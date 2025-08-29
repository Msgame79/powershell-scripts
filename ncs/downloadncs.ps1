#default values
[string]$defaultfolder = $PSScriptRoot
[System.Object]$downloadlength = $null
$ErrorActionPreference = 'SilentlyContinue'

if ($PSVersionTable.PSVersion.Major -lt 7) {
    "Run this script on PowerShell 7"
    Read-Host
    exit
}

Set-Location $defaultfolder
ffmpeg -version | Out-Null
if (-not $?) {
    "ffmpeg is unabailable`nenter to exit"
    Read-Host
    exit
}
if ($PSVersionTable.PSVersion.Major -lt 7) {
    "use PowerShell 7 or newer`nenter to exit"
    Read-Host
    exit
}
#force stat
if (Test-Path ".\musics") {
    do {
        Remove-Item -Recurse -Force ".\musics"
    } until (-not (Test-Path ".\musics"))
}
if (Test-Path ".\invalids") {
    do {
        Remove-Item -Recurse -Force ".\invalids"
    } until (-not (Test-Path ".\invalids"))
}
if (Test-Path ".\log.txt") {
    do {
        Remove-Item -Force ".\log.txt"
    } until (-not (Test-Path ".\log.txt"))
}
New-Item -ItemType Directory -Path ".\musics" | Out-Null
New-Item -ItemType Directory -Path ".\musics\temp" | Out-Null
New-Item -ItemType File -Path ".\log.txt" | Out-Null
Write-Host "Open log.txt on vscode to wacth log"
$downloadlength = Measure-Command -Expression {
    (Invoke-RestMethod -URI "https://raw.githubusercontent.com/Msgame79/powershell-scripts/refs/heads/main/ncs/uuids.txt").split("`n") | Foreach-Object -ThrottleLimit 10 -Parallel {
        [string]$title = ""
        [int]$hasnoname =  0
        [array]$logtext = @()
        $title = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes((Invoke-WebRequest -URI "https://ncs.io/track/download/${_}" -Method Head).Headers["Content-Disposition"]))
        if ($title.Length -eq 0) {
            $hasnoname = 1
        }
        $logtext += "UUID: ${_}"
        $logtext += "URL: https://ncs.io/track/download/${_}"
        if ($hasnoname) {
            $logtext += "Failed to get title"
            $logtext += "URL can be non-existent"
            $logtext += "Nothing downloaded"
        } else {
            
            $logtext += "Title: ${title}"
            Invoke-RestMethod -Uri "https://ncs.io/track/download/${_}" -OutFile ".\musics\temp\${_}.mp3"
            if (-not (Test-Path -Path ".\musics\temp\${_}.mp3")) {
                $logtext += "Failed to download"
                $logtext += "An error occurred while downloading"
            } elseif ((Get-ChildItem ".\musics\temp\${_}.mp3").Length -eq 0) {
                Remove-Item -Path ".\musics\temp\${_}.mp3"
                $logtext += "Loaded zero-byte file"
                $logtext += "This file may be non-existent on server"
                $logtext += "Already removed"
            } else {
                $logtext += "Downloaded successfully"
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\${_}.mp3" -map "0:0" -c copy -metadata title="${title}" ".\musics\${_}.mp3"
            }
            Invoke-RestMethod -Uri "https://ncs.io/track/download/i_${_}" -OutFile ".\musics\temp\i_${_}.mp3"
            if (-not (Test-Path -Path ".\musics\temp\i_${_}.mp3")) {
            } elseif ((Get-ChildItem ".\musics\temp\i_${_}.mp3").Length -eq 0) {
                $logtext += "URL: https://ncs.io/track/download/i_${_}"
                $logtext += "Title: ${title} (Instrumental)"
                Remove-Item -Path ".\musics\temp\i_${_}.mp3"
                $logtext += "Loaded zero-byte file"
                $logtext += "This file may be non-existent on server"
                $logtext += "Already deleted"
            } else {
                $logtext += "URL: https://ncs.io/track/download/i_${_}"
                $logtext += "Title: ${title} (Instrumental)"
                $logtext += "Downloaded successfully"
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\i_${_}.mp3" -map "0:0" -c copy -metadata title="${title} (Instrumental)" "2.\musics\i_${_}.mp3"
            }
        }
        $logtext += ""
        $logtext | Out-File -FilePath ".\log.txt" -Append
    }
}
"All files downloaded in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))" | Out-File -FilePath ".\log.txt" -Append
do {
    Remove-Item -Recurse -Force ".\musics\temp"
} until (-not (Test-Path ".\musics\temp"))
Get-ChildItem -Path ".\musics" | Where-Object {$_.Length -eq 0} | Remove-Item
Write-Host -Object "Done`nEnter to exit"
Read-Host
exit