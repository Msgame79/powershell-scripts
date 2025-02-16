chcp 65001 # UTF-8 Without BOM
Set-Location $PSScriptRoot
$ErrorActionPreference = 'SilentlyContinue'

# `^ +`を空の文字列に置換して行頭の空白を削除

#default values
[bool]$issucceeded = $true

ffmpeg -version | Out-Null
if (-not $?) {
    "ffmpeg is unabailable`nenter to exit"
    Read-Host
    exit
}
if ($PSVersionTable.PSVersion.Major -le 5) {
    "use PowerShell Core(6 or later)`nenter to exit"
    Read-Host
    exit
}
#force stat
if (Test-Path .\musics) {
    do {
        Remove-Item -Recurse -Force .\musics
    } until ($?)
}
if (Test-Path .\log.text) {
    do {
        Remove-Item -Force .\log.text
    } until ($?)
}
New-Item -ItemType Directory -Path .\musics
New-Item -ItemType Directory -Path .\musics\temp
Clear-Host
if (-not (Test-Path .\uuids.txt)) {
    "uuids.txt does not exist`nenter to exit"
    Read-Host
    exit
}
if ((Get-Content .\uuids.txt | Sort-Object | Get-Unique).Count -lt (Get-Content .\uuids.txt | Sort-Object).Count) {
    "duplication detected in uuids.txt`nenter to exit"
    Read-Host
    exit
}

#main area
Get-Content .\uuids.txt | Foreach-Object -ThrottleLimit 10 -Parallel {
    [string]$contentdisposition = ""
    [string]$title = ""
    [string]$loghost = ""
    [string]$logtext = ""
    $contentdisposition = (Invoke-WebRequest -Uri "https://ncs.io/track/download/$_" -Method Head).Headers["Content-Disposition"]
    $title = $contentdisposition.SubString(22,$contentdisposition.Length - 41)
    if ($title -match "[\u0080-\u009f\u00a9]") {
        $loghost += "Title: $title`nwarning: title may contain invalid letter downloading from browser recommended`n"
        $logtext += "Title: $title`nwarning: title may contain invalid letter downloading from browser recommended`n"
    } else {
        $loghost += "Title: $title`n"
        $logtext += "Title: $title`n"
    }
    $loghost += "URL: https://ncs.io/track/download/$_`n"
    $logtext += "URL: https://ncs.io/track/download/$_`n"
    Invoke-RestMethod -Uri "https://ncs.io/track/download/$_" -OutFile ".\musics\temp\$_.mp3" | Out-Null
    if (-not (Test-Path ".\musics\temp\$_.mp3")) {
        $loghost += "Stat: Failed`n"
        $logtext += "Stat: Failed`n"
    } else {
        if (((get-itemproperty ".\musics\temp\$_.mp3").Length) -eq 0) {
            $issucceeded = $false
            do {
                Remove-Item ".\musics\temp\$_.mp3" -Force
            } until ($?)
        } else {
            $issucceeded = $true
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/i_$_" -OutFile ".\musics\temp\i_$_.mp3" | Out-Null
        if (-not (Test-Path ".\musics\temp\i_$_.mp3")) {
            $loghost += "Stat: Succeeded`nInstrumental does not exist`n"
        } else {
            if ($issucceeded) {
                $loghost += "Stat: Succeeded`n`n"
                $logtext += "Stat: Succeeded`n`n"
            } else {
                $loghost += "Stat: Failed`n`n"
                $logtext += "Stat: Failed`n`n"
            }
            if ($title -match "[\u0080-\u009f\u00a9]") {
                $loghost += "Title: $title (Instrumental)`nwarning: title may contain invalid letter downloading from browser recommended`n"
                $logtext += "Title: $title (Instrumental)`nwarning: title may contain invalid letter downloading from browser recommended`n"
            } else {
                $loghost += "Title: $title (Instrumental)`n"
                $logtext += "Title: $title (Instrumental)`n"
            }
            $loghost += "URL: https://ncs.io/track/download/i_$_`n"
            $logtext += "URL: https://ncs.io/track/download/i_$_`n"
            if (((get-itemproperty ".\musics\temp\$_.mp3").Length) -eq 0) {
                $issucceeded = $false
            } else {
                $issucceeded = $true
                ffmpeg -loglevel -8 -vn -i ".\musics\temp\i_$_.mp3" -c copy -metadata title="$title (Instrumental)" ".\musics\i_$_.mp3"
            }
            do {
                Remove-Item ".\musics\temp\i_$_.mp3" -Force
            } until ($?)
            if ($issucceeded) {
                $loghost += "Stat: Succeeded`n`n"
                $logtext += "Stat: Succeeded`n`n"
            } else {
                $loghost += "Stat: Failed`n`n"
                $logtext += "Stat: Failed`n`n"
            }
        }
        ffmpeg -loglevel -8 -vn -i ".\musics\temp\$_.mp3" -c copy -metadata title="$title" ".\musics\$_.mp3"
        do {
            Remove-Item ".\musics\temp\$_.mp3" -Force
        } until ($?)
    }
    $loghost
    do {
        $logtext | Out-File log.text -Append -Encoding utf8NoBOM
    } until ($?)
}
do {
    Remove-Item -Recurse -Force .\musics\temp
} until ($?)
"done"
Read-Host