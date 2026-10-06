. "$PSScriptRoot/Common.ps1"
$null = Get-RushwareJava
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
$null = New-Item -ItemType Directory -Force -Path $RuntimeRoot, (Join-Path $RuntimeRoot 'plugins/PGM')
$icon = Join-Path $ProjectRoot 'assets/branding/server-icon.png'
$runtimeIcon = Join-Path $RuntimeRoot 'server-icon.png'
if ((Test-Path -LiteralPath $icon) -and -not (Test-Path -LiteralPath $runtimeIcon)) {
    Copy-Item -LiteralPath $icon -Destination $runtimeIcon
}
$serverJar = Join-Path $RuntimeRoot 'SportPaper.jar'
if (-not (Test-Path -LiteralPath $serverJar)) {
    Invoke-WebRequest -Uri $lock.sportpaper.url -OutFile "$serverJar.download" -UseBasicParsing
    if ((Get-FileHash -LiteralPath "$serverJar.download" -Algorithm SHA256).Hash -ne $lock.sportpaper.sha256) {
        throw 'SportPaper checksum mismatch; downloaded file was not installed.'
    }
    Move-Item -LiteralPath "$serverJar.download" -Destination $serverJar
}
if ((Get-FileHash -LiteralPath $serverJar -Algorithm SHA256).Hash -ne $lock.sportpaper.sha256) {
    throw 'Installed SportPaper does not match dependencies.lock.json.'
}
foreach ($name in @('server.properties', 'sportpaper.yml')) {
    $destination = Join-Path $RuntimeRoot $name
    if (-not (Test-Path -LiteralPath $destination)) {
        Copy-Item -LiteralPath (Join-Path $ProjectRoot "deployment/$name") -Destination $destination
    }
}
$pgmConfig = Join-Path $RuntimeRoot 'plugins/PGM/config.yml'
if (-not (Test-Path -LiteralPath $pgmConfig)) {
    Copy-Item -LiteralPath (Join-Path $ProjectRoot 'core/src/main/resources/config.yml') -Destination $pgmConfig
}
$mapsPath = Join-Path $RuntimeRoot 'maps'
if (-not (Test-Path -LiteralPath $mapsPath)) {
    & git clone $lock.maps.repository $mapsPath
    if ($LASTEXITCODE -ne 0) { throw 'Map repository clone failed.' }
    & git -C $mapsPath checkout --detach $lock.maps.commit
    if ($LASTEXITCODE -ne 0) { throw 'Could not check out the pinned map revision.' }
}
$mapHead = & git -C $mapsPath rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $mapHead -ne $lock.maps.commit) { throw 'Map revision does not match the lock file.' }
$eula = Join-Path $RuntimeRoot 'eula.txt'
if (-not (Test-Path -LiteralPath $eula)) {
    Set-Content -LiteralPath $eula -Encoding ASCII -Value @('# Read https://aka.ms/MinecraftEULA before accepting.', 'eula=false')
}
foreach ($name in @('PGM.jar', 'RushwareGuard.jar')) {
    $artifact = Join-Path $ProjectRoot "build/libs/$name"
    if (-not (Test-Path -LiteralPath $artifact)) { throw "Missing $name. Run scripts/Build.ps1 first." }
    Copy-Item -LiteralPath $artifact -Destination (Join-Path $RuntimeRoot "plugins/$name") -Force
}
& "$PSScriptRoot/Install-WorldEdit.ps1" -ServerRoot $RuntimeRoot
& "$PSScriptRoot/Install-LuckPerms.ps1" -ServerRoot $RuntimeRoot
Write-Host 'Dev server prepared in runtime/. Strict admission stays closed until a trusted verifier is implemented.'
Write-Host 'Read the Minecraft EULA and accept it in runtime/eula.txt before using Start-DevServer.ps1.'
