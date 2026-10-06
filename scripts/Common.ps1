Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RuntimeRoot = Join-Path $ProjectRoot 'runtime'

function Get-RushwareJava {
    $javaHome = if ($env:RUSHWARE_JAVA_HOME) { $env:RUSHWARE_JAVA_HOME } else { $env:JAVA_HOME }
    if (-not $javaHome) { throw 'Set RUSHWARE_JAVA_HOME or JAVA_HOME to a JDK 25 installation.' }
    $javaExe = Join-Path $javaHome 'bin/java.exe'
    $releaseFile = Join-Path $javaHome 'release'
    if (-not (Test-Path -LiteralPath $javaExe) -or -not (Test-Path -LiteralPath $releaseFile)) {
        throw "Invalid JDK directory: $javaHome"
    }
    if (-not (Select-String -LiteralPath $releaseFile -Pattern '^JAVA_VERSION="25[.\"]' -Quiet)) {
        throw 'This PGM revision requires JDK 25. Minecraft 1.8.9 is a separate version number.'
    }
    return $javaExe
}

function Invoke-RushwareGradle {
    param([string[]]$Tasks)
    $javaExe = Get-RushwareJava
    Push-Location $ProjectRoot
    try {
        & $javaExe -cp 'gradle/wrapper/gradle-wrapper.jar' org.gradle.wrapper.GradleWrapperMain @Tasks --console=plain
        if ($LASTEXITCODE -ne 0) { throw "Gradle failed with exit code $LASTEXITCODE" }
    } finally { Pop-Location }
}
