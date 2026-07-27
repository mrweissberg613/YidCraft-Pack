# ============================
# YidCraft Resource Pack Release
# ============================

# Load token
if (!(Test-Path ".\config.ps1")) {
    Write-Host "ERROR: config.ps1 missing!"
    exit
}

. .\config.ps1


# Ask release information

$Version = Read-Host "Enter release version (example: v1.1)"

$ReleaseTitle = Read-Host "Enter release title"

$Description = Read-Host "Enter a brief description of this update"


$Repo = "mrweissberg613/YidCraft-Pack"
$ZipName = "YidCraft-Pack.zip"



Write-Host ""
Write-Host "Creating ZIP..."

if (Test-Path $ZipName) {
    Remove-Item $ZipName
}


Compress-Archive `
    -Path pack.mcmeta,pack.png,assets `
    -DestinationPath $ZipName


Write-Host "ZIP created!"



# SHA1

Write-Host "Generating SHA1..."

$SHA1 = (Get-FileHash $ZipName -Algorithm SHA1).Hash.ToLower()

Write-Host "SHA1:"
Write-Host $SHA1



# Git

Write-Host ""
Write-Host "Updating GitHub repository..."

git add .

git commit -m "Release $Version - $ReleaseTitle"

git push



# Headers

$Headers = @{
    Authorization = "Bearer $GitHubToken"
    Accept = "application/vnd.github+json"
}



# Create release

Write-Host ""
Write-Host "Creating GitHub release..."


$ReleaseData = @{
    tag_name = $Version
    name = $ReleaseTitle
    body = $Description
    draft = $false
    prerelease = $false
} | ConvertTo-Json



$Release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Repo/releases" `
    -Method POST `
    -Headers $Headers `
    -Body $ReleaseData `
    -ContentType "application/json"



# Upload ZIP

Write-Host "Uploading ZIP..."

$UploadURL = $Release.upload_url -replace '\{\?.*\}', ''
$UploadUri = $UploadURL + '?name=' + [uri]::EscapeDataString($ZipName)

try {
    $Asset = Invoke-RestMethod `
        -Uri $UploadUri `
        -Method POST `
        -Headers $Headers `
        -ContentType "application/zip" `
        -InFile $ZipName

    $DownloadURL = $Asset.browser_download_url
}
catch {
    Write-Host "Asset upload failed: $($_.Exception.Message)"
    $DownloadURL = "https://github.com/$Repo/releases/download/$Version/$ZipName"
}


# Output

if ([string]::IsNullOrWhiteSpace($DownloadURL)) {
    $DownloadURL = "https://github.com/$Repo/releases/latest/download/$ZipName"
}


Write-Host ""
Write-Host "=============================="
Write-Host " RELEASE COMPLETE "
Write-Host "=============================="
Write-Host ""

Write-Host "Download URL:"
Write-Host $DownloadURL

Write-Host ""
Write-Host "Minecraft server URL:"
Write-Host "resource-pack=$DownloadURL"

Write-Host ""

Write-Host "SHA1:"
Write-Host $SHA1

Write-Host ""