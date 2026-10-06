param([string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package'))
. "$PSScriptRoot/Common.ps1"
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$configPath = Join-Path $ServerRoot 'plugins/PGM/config.yml'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8
$existing = [regex]::Matches($config, '(?m)^  (admin|sponsor|supporter):').Count
if ($existing -gt 0 -and $existing -ne 3) { throw 'Partial/custom PGM groups require review; refusing to overwrite.' }
if ([regex]::Matches($config, '(?m)^  max-extra-votes:').Count -ne 1) { throw 'Cannot locate vote multiplier limit.' }
$backupRoot = Join-Path $ServerRoot ('.backups/permissions-' + (Get-Date -Format yyyyMMdd-HHmmss))
$null = New-Item -ItemType Directory -Path $backupRoot -Force
Copy-Item -LiteralPath $configPath -Destination $backupRoot
if ($existing -eq 0) {
    if ([regex]::Matches($config, '(?m)^  default:').Count -ne 1) { throw 'Cannot locate default group.' }
    $groupTemplate = Get-Content -LiteralPath (Join-Path $ProjectRoot 'deployment/rushware-pgm-groups.yml') -Raw -Encoding UTF8
    $config = [regex]::Replace($config, '(?m)^  default:', ($groupTemplate.TrimEnd() + "`n  default:"))
}
$config = [regex]::Replace($config, '(?m)^  max-extra-votes:.*$', '  max-extra-votes: 10 # Admin 10, Sponsor 5, Supporter 3, Default 1')
$config = [regex]::Replace($config, '(?m)^  allow-extra-votes:.*$', '  allow-extra-votes: true')
[IO.File]::WriteAllText($configPath, $config, (New-Object Text.UTF8Encoding($false)))
$lpFolder = Join-Path $ServerRoot 'plugins/LuckPerms'
$null = New-Item -ItemType Directory -Path $lpFolder -Force
$jsonBytes = [IO.File]::ReadAllBytes((Join-Path $ProjectRoot 'deployment/luckperms-rushware-groups.json'))
$output = [IO.File]::Create((Join-Path $lpFolder 'rushware-groups.json.gz'))
$gzip = New-Object IO.Compression.GZipStream($output, [IO.Compression.CompressionMode]::Compress)
try { $gzip.Write($jsonBytes, 0, $jsonBytes.Length) } finally { $gzip.Dispose(); $output.Dispose() }
Write-Host 'PGM groups prepared. After restarting, console: lp export before-rushware-groups; lp import rushware-groups --replace'
Write-Host 'Only the four defined groups are replaced; player memberships are not changed. Retain the export as a backup.'
