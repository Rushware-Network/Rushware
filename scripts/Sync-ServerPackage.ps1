. "$PSScriptRoot/Common.ps1"
$packageRoot = Join-Path $ProjectRoot 'server-package'
if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) {
    Write-Host 'No server-package directory yet. Run Package-LocalTestServer.ps1 to create it.'
    return
}
$pluginNames = @('PGM.jar', 'RushwareGuard.jar', 'RushwareModeration.jar')
$archivePath = Join-Path $packageRoot 'server-package.7z'
$archiveTool = $null
if (Test-Path -LiteralPath $archivePath) {
    $candidates = @(
        (Join-Path $ProjectRoot '.local/tools/7zr.exe'),
        'C:/Program Files/7-Zip/7z.exe',
        'F:/Program Files/7-Zip/7z.exe'
    )
    foreach ($toolName in @('7z', '7za', '7zz', '7zr')) {
        $command = Get-Command $toolName -ErrorAction SilentlyContinue
        if ($command) { $candidates += $command.Source }
    }
    $archiveTool = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $archiveTool) { throw 'Install 7-Zip or place 7zr.exe in .local/tools/ to update server-package.7z.' }
}
$hashes = [ordered]@{}
foreach ($name in $pluginNames) {
    $artifact = Join-Path $ProjectRoot "build/libs/$name"
    if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "Missing artifact: $artifact" }
    $hashes[$name] = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash
}
$null = New-Item -ItemType Directory -Force -Path (Join-Path $packageRoot 'plugins')
foreach ($name in $pluginNames) {
    $destination = Join-Path $packageRoot "plugins/$name"
    Copy-Item -LiteralPath (Join-Path $ProjectRoot "build/libs/$name") -Destination $destination -Force
    if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $hashes[$name]) {
        throw "Package checksum mismatch: $name"
    }
}
$revision = & git -C $ProjectRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Could not read source revision.' }
$manifest = [ordered]@{
    builtAtUtc = [DateTime]::UtcNow.ToString('o')
    sourceCommit = $revision
    sha256 = $hashes
}
$manifestPath = Join-Path $packageRoot 'ARTIFACTS.json'
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 4) + "`n", [Text.UTF8Encoding]::new($false))
if ($archiveTool) {
    # Update only built plugins and their manifest; retain existing archived configuration/data.
    $stagedArchive = Join-Path $packageRoot 'server-package.next.7z'
    if (Test-Path -LiteralPath $stagedArchive) { throw 'server-package.next.7z exists; inspect the previous interrupted archive update first.' }
    Copy-Item -LiteralPath $archivePath -Destination $stagedArchive
    Push-Location $packageRoot
    try {
        $entries = @($pluginNames | ForEach-Object { "plugins/$_" }) + @('ARTIFACTS.json')
        & $archiveTool a $stagedArchive @entries -mx=1 -ms=off -bso0 -bsp0
        if ($LASTEXITCODE -ne 0) { throw 'Archive update failed; original server-package.7z was preserved.' }
        & $archiveTool t $stagedArchive -bso0 -bsp0
        if ($LASTEXITCODE -ne 0) { throw 'Archive verification failed; original server-package.7z was preserved.' }
        Move-Item -LiteralPath $stagedArchive -Destination $archivePath -Force
    } finally { Pop-Location }
}
Write-Host 'Latest plugins copied to server-package/plugins; SHA-256 verified.'
if ($archiveTool) { Write-Host 'server-package/server-package.7z updated and verified.' }
if (Test-Path -LiteralPath (Join-Path $packageRoot 'server-package.zip')) {
    & "$PSScriptRoot/Package-ServerZip.ps1"
}
