. "$PSScriptRoot/Common.ps1"
$packageRoot = Join-Path $ProjectRoot 'server-package'
if (Test-Path -LiteralPath $packageRoot) {
    throw 'server-package already exists. Preserve any server/player data by renaming it before creating a new package.'
}
foreach ($file in @('SportPaper.jar', 'maps/README.md')) {
    if (-not (Test-Path -LiteralPath (Join-Path $RuntimeRoot $file))) { throw 'Run Setup-DevServer.ps1 first.' }
}
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
if ((Get-FileHash -LiteralPath (Join-Path $RuntimeRoot 'SportPaper.jar') -Algorithm SHA256).Hash -ne $lock.sportpaper.sha256) {
    throw 'SportPaper checksum mismatch.'
}
foreach ($name in @('PGM.jar', 'RushwareGuard.jar')) {
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot "build/libs/$name"))) { throw 'Run Build.ps1 first.' }
}
$null = New-Item -ItemType Directory -Path $packageRoot, "$packageRoot/plugins/PGM", "$packageRoot/plugins/RushwareGuard", "$packageRoot/maps", "$packageRoot/licenses"
Copy-Item -LiteralPath (Join-Path $RuntimeRoot 'SportPaper.jar') -Destination $packageRoot
foreach ($name in @('PGM.jar', 'RushwareGuard.jar')) {
    Copy-Item -LiteralPath (Join-Path $ProjectRoot "build/libs/$name") -Destination "$packageRoot/plugins/$name"
}
foreach ($name in @('server.properties', 'sportpaper.yml', 'dependencies.lock.json')) {
    Copy-Item -LiteralPath (Join-Path $ProjectRoot "deployment/$name") -Destination $packageRoot
}
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/Start-Standalone.bat') -Destination "$packageRoot/Start.bat"
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/Start-Standalone.ps1') -Destination "$packageRoot/Start.ps1"
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'deployment/LOCAL_TEST_README.md') -Destination "$packageRoot/README.md"
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'core/src/main/resources/config.yml') -Destination "$packageRoot/plugins/PGM/config.yml"
Set-Content -LiteralPath "$packageRoot/plugins/RushwareGuard/config.yml" -Encoding ASCII -Value @('# LOCAL TEST ONLY: allows loopback protocol 47, not exact 1.8.9 verification.', 'local-test: true')
Set-Content -LiteralPath "$packageRoot/eula.txt" -Encoding ASCII -Value @('# Read https://aka.ms/MinecraftEULA before accepting.', 'eula=false')
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot 'maps') -Force | Where-Object Name -ne '.git' | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination "$packageRoot/maps" -Recurse
}
foreach ($name in @('LICENSE', 'LICENSE_LINKING')) {
    Copy-Item -LiteralPath (Join-Path $ProjectRoot $name) -Destination "$packageRoot/licenses"
}
$revision = & git -C $ProjectRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Could not read source revision.' }
Set-Content -LiteralPath "$packageRoot/BUILD.txt" -Encoding ASCII -Value @("Rushware source commit: $revision", 'Profile: local gameplay testing only; not strict 1.8.9 verification.', 'Required Java: JDK 25')
Write-Host "Standalone local test package created: $packageRoot"
if (Test-Path -LiteralPath (Join-Path $ProjectRoot '.local/PublicMaps/kotf')) {
    & "$PSScriptRoot/Import-PublicMaps.ps1" -ServerRoot $packageRoot
}
