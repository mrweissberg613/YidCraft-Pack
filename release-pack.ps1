# ============================
# YidCraft Resource Pack Release
# ============================

# Load private config
if (!(Test-Path ".\config.ps1")) {
    Write-Host "ERROR: config.ps1 missing!"
    exit
}

. .\config.ps1


# Settings
$Repo = "mrweissberg613/YidCraft-Pack"
$Version = "v1.0"
$PackName = "YidCraft-Pack.zip"


Write-Host "Creating resource pack ZIP..."


# Delete old zip
if (Test-Path $PackName) {
    Remove-Item $PackName
}


# Create zip
Compress-Archive `
    -Path pack.mcmeta,pack.png,assets `
    -DestinationPath $PackName


Write-Host "ZIP created!"


# Generate SHA1

Write-Host "Generating SHA1..."

$SHA1 = (Get-FileHash $PackName -Algorithm SHA1).Hash.ToLower()

Write-Host "SHA1:"
Write-Host $SHA1



# Git update

Write-Host "Saving Git changes..."

git add .

git commit -m "Release $Version"

git push



# GitHub headers

$Headers = @{
    Authorization = "Bearer $GitHubToken"
    Accept = "application/vnd.github+json"
}



# Create release

Write-Host "Creating GitHub release..."


$Body = @{
    tag_name = $Version
    name = "YidCraft Resource Pack $Version"
    body = "Automatic resource pack release"
} | ConvertTo-Json



$Release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Repo/releases" `
    -Method POST `
    -Headers $Headers `
    -Body $Body `
    -ContentType "application/json"



# Upload ZIP

Write-Host "Uploading ZIP..."


$UploadURL = $Release.upload_url -replace "\{.*",""


Invoke-RestMethod `
    -Uri "$UploadURL?name=$PackName" `
    -Method POST `
    -Headers $Headers `
    -ContentType "application/zip" `
    -InFile $PackName



# Output information

$Download = "https://github.com/$Repo/releases/download/$Version/$PackName"


Write-Host ""
Write-Host "============================"
Write-Host " RELEASE COMPLETE "
Write-Host "============================"
Write-Host ""
Write-Host "Download URL:"
Write-Host $Download
Write-Host ""
Write-Host "SHA1:"
Write-Host $SHA1
Write-Host ""