. "$PSScriptRoot/Common.ps1"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$packageRoot = (Resolve-Path -LiteralPath (Join-Path $ProjectRoot 'server-package')).Path
$destination = Join-Path $packageRoot 'server-package.zip'
$stagedZip = Join-Path $packageRoot 'server-package.next.zip'
if (Test-Path -LiteralPath $stagedZip) { throw 'Inspect the existing server-package.next.zip from an interrupted packaging run.' }
$files = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File -Force | Where-Object {
    $relative = $_.FullName.Substring($packageRoot.Length + 1).Replace('\', '/')
    $relative -notmatch '^(?:\.backups/|logs/|match-\d+/)' -and
    $relative -notmatch '^server-package(?:\.next)?\.(?:7z|zip)$'
})
$stream = [IO.File]::Create($stagedZip)
$archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($packageRoot.Length + 1).Replace('\', '/')
        $null = [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $relative, [IO.Compression.CompressionLevel]::Optimal)
    }
} finally { $archive.Dispose(); $stream.Dispose() }
$check = [IO.Compression.ZipFile]::OpenRead($stagedZip)
try {
    if ($check.Entries.Count -ne $files.Count) { throw 'ZIP file count mismatch.' }
    foreach ($name in @('SportPaper.jar', 'plugins/PGM.jar', 'plugins/RushwareGuard.jar', 'plugins/RushwareModeration.jar', 'plugins/PGM/config.yml', 'plugins/PGM/map-pools.yml', 'plugins/LuckPerms/luckperms-h2-v2.mv.db', 'ARCADEMAPS.json')) {
        if (-not $check.GetEntry($name)) { throw "Required ZIP entry missing: $name" }
    }
    foreach ($pluginName in @('PGM.jar', 'RushwareGuard.jar', 'RushwareModeration.jar')) {
        $entryStream = $check.GetEntry("plugins/$pluginName").Open()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $zipHash = [BitConverter]::ToString($sha.ComputeHash($entryStream)).Replace('-', '') }
        finally { $entryStream.Dispose(); $sha.Dispose() }
        $builtHash = (Get-FileHash -LiteralPath (Join-Path $ProjectRoot "build/libs/$pluginName") -Algorithm SHA256).Hash
        if ($zipHash -ne $builtHash) { throw "ZIP contains an outdated plugin: $pluginName" }
    }
} finally { $check.Dispose() }
Move-Item -LiteralPath $stagedZip -Destination $destination -Force
Write-Host "Verified ZIP package: $destination ($($files.Count) files)"
