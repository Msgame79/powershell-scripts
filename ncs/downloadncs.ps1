#default values
[string]$defaultfolder = $PSScriptRoot
[System.Object]$downloadlength = $null
[string]$title = ""
[int]$num = 0
[int]$count = 0
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
if (Test-Path ".\log.txt") {
    do {
        Remove-Item -Force ".\log.txt"
    } until (-not (Test-Path ".\log.txt"))
}
if (Test-Path ".\invalids.txt") {
    do {
        Remove-Item -Force ".\invalids.txt"
    } until (-not (Test-Path ".\invalids.txt"))
}
if ((Get-Content ".\uuids.txt" | Where-Object {$_ -notmatch "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"}).Count -gt 1) {
    "invalid UUID detected in uuids.txt`nenter to exit"
    Read-Host
    exit
}
if ((Get-Content ".\uuids.txt" | Sort-Object | Get-Unique).Count -lt (Get-Content ".\uuids.txt" | Sort-Object).Count) {
    "duplication detected in uuids.txt`nenter to exit"
    Read-Host
    exit
}
New-Item -ItemType Directory -Path ".\musics" | Out-Null
New-Item -ItemType Directory -Path ".\musics\temp" | Out-Null
New-Item -ItemType File -Path ".\log.txt" | Out-Null
New-Item -ItemType File -Path ".\invalids.txt" | Out-Null
Write-Host "Open log.txt in vscode to wacth log"
$downloadlength = Measure-Command -Expression {
    Get-Content .\uuids.txt | Foreach-Object -ThrottleLimit 10 -Parallel {
        [string]$title = ""
        [int]$isinvalidname =  0
        [int]$hasnoname =  0
        [int]$isfailed =  0
        [int]$iszerobyte =  0
        [array]$logtext = @()
        $title = [string]((Invoke-WebRequest -Uri "https://ncs.io/track/download/${_}" -Method Head).Headers["Content-Disposition"]).SubString(22,([string](Invoke-WebRequest -Uri "https://ncs.io/track/download/${_}" -Method Head).Headers["Content-Disposition"]).Length - 41)
        if ($title -match "[\u0080-\u00bf]") {
            $isinvalidname = 1
        } elseif ($title.Length -eq 0) {
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
            if ($isinvalidname) {
                $logtext += "Title contains invalid character(s)"
            }
            Invoke-RestMethod -Uri "https://ncs.io/track/download/${_}" -OutFile ".\musics\temp\${_}.mp3"
            if (-not $?) {
                $isfailed = 1
            } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\${_}.mp3" -Name "Length") -eq 0) {
                $iszerobyte =  1
            }
            if ($isfailed) {
                $logtext += "Failed to download"
                $logtext += "An error occurred while downloading"
            } elseif ($iszerobyte) {
                Remove-Item -Path ".\musics\temp\${_}.mp3"
                $logtext += "Loaded zero-byte file"
                $logtext += "This file may be non-existent on server"
                $logtext += "Already removed"
            } else {
                $logtext += "Downloaded successfully"
                if ($isinvalidname) {
                    "${_}" | Out-File -FilePath ".\invalids.txt" -Append
                    ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\${_}.mp3" -map "0:0" -c copy -metadata title="Invalid title ${_}" ".\${_}.mp3"
                } else {
                    ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\${_}.mp3" -map "0:0" -c copy -metadata title="${title}" ".\musics\${_}.mp3"
                }
            }
            $isfailed =  0
            $iszerobyte =  0
            Invoke-RestMethod -Uri "https://ncs.io/track/download/i_${_}" -OutFile ".\musics\temp\i_${_}.mp3"
            if (-not $?) {
                $isfailed = 1
            } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\i_${_}.mp3" -Name "Length") -eq 0) {
                $iszerobyte =  1
            }
            if ($isfailed) {
            } elseif ($iszerobyte) {
                $logtext += "UUID: ${_}"
                $logtext += "URL: https://ncs.io/track/download/i_${_}"
                $logtext += "Title: ${title} (Instrumental)"
                if ($isinvalidname) {
                    $logtext += "Title contains invalid character(s)"
                }
                Remove-Item -Path ".\musics\temp\i_${_}.mp3"
                $logtext += "Loaded zero-byte file"
                $logtext += "This file may be non-existent on server"
                $logtext += "Already deleted"
            } else {
                $logtext += "UUID: ${_}"
                $logtext += "URL: https://ncs.io/track/download/i_${_}"
                $logtext += "Title: ${title} (Instrumental)"
                if ($isinvalidname) {
                    $logtext += "Title contains invalid character(s)"
                }
                $logtext += "Downloaded successfully"
                if ($isinvalidname) {
                    "i_${_}" | Out-File -FilePath ".\invalids.txt" -Append
                    ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\i_${_}.mp3" -map "0:0" -c copy -metadata title="Invalid title ${_} (Instrumental)" ".\i_${_}.mp3"
                } else {
                    ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\i_${_}.mp3" -map "0:0" -c copy -metadata title="${title} (Instrumental)" ".\musics\i_${_}.mp3"
                }
            }
        }
        $logtext += ""
        $logtext | Out-File -FilePath ".\log.txt"
    }
}
Write-Host "All files downloaded in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))"
do {
    Remove-Item -Recurse -Force ".\musics\temp"
} until (-not (Tes-Path ".\musics\temp"))

# Download invlaids
$num = (Get-Content -Path ".\invalids.txt").Length
(Get-Content -Path ".\invalids.txt") | ForEach-Object {
    $count += 1
    Start-Process "https://ncs.io/track/download/${_}"
    do {
        Clear-Host
        "${count}/${num} ($([Math]::Round($count * 100 / $num), 2, 1)%)"
        "URL: https://ncs.io/track/download/${_}"
        $title = Read-Host -Prompt "Enter filename(Full) or skip"
    } until ($title -match "^[^ ].+\.mp3$|^skip$")
    if ($title -notmatch "^skip$") {
        $title = $title.Substring(0, $title.Length - 18)
        if ($_ -match "^i_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$") {
            ffmpeg -hide_banner -loglevel -8 -vn -i ".\${_}.mp3" -map "0:0" -c copy -metadata title="${title} (Instrumental)" ".\musics\${_}.mp3"
        } else {
            ffmpeg -hide_banner -loglevel -8 -vn -i ".\${_}.mp3" -map "0:0" -c copy -metadata title="${title}" ".\musics\${_}.mp3"
        }
    }
}
Read-Host
exit