Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try {
    $javaHome = if ($env:RUSHWARE_JAVA_HOME) { $env:RUSHWARE_JAVA_HOME } else { $env:JAVA_HOME }
    if (-not $javaHome) { throw 'Set JAVA_HOME or RUSHWARE_JAVA_HOME to JDK 25.' }
    $javaExe = Join-Path $javaHome 'bin/java.exe'
    $release = Join-Path $javaHome 'release'
    if (-not (Test-Path -LiteralPath $javaExe) -or -not (Test-Path -LiteralPath $release)) { throw 'Invalid JDK directory.' }
    if (-not (Select-String -LiteralPath $release -Pattern '^JAVA_VERSION="25[.\"]' -Quiet)) { throw 'JDK 25 is required.' }
    $lock = Get-Content (Join-Path $PSScriptRoot 'dependencies.lock.json') -Raw | ConvertFrom-Json
    foreach ($name in @('SportPaper.jar', 'plugins/PGM.jar', 'plugins/RushwareGuard.jar', 'eula.txt')) {
        if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot $name))) { throw "Missing $name" }
    }
    if (-not (Select-String -LiteralPath (Join-Path $PSScriptRoot 'eula.txt') -Pattern '^eula=true\s*$' -Quiet)) {
        throw 'Read https://aka.ms/MinecraftEULA and set eula=true in eula.txt if you agree.'
    }
    if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'SportPaper.jar') -Algorithm SHA256).Hash -ne $lock.sportpaper.sha256) {
        throw 'SportPaper checksum mismatch.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'plugins/WorldEdit.jar')) -or
        (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'plugins/WorldEdit.jar') -Algorithm SHA256).Hash -ne $lock.worldedit.sha256) {
        throw 'WorldEdit is missing or its checksum differs from dependencies.lock.json.'
    }
    foreach ($plugin in (Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'plugins') -Filter '*.jar')) {
        if ($plugin.Name -notin @('PGM.jar', 'RushwareGuard.jar', 'WorldEdit.jar', 'LuckPerms.jar')) { throw "Unreviewed plugin: $($plugin.Name)" }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'plugins/LuckPerms.jar')) -or
        (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'plugins/LuckPerms.jar') -Algorithm SHA256).Hash -ne $lock.luckperms.sha256) {
        throw 'LuckPerms is missing or its checksum differs from dependencies.lock.json.'
    }
    Push-Location $PSScriptRoot
    try {
        $javaArgs = @('-Xms256M', '-Xmx2G', '-Dterminal.jline=false', '-Dterminal.ansi=true', '-jar', 'SportPaper.jar', 'nogui')
        & $javaExe @javaArgs
        if ($LASTEXITCODE -ne 0) { throw "Server exited with code $LASTEXITCODE" }
    } finally { Pop-Location }
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
