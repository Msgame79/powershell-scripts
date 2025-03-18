chcp 65001

#default values
[string]$defaultfolder = $PSScriptRoot
[System.Object]$downloadlength = $null
$ErrorActionPreference = 'SilentlyContinue'

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
Write-Host "Open log.txt in vscode to wacth log"
$downloadlength = Measure-Command -Expression {
    Get-Content .\uuids.txt | Foreach-Object -ThrottleLimit 10 -Parallel {
        [string]$title = ""
        [int]$isinvalidname =  0
        [int]$hasnoname =  0
        [int]$isfailed =  0
        [int]$iszerobyte =  0
        [int]$isfailedinst =  0
        [int]$iszerobyteinst =  0
        $title = [string]((Invoke-WebRequest -Uri "https://ncs.io/track/download/${_}" -Method Head).Headers["Content-Disposition"]).SubString(22,([string](Invoke-WebRequest -Uri "https://ncs.io/track/download/${_}" -Method Head).Headers["Content-Disposition"]).Length - 41)
        if ($title -match "[\u0080-\u00bf]") {
            $isinvalidname = 1
        } elseif ($title -match "^$") {
            $hasnoname = 1
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/${_}" -OutFile ".\musics\temp\${_}.mp3"
        if (-not $?) {
            $isfailed = 1
        } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\${_}.mp3" -Name "Length") -eq 0) {
            $iszerobyte =  1
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/i_${_}" -OutFile ".\musics\temp\i_${_}.mp3"
        if (-not $?) {
            $isfailedinst = 1
        } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\i_${_}.mp3" -Name "Length") -eq 0) {
            $iszerobyteinst =  1
        }
    }
}
Write-Host "All files downloaded in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))"