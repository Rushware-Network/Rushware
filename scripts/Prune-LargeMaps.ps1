param(
    [string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package'),
    [switch]$Apply,
    [switch]$SkipArchives
)
. "$PSScriptRoot/Common.ps1"
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$workspacePrefix = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\') + '\'
if (-not ($ServerRoot + '\').StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'ServerRoot must resolve inside this workspace.'
}
$policy = Get-Content -LiteralPath (Join-Path $ProjectRoot 'deployment/map-capacity-policy.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($include in $policy.includesSha256.PSObject.Properties) {
    $path = Join-Path $ServerRoot ('plugins/PGM/includes/' + $include.Name)
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $include.Value) { throw "Shared include changed since capacity audit: $($include.Name)" }
}
$poolPath = Join-Path $ServerRoot 'plugins/PGM/map-pools.yml'
$pool = Get-Content -LiteralPath $poolPath -Raw -Encoding UTF8
if ($pool -notmatch '(?m)^    variants: \[default\]\s*$') { throw 'This policy is audited for the default variant only.' }
$targets = @()
$entries = @()
foreach ($map in $policy.removedMaps) {
    if ($map.capacity -le $policy.maxPlayers) { throw "Invalid policy entry: $($map.name)" }
    if ($map.directory -notmatch '^maps/(?:PublicMaps|CommunityMaps)/[^.].+') { throw 'Invalid map directory in policy.' }
    $target = [IO.Path]::GetFullPath((Join-Path $ServerRoot $map.directory))
    $mapsPrefix = [IO.Path]::GetFullPath((Join-Path $ServerRoot 'maps')).TrimEnd('\') + '\'
    if (-not $target.StartsWith($mapsPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Map target escapes maps directory.' }
    $entry = "      - '" + $map.name.Replace("'", "''") + "'"
    $entries += $entry
    if (-not (Test-Path -LiteralPath $target)) { continue }
    # Check every path component and descendant before any recursive deletion.
    $ancestor = Get-Item -LiteralPath $target -Force
    while ($ancestor.FullName -ne $ServerRoot) {
        if ($ancestor.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing reparse point: $($ancestor.FullName)" }
        $ancestor = $ancestor.Parent
        if (-not $ancestor) { throw 'Could not verify map ancestry.' }
    }
    $children = @(Get-ChildItem -LiteralPath $target -Recurse -Force)
    if ($children | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }) { throw "Refusing map containing reparse points: $target" }
    $xmlPath = Join-Path $target 'map.xml'
    if ((Get-FileHash -LiteralPath $xmlPath -Algorithm SHA256).Hash -ne $map.mapXmlSha256) { throw "Map XML changed since capacity audit: $($map.name)" }
    [xml]$xml = Get-Content -LiteralPath $xmlPath -Raw -Encoding UTF8
    if ($xml.map.name.Trim() -cne $map.name) { throw "Map name mismatch: $target" }
    $size = ($children | Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    $targets += [pscustomobject]@{ Path=$target; Relative=$map.directory; Name=$map.name; Bytes=$size }
}
$newPool = (($pool -split "`r?`n" | Where-Object { $_ -cnotin $entries }) -join "`n").TrimEnd() + "`n"
$remainingCount = [regex]::Matches($newPool, "(?m)^      - '").Count
Write-Host "Capacity policy: maximum $($policy.maxPlayers), default variant. Remove $($targets.Count) installed maps; remaining pool entries: $remainingCount."
if (-not $Apply) { $targets | Select-Object Name,Relative,Bytes; return }
$sevenZip = Join-Path $ServerRoot 'server-package.7z'
$zip = Join-Path $ServerRoot 'server-package.zip'
$tool = Join-Path $ProjectRoot '.local/tools/7zr.exe'
$staged = Join-Path $ServerRoot 'server-package.next.7z'
if (-not $SkipArchives -and (Test-Path -LiteralPath $sevenZip)) {
    if (-not (Test-Path -LiteralPath $tool)) { throw 'Missing .local/tools/7zr.exe.' }
    if (Test-Path -LiteralPath $staged) { throw 'Inspect existing staged 7z before proceeding.' }
}
$backup = Join-Path $ServerRoot ('.backups/map-capacity-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$null = New-Item -ItemType Directory -Path $backup
Copy-Item -LiteralPath $poolPath -Destination $backup
$utf8 = [Text.UTF8Encoding]::new($false)
foreach ($target in $targets) { Remove-Item -LiteralPath $target.Path -Recurse -Force }
[IO.File]::WriteAllText($poolPath, $newPool, $utf8)
$updated = @('plugins/PGM/map-pools.yml')
foreach ($spec in @(@('PUBLICMAPS.json','PublicMaps'), @('COMMUNITYMAPS.json','CommunityMaps/touchdown'), @('ARCADEMAPS.json','CommunityMaps/arcade'))) {
    $manifestPath = Join-Path $ServerRoot $spec[0]
    if (-not (Test-Path -LiteralPath $manifestPath)) { continue }
    Copy-Item -LiteralPath $manifestPath -Destination $backup
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $mapRoot = Join-Path $ServerRoot ('maps/' + $spec[1])
    $installed = @(Get-ChildItem -LiteralPath $mapRoot -Recurse -Filter map.xml)
    $installedNames = @($installed | ForEach-Object { ([xml](Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8)).map.name.Trim() } | Sort-Object)
    $manifest.mapCount = $installed.Count
    if ($manifest.PSObject.Properties['mapNames']) { $manifest.mapNames = $installedNames }
    if ($manifest.PSObject.Properties['categories']) {
        foreach ($category in @($manifest.categories.PSObject.Properties.Name)) {
            $manifest.categories.$category = @(Get-ChildItem -LiteralPath (Join-Path $mapRoot $category) -Recurse -Filter map.xml).Count
        }
    }
    if ($manifest.PSObject.Properties['poolMapCount']) {
        $manifest.poolMapCount = @($installedNames | Where-Object { $newPool.Contains("      - '" + $_.Replace("'", "''") + "'") }).Count
    }
    $manifest | Add-Member -NotePropertyName capacityPolicy -NotePropertyValue @{maxPlayers=24; variant='default'; source='deployment/map-capacity-policy.json'} -Force
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8) + "`n", $utf8)
    $updated += $spec[0]
}
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/map-capacity-policy.json') -Destination (Join-Path $ServerRoot 'MAP_CAPACITY_POLICY.json') -Force
$updated += 'MAP_CAPACITY_POLICY.json'
if (-not $SkipArchives -and (Test-Path -LiteralPath $sevenZip)) {
    Copy-Item -LiteralPath $sevenZip -Destination $staged
    $list = Join-Path $backup 'archive-removals.txt'
    # Remove directory entries as well as their contents, including on repeat runs.
    [IO.File]::WriteAllLines($list, @($policy.removedMaps | ForEach-Object { $_.directory; $_.directory + '/*' }), $utf8)
    Push-Location $ServerRoot
    try {
        & $tool d $staged "@$list" -scsUTF-8 -bso0 -bsp0
        if ($LASTEXITCODE -ne 0) { throw '7z map deletion failed; original archive retained.' }
        & $tool a $staged @updated -mx=1 -ms=off -bso0 -bsp0
        if ($LASTEXITCODE -ne 0) { throw '7z metadata update failed; original archive retained.' }
        & $tool t $staged -bso0 -bsp0
        if ($LASTEXITCODE -ne 0) { throw '7z validation failed; original archive retained.' }
        Move-Item -LiteralPath $staged -Destination $sevenZip -Force
    } finally { Pop-Location }
}
if (-not $SkipArchives -and (Test-Path -LiteralPath $zip)) { & "$PSScriptRoot/Package-ServerZip.ps1" }
Write-Host "Map pruning complete. Configuration/manifest backup: $backup. Shared includes, licenses, saved worlds and player data retained."
