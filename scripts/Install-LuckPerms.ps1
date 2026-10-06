param([string]$ServerRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server-package'))
. "$PSScriptRoot/Common.ps1"
$ServerRoot = (Resolve-Path -LiteralPath $ServerRoot).Path
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
$artifact = Join-Path $ServerRoot 'plugins/LuckPerms.jar'
if (-not (Test-Path -LiteralPath $artifact)) {
    Invoke-WebRequest -Uri $lock.luckperms.url -OutFile "$artifact.download" -UseBasicParsing
    if ((Get-FileHash -LiteralPath "$artifact.download" -Algorithm SHA256).Hash -ne $lock.luckperms.sha256) { throw 'LuckPerms checksum mismatch.' }
    Move-Item -LiteralPath "$artifact.download" -Destination $artifact
}
if ((Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash -ne $lock.luckperms.sha256) { throw 'Installed LuckPerms differs from the pinned release. Preserve custom builds separately.' }
$licenses = Join-Path $ServerRoot 'licenses'
$null = New-Item -ItemType Directory -Path $licenses -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/licenses/LuckPerms-LICENSE.txt') -Destination $licenses -Force
# Let LuckPerms generate its defaults; preserve existing configuration and permission data.
Write-Host "LuckPerms $($lock.luckperms.version) installed in $ServerRoot. No custom groups or titles were created."
