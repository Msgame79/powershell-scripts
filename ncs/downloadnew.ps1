# default values
[string]$defaultfolder = "${PSScriptRoot}"
[string]$url = ""
[string]$uuid = ""
[string]$title = ""
[int]$isinvalidname =  0
[int]$hasnoname =  0
[int]$isfailed =  0
[int]$iszerobyte =  0

Set-Location -Path "${defaultfolder}"

if (-not (Test-Path ".\musics")) {
    """musics"" folder not found`nEnter to exit"
    exit
}
if (Test-Path ".\musics\temp") {
    do {
        Remove-Item -Recurse -Force ".\musics\temp"
    } until (-not (Test-Path ".\musics\temp"))
}
if (Test-Path ".\invalids") {
    do {
        Remove-Item -Recurse -Force ".\invalids"
    } until (-not (Test-Path ".\invalids"))
}
New-Item -ItemType Directory -Path ".\musics\temp" | Out-Null
New-Item -ItemType Directory -Path ".\invalids" | Out-Null
do {
    Clear-Host
    $url = Read-Host -Prompt "Enter URL or UUID"
} until ($url -match "^((https?://)?(www\.)?ncs\.io/track/download/)?(i_)?([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})$")
$uuid = $Matches.5
$title = [string]((Invoke-WebRequest -Uri "https://ncs.io/track/download/${uuid}" -Method Head).Headers["Content-Disposition"]).SubString(22,([string](Invoke-WebRequest -Uri "https://ncs.io/track/download/${uuid}" -Method Head).Headers["Content-Disposition"]).Length - 41)
if ($title -match "[\u0080-\u00bf]") {
    $isinvalidname = 1
} elseif ($title.Length -eq 0) {
    $hasnoname = 1
}
if ($hasnoname) {
    Write-Host -Object "Failed to get title`n maybe you typed wrong uuid?"
} else {
    if (Test-Path -Path ".\musics\${uuid}.mp3") {
        Write-Host -Object "${uuid}.mp3 already exists"
    } else {
        Write-Host -Object "Title: ${title}"
        if ($isinvalidname) {
            Write-Host -Object "Title contains invalid character(s)"
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/${uuid}" -OutFile ".\musics\temp\${uuid}.mp3"
        if (-not $?) {
            $isfailed = 1
        } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\${uuid}.mp3" -Name "Length") -eq 0) {
            $iszerobyte =  1
        }
        if ($isfailed) {
            Write-Host -Object "Failed to download`nAn error occurred while downloading"
        } elseif ($iszerobyte) {
            Remove-Item -Path ".\musics\temp\${uuid}.mp3"
            Write-Host -Object "Loaded zero-byte file`nThis file may be non-existent on server but returned with 20x`nAlready removed"
        } else {
            Write-Host -Object "Downloaded successfully"
            if ($isinvalidname) {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\${uuid}.mp3" -map "0:0" -c copy -metadata title="Invalid title ${uuid}" ".\invalids\${uuid}.mp3"
            } else {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\${uuid}.mp3" -map "0:0" -c copy -metadata title="${title}" ".\musics\${uuid}.mp3"
            }
        }
    }
    $isfailed =  0
    $iszerobyte =  0
    if (Test-Path -Path ".\musics\i_${uuid}.mp3") {
        Write-Host -Object "i_${uuid}.mp3 already exists"
    } else {
        Write-Host -Object "Title: ${title} (Instrumental)"
        if ($isinvalidname) {
            Write-Host -Object "Title contains invalid character(s)"
        }
        Invoke-RestMethod -Uri "https://ncs.io/track/download/i_${uuid}" -OutFile ".\musics\temp\i_${uuid}.mp3"
        if (-not $?) {
            $isfailed = 1
        } elseif ((Get-ItemPropertyValue -Path ".\musics\temp\i_${uuid}.mp3" -Name "Length") -eq 0) {
            $iszerobyte =  1
        }
        if ($isfailed) {
            Write-Host -Object "Failed to download`nAn error occurred while downloading"
        } elseif ($iszerobyte) {
            Remove-Item -Path ".\musics\temp\i_${uuid}.mp3"
            Write-Host -Object "Loaded zero-byte file`nThis file may be non-existent on server but returned with 20x`nAlready removed"
        } else {
            Write-Host -Object "Downloaded successfully"
            if ($isinvalidname) {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\i_${uuid}.mp3" -map "0:0" -c copy -metadata title="Invalid title ${uuid} (Instrumental)" ".\invalids\i_${uuid}.mp3"
            } else {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\musics\temp\i_${uuid}.mp3" -map "0:0" -c copy -metadata title="${title} (Instrumental)" ".\musics\i_${uuid}.mp3"
            }
        }
    }
    if ($isinvalidname) {
        Get-ChildItem -Name -Path ".\invalids" | Where-Object {$_ -match "^(i_)?[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.mp3$"} | ForEach-Object {
            do {
                Clear-Host
                "URL: https://ncs.io/track/download/$($_.SubString(0, ($_.Length - 4)))"
                $title = Read-Host -Prompt "Enter filename(Full) or skip"
            } until ($title -match "^[^ ].+\.mp3$|^skip$")
        }
        if ($title -notmatch "^skip$") {
            $title = $title.Substring(0, $title.Length - 18)
            if ($_ -match "^i_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$") {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\invalids\${_}" -map "0:0" -c copy -metadata title="${title} (Instrumental)" ".\musics\${_}"
            } else {
                ffmpeg -hide_banner -loglevel -8 -vn -i ".\invalids\${_}" -map "0:0" -c copy -metadata title="${title}" ".\musics\${_}"
            }
        }
    }
}
do {
    Remove-Item -Recurse -Force ".\musics\temp"
} until (-not (Tes-Path ".\musics\temp"))
if (Test-Path ".\invalids") {
    do {
        Remove-Item -Recurse -Force ".\invalids"
    } until (-not (Test-Path ".\invalids"))
}
Write-Host -Object "Enter to exit"
Read-Host
exit