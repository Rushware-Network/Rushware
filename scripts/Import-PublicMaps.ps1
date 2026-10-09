param(
    [string]$SourceRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) '.local/PublicMaps'),
    [string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package')
)
. "$PSScriptRoot/Common.ps1"
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$configPath = Join-Path $ServerRoot 'plugins/PGM/config.yml'
$destination = Join-Path $ServerRoot 'maps/PublicMaps'
if (Test-Path -LiteralPath $destination) { throw 'PublicMaps already exists in the server. Refusing to overwrite existing maps.' }
if (-not (Test-Path -LiteralPath $configPath)) { throw 'PGM config.yml is missing.' }
$modes = @('kotf', 'ffa', 'koth', 'tdm')
$names = @()
$counts = @{}
foreach ($mode in $modes) {
    $modePath = Join-Path $SourceRoot $mode
    if (-not (Test-Path -LiteralPath $modePath)) { throw "Missing map category: $mode" }
    $maps = Get-ChildItem -LiteralPath $modePath -Recurse -Filter map.xml
    $counts[$mode] = $maps.Count
    foreach ($file in $maps) {
        [xml]$xml = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        $name = $xml.SelectSingleNode('/map/name')
        if (-not $name -or -not $name.InnerText.Trim()) { throw "Missing map name: $($file.FullName)" }
        $names += $name.InnerText.Trim()
    }
}
if (($names | Select-Object -Unique).Count -ne $names.Count) { throw 'Duplicate map names require manual review.' }
$excludedNames = Get-Content (Join-Path $ProjectRoot 'deployment/map-pool-exclusions.json') -Raw | ConvertFrom-Json
$poolNames = @($names | Where-Object { $_ -cnotin $excludedNames })
$includesRoot = Join-Path $ServerRoot 'plugins/PGM/includes'
$sourceIncludes = Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'includes') -File
foreach ($include in $sourceIncludes) {
    $target = Join-Path $includesRoot $include.Name
    if ((Test-Path -LiteralPath $target) -and
        (Get-FileHash -LiteralPath $target).Hash -ne (Get-FileHash -LiteralPath $include.FullName).Hash) {
        throw "Conflicting include: $($include.Name)"
    }
}
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8
if ([regex]::Matches($config, '(?m)^  (?:#\s*)?pools:.*$').Count -ne 1) { throw 'Could not locate the map.pools configuration entry.' }
$backupRoot = Join-Path $ServerRoot ('.backups/publicmaps-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$null = New-Item -ItemType Directory -Path $backupRoot, $destination -Force
Copy-Item -LiteralPath $configPath -Destination (Join-Path $backupRoot 'config.yml')
$poolPath = Join-Path $ServerRoot 'plugins/PGM/map-pools.yml'
if (Test-Path -LiteralPath $poolPath) { Copy-Item -LiteralPath $poolPath -Destination (Join-Path $backupRoot 'map-pools.yml') }
foreach ($mode in $modes) {
    Copy-Item -LiteralPath (Join-Path $SourceRoot $mode) -Destination $destination -Recurse
}
Copy-Item -LiteralPath (Join-Path $SourceRoot 'README.md') -Destination $destination
$null = New-Item -ItemType Directory -Path $includesRoot -Force
$sourceIncludes | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $includesRoot -Force }
$pool = @(
    '# Rushware: PublicMaps KOTF / FFA / KOTH / TDM end-of-match voting.',
    'pools:',
    '  publicmaps:',
    '    type: voted',
    '    enabled: true',
    '    dynamic: true',
    '    players: 0',
    '    cycle-time: "35s"',
    '    poll-delay: "5s"',
    '    vote-options: 5',
    '    variants: [default]',
    '    modifier: "score * bound(1 - (0.2 * same_gamemode), 0.2, 1)"',
    '    score:',
    '      persist: true',
    '    maps:'
)
$pool += $poolNames | Sort-Object | ForEach-Object { "      - '" + $_.Replace("'", "''") + "'" }
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($poolPath, ($pool -join "`n") + "`n", $utf8)
$config = [regex]::Replace($config, '(?m)^  (?:#\s*)?pools:.*$', '  pools: "map-pools.yml"')
$config = [regex]::Replace($config, '(?m)^    - "maps"\r?$', '    - "maps/PublicMaps"')
[System.IO.File]::WriteAllText($configPath, $config, $utf8)
$revision = & git -C $SourceRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Could not read the PublicMaps revision.' }
$manifest = [ordered]@{ repository='https://github.com/OvercastCommunity/PublicMaps'; commit=$revision; mapCount=$names.Count; poolMapCount=$poolNames.Count; excludedMapNames=$excludedNames; categories=$counts; voting='voted'; pollDelay='5s'; voteOptions=5; cycleTime='35s' }
[System.IO.File]::WriteAllText((Join-Path $ServerRoot 'PUBLICMAPS.json'), ($manifest | ConvertTo-Json -Depth 4) + "`n", $utf8)
Write-Host "Imported $($names.Count) PublicMaps maps and their shared includes. Restart the server to enable the voted pool."
& "$PSScriptRoot/Prune-LargeMaps.ps1" -ServerRoot $ServerRoot -Apply -SkipArchives
Write-Host "Previous configuration backed up in $backupRoot"
