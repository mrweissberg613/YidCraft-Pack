# ============================
# YidCraft Resource Pack Release
# ============================

# Load token
if (!(Test-Path ".\config.ps1")) {
    Write-Host "ERROR: config.ps1 missing!"
    exit
}

. .\config.ps1


# Settings
$Repo = "mrweissberg613/YidCraft-Pack"
$Version = "v1.0"
$ZipName = "YidCraft-Pack.zip"


Write-Host "Creating ZIP..."


if (Test-Path $ZipName) {
    Remove-Item $ZipName
}


Compress-Archive `
    -Path pack.mcmeta,pack.png,assets `
    -DestinationPath $ZipName


Write-Host "ZIP created"


# SHA1

$SHA1 = (Get-FileHash $ZipName -Algorithm SHA1).Hash.ToLower()

Write-Host "SHA1:"
Write-Host $SHA1



# Git

Write-Host "Pushing Git changes..."

git add .
git commit -m "Release $Version"
git push



# Headers

$Headers = @{
    Authorization = "Bearer $GitHubToken"
    Accept = "application/vnd.github+json"
}



# Create release

Write-Host "Creating GitHub release..."


$ReleaseBody = @{
    tag_name = $Version
    target_commitish = "main"
    name = "YidCraft Resource Pack $Version"
    body = "Automatic resource pack release"
    draft = $false
    prerelease = $false
} | ConvertTo-Json


$Release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Repo/releases" `
    -Method POST `
    -Headers $Headers `
    -Body $ReleaseBody `
    -ContentType "application/json"



# Upload ZIP asset

Write-Host "Uploading ZIP asset..."


$UploadURL = $Release.upload_url.Replace("{?name,label}", "")


Invoke-RestMethod `
    -Uri "$UploadURL?name=$ZipName" `
    -Method POST `
    -Headers $Headers `
    -ContentType "application/zip" `
    -InFile $ZipName



# Output

$DownloadURL = "https://github.com/$Repo/releases/download/$Version/$ZipName"


Write-Host ""
Write-Host "=========================="
Write-Host " RELEASE FINISHED "
Write-Host "=========================="
Write-Host ""
Write-Host "Minecraft Download URL:"
Write-Host $DownloadURL
Write-Host ""
Write-Host "SHA1:"
Write-Host $SHA1