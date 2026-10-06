. "$PSScriptRoot/Common.ps1"
$javaExe = Get-RushwareJava
foreach ($name in @('SportPaper.jar', 'plugins/PGM.jar', 'plugins/RushwareGuard.jar', 'server.properties', 'eula.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $RuntimeRoot $name))) { throw "Missing $name. Run Setup-DevServer.ps1 first." }
}
if (-not (Select-String -LiteralPath (Join-Path $RuntimeRoot 'eula.txt') -Pattern '^eula=true\s*$' -Quiet)) {
    throw 'Minecraft EULA has not been accepted in runtime/eula.txt.'
}
$lock = Get-Content (Join-Path $ProjectRoot 'deployment/dependencies.lock.json') -Raw | ConvertFrom-Json
if ((Get-FileHash -LiteralPath (Join-Path $RuntimeRoot 'SportPaper.jar') -Algorithm SHA256).Hash -ne $lock.sportpaper.sha256) {
    throw 'SportPaper checksum mismatch.'
}
$plugins = Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot 'plugins') -Filter '*.jar'
foreach ($plugin in $plugins) {
    if ($plugin.Name -notin @('PGM.jar', 'RushwareGuard.jar')) {
        throw "Unreviewed plugin $($plugin.Name). Review admission compatibility before extending this allowlist."
    }
}
Push-Location $RuntimeRoot
try {
    $javaArgs = @('-Xms256M', '-Xmx2G', '-Dterminal.jline=false', '-Dterminal.ansi=true', '-jar', 'SportPaper.jar', 'nogui')
    & $javaExe @javaArgs
    if ($LASTEXITCODE -ne 0) { throw "Server exited with code $LASTEXITCODE" }
} finally { Pop-Location }
