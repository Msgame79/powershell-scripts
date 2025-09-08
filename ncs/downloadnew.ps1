#default values
[string]$defaultfolder = $PSScriptRoot
$ErrorActionPreference = 'SilentlyContinue'

Set-Location $defaultfolder
ffmpeg -version | Out-Null
if (-not $?) {
    "ffmpeg is unabailable`nenter to exit"
    Read-Host
    exit
}

if (-not (Test-Path ".\musics"))
{
    "musics not found`nrun downloadncs.ps1 first`nEnter to exit"
    Read-Host
    exit
}

if ((Test-Path ".\musics\temp"))
{
    if ((Get-ChildItem ".\musics\temp").Count)
    {
        Write-Host "Waiting for other process..."
        do
        {
        } until (-not (Test-Path ".\musics\temp"))
    }
}
while (Test-Path ".\musics\temp")
{
    Remove-Item -Recurse -Force ".\musics\temp"
}

while(1)
{
    New-Item -ItemType Directory -Path ".\musics\temp" | Out-Null
    do
    {
        Clear-Host
        $uuid = Read-Host "Enter URL or UUID"
    } until ($uuid -cmatch "^(https://(www\.)?ncs\.io/track/download/)?([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})$")
    $uuid = $Matches.3
    Write-Host "UUID: ${uuid}"
    $title = ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes((Invoke-WebRequest -URI "https://ncs.io/track/download/${uuid}" -Method Head).Headers["Content-Disposition"]))).SubString(22, ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes((Invoke-WebRequest -URI "https://ncs.io/track/download/${uuid}" -Method Head).Headers["Content-Disposition"]))).Length - 41)
    if ($title.Length -eq 0)
    {
        Write-Host "Failed to load title"
    } else 
    {
        Write-Host "Title: ${title}"
    }
    if (Test-Path ".\musics\${uuid}.mp3")
    {
        Write-Host "Already exists"
    } else
    {
        Invoke-RestMethod -Uri "https://ncs.io/track/download/${uuid}" -OutFile ".\musics\temp\${uuid}.mp3"
        if (-not (Test-Path -Path ".\musics\temp\${uuid}.mp3"))
        {
            Write-Host "Failed to download`nAn error occurred while downloading"
        } elseif ((Get-ChildItem ".\musics\temp\${uuid}.mp3").Length -eq 0)
        {
            Remove-Item -Path ".\musics\temp\${uuid}.mp3`nLoaded zero-byte file`nThis file may be non-existent on server`nAlready removed"
        } else
        {
            Start-Process "ffmpeg" "-hide_banner -loglevel -8 -vn -i "".\musics\temp\${_}.mp3"" -map ""0:0"" -c copy -metadata title=""${title}"" "".\musics\${_}.mp3""" -NoNewWindow -Wait
            Write-Host "Downloaded successfully"
            Write-Host "URL: https://ncs.io/track/download/i_${uuid}"
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/i_${uuid}" -OutFile ".\musics\temp\i_${uuid}.mp3"
        if (-not (Test-Path -Path ".\musics\temp\i_${uuid}.mp3"))
        {
            Write-Host "Failed to download`nAn error occurred while downloading"
        } elseif ((Get-ChildItem ".\musics\temp\i_${uuid}.mp3").Length -eq 0)
        {
            Remove-Item -Path ".\musics\temp\i_${uuid}.mp3`nLoaded zero-byte file`nThis file may be non-existent on server`nAlready removed"
        } else
        {
            Start-Process "ffmpeg" "-hide_banner -loglevel -8 -vn -i "".\musics\temp\${_}.mp3"" -map ""0:0"" -c copy -metadata title=""${title} (Instrumental)"" "".\musics\i_${_}.mp3""" -NoNewWindow -Wait
            Write-Host "Title: ${title} (Instrumental)`nURL: https://ncs.io/track/download/i_${uuid}`nDownloaded successfully"
        }   
    }
    do
    {
        Remove-Item -Recurse -Force ".\musics\temp"
    } until (-not (Test-Path ".\musics\temp"))
    Write-Host -Object "Done`nEnter to restart"
    Read-Host
}