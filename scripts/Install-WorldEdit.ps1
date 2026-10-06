param([string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package'))
. "$PSScriptRoot/Common.ps1"
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
$artifact = Join-Path $ServerRoot 'plugins/WorldEdit.jar'
if (-not (Test-Path -LiteralPath $artifact)) {
    Invoke-WebRequest -Uri $lock.worldedit.url -OutFile "$artifact.download" -UseBasicParsing
    if ((Get-FileHash -LiteralPath "$artifact.download" -Algorithm SHA256).Hash -ne $lock.worldedit.sha256) { throw 'WorldEdit checksum mismatch.' }
    Move-Item -LiteralPath "$artifact.download" -Destination $artifact
}
if ((Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash -ne $lock.worldedit.sha256) { throw 'Installed WorldEdit differs from the pinned release. Preserve custom builds separately.' }
$licenses = Join-Path $ServerRoot 'licenses'
$null = New-Item -ItemType Directory -Path $licenses -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/licenses/WorldEdit-LICENSE.txt') -Destination $licenses -Force
$config = Join-Path $ServerRoot 'plugins/WorldEdit/config.yml'
if (-not (Test-Path -LiteralPath $config)) {
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $config) -Force
    Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/worldedit-config.yml') -Destination $config
}
Write-Host "WorldEdit $($lock.worldedit.version) installed in $ServerRoot"
