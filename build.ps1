$zipName = "yidcraft.zip"
$archiveDir = "archive"

if (!(Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
}

if (Test-Path $zipName) {
    $version = 1
    while (Test-Path "$archiveDir\YidCraft v$version.zip") {
        $version++
    }

    Move-Item $zipName "$archiveDir\YidCraft v$version.zip"
}

Compress-Archive `
    -Path assets, pack.mcmeta, pack.png `
    -DestinationPath $zipName `
    -CompressionLevel Optimal

Write-Host ""
Write-Host "==============================="
Write-Host " Resource pack built!"
Write-Host " Output: $zipName"
Write-Host "==============================="