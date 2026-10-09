param(
    [string]$SourceRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) '.local/CommunityMaps'),
    [string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package')
)
. "$PSScriptRoot/Common.ps1"
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $SourceRoot)) {
    & git clone --filter=blob:none --sparse $lock.communitymaps.repository $SourceRoot
    if ($LASTEXITCODE -ne 0) { throw 'CommunityMaps clone failed.' }
    & git -C $SourceRoot sparse-checkout set touchdown
    if ($LASTEXITCODE -ne 0) { throw 'CommunityMaps sparse checkout failed.' }
    & git -C $SourceRoot checkout --detach $lock.communitymaps.commit
    if ($LASTEXITCODE -ne 0) { throw 'Pinned CommunityMaps checkout failed.' }
}
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$revision = & git -C $SourceRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $revision -ne $lock.communitymaps.commit) { throw 'CommunityMaps revision does not match the lock file.' }
$destination = Join-Path $ServerRoot 'maps/CommunityMaps'
if (Test-Path -LiteralPath $destination) { throw 'CommunityMaps already exists; refusing to overwrite maps.' }
$poolPath = Join-Path $ServerRoot 'plugins/PGM/map-pools.yml'
$configPath = Join-Path $ServerRoot 'plugins/PGM/config.yml'
$pool = Get-Content -LiteralPath $poolPath -Raw -Encoding UTF8
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8
if ($pool -notmatch '(?m)^  publicmaps:' -or [regex]::Matches($pool, '(?m)^    maps:').Count -ne 1) { throw 'Expected the existing single publicmaps vote pool.' }
if ([regex]::Matches($config, '(?m)^    - "maps/PublicMaps"\r?$').Count -ne 1) { throw 'Expected the existing PublicMaps folder configuration.' }
$names = @()
foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'touchdown') -Recurse -Filter map.xml)) {
    [xml]$xml = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $name = $xml.SelectSingleNode('/map/name').InnerText.Trim()
    if (-not $name -or $name -cin $names) { throw "Missing or duplicate map name: $($file.FullName)" }
    $entry = "      - '" + $name.Replace("'", "''") + "'"
    if ($pool.Contains($entry)) { throw "Map already in the pool: $name" }
    foreach ($include in $xml.SelectNodes('/map/include')) {
        if (-not (Test-Path -LiteralPath (Join-Path $ServerRoot "plugins/PGM/includes/$($include.id).xml"))) { throw "Missing shared include: $($include.id). Import PublicMaps first." }
    }
    $names += $name
}
if ($names.Count -ne $lock.communitymaps.mapCount) { throw 'Unexpected touchdown map count.' }
$backupRoot = Join-Path $ServerRoot ('.backups/touchdown-' + (Get-Date -Format yyyyMMdd-HHmmss))
$null = New-Item -ItemType Directory -Path $backupRoot, $destination -Force
Copy-Item -LiteralPath $poolPath, $configPath -Destination $backupRoot
Copy-Item -LiteralPath (Join-Path $SourceRoot 'touchdown') -Destination $destination -Recurse
Copy-Item -LiteralPath (Join-Path $SourceRoot 'README.md'), (Join-Path $SourceRoot 'LICENSE.md') -Destination $destination
$pool = $pool.TrimEnd() + "`n" + (($names | Sort-Object | ForEach-Object { "      - '" + $_.Replace("'", "''") + "'" }) -join "`n") + "`n"
$config = [regex]::Replace($config, '(?m)^    - "maps/PublicMaps"\r?$', "    - `"maps/PublicMaps`"`n    - `"maps/CommunityMaps`"")
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($poolPath, $pool, $utf8)
[IO.File]::WriteAllText($configPath, $config, $utf8)
$manifest = [ordered]@{repository=$lock.communitymaps.repository; commit=$revision; category='touchdown'; mapCount=$names.Count; mapNames=$names; pool='publicmaps'; voting='voted'}
[IO.File]::WriteAllText((Join-Path $ServerRoot 'COMMUNITYMAPS.json'), ($manifest | ConvertTo-Json -Depth 4), $utf8)
Write-Host "Imported $($names.Count) touchdown maps into the existing voted pool. Restart to apply. Backup: $backupRoot"
& "$PSScriptRoot/Prune-LargeMaps.ps1" -ServerRoot $ServerRoot -Apply -SkipArchives
