chcp 65001

set-location $PSScriptRoot

[array]$files = @()
[string]$result = ""
[int]$counter = 0
[int]$counter1 = 1
[string]$file = ""
[bool]$flag = $true
[bool]$flag1 = $false
[string]$prefix = "re_"

# check if ffmpeg and ffprobe are available
ffprobe -version | Out-Null
if (-not $?) {
    "ffprobe is unabailable`nenter to exit"
    Read-Host
    exit
}
ffmpeg -version | Out-Null
if (-not $?) {
    "ffmpeg is unabailable`nenter to exit"
    Read-Host
    exit
}

$files = get-childitem -name | Where-Object {$_ -match ".*\.(mp4|mkv|mov|webm)"}
$files | ForEach-Object {
    $result = ffprobe -hide_banner -loglevel 16 -of "default=nw=1:nk=1" -select_streams v:0 -show_entries "stream=codec_name" $_
    $file = $files[$counter]
    if (-not $result -match "^h264$|^$") {
        "detected`n$file"
        if (Test-Path "$prefix$file") {
            do {
                $counter1 += 1
                $prefix += "$counter1"
                $flag1 = Test-Path "$prefix$file"
            } until (-not $flag1)
        }
        ffmpeg -loglevel -8 -i $file -c:v h264_nvenc -qmax 18 -qmin 18 -c:a copy "$prefix$file"
        if ($?) {
            do {
                try {
                    $flag = $true
                    Remove-Item $file
                    Rename-Item -Path "$prefix$file" -NewName "$file"
                } catch {
                    $flag = $false
                }                
            } until ($flag)
            "$file saved successfully"
        } else {
            "an error occured when saving $file"
        }
        ""
    } elseif ($result -match "^$") {
        "$file does not contain video stream"
    } else {
        "$file is encoded by h264"
    }
    ""
    $counter += 1
    $counter1 = 1
    $prefix = "re_"
}
"done`nenter to finish"
Read-Host