chcp 65001
Clear-Host
"Table of Files in current directory"
""
Get-ChildItem -Name | Where-Object {$_ -match "^.*\.mp4$|^.*\.mov$|^.*\.mkv$"}
""
Do {
    "choose input"
    $in=Read-Host
} Until (Test-Path $in)
$ext = [System.IO.Path]::GetExtension($in).TrimStart('.')
$fps=ffprobe -hide_banner -i "$in" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=r_frame_rate"
$fps=pwsh -c $fps
[int]$width=ffprobe -hide_banner -i "$in" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=width"
if ($width -lt 500) {
    $width=500
}
[int]$height=ffprobe -hide_banner -i "$in" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=height"
$height=$height+165
$pad="w=$width"+":h=$height"+":x=0:y=165"
ffplay -hide_banner -fs -i "$in" -vf "pad=$pad,drawtext=fontsize=70:fontcolor=white:fontfile=c\\:/windows/fonts/cour.ttf:text='%{eif\:mod(mod(floor(t/3600),60),24)\:u\:2}\:%{eif\:mod(floor(t/60),60)\:u\:2}\:%{eif\:mod(floor(t),60)\:u\:2}.%{eif\:floor(mod(n/$fps,1)*1000)\:u\:3}',drawtext=y=55:fontsize=70:fontcolor=white:fontfile=c\\:/windows/fonts/cour.ttf:text='%{eif\:floor(t)\:u\:8}.%{eif\:floor(mod(n/$fps,1)*1000)\:u\:3}',drawtext=y=110:fontsize=70:fontcolor=white:fontfile=c\\:/windows/fonts/cour.ttf:text='%{pict_type}'"
Clear-Host
Do {
    "starts at (enter nothing to set beginning)"
    $ss=Read-Host
} Until ($ss -match "^[1-9]?[0-9]+(\.[0-9]+)?$|^[0-5][0-9]:[0-5]?[0-9](\.[0-9]+)?$|^[0-5]?[0-9]:[0-5]?[0-9]:[0-5]?[0-9](\.[0-9]+)?$|^$")
if ($ss -match "^[1-9]?[0-9]+(\.[0-9]+)?$|^[0-5][0-9]:[0-5]?[0-9](\.[0-9]+)?$|^[0-5]?[0-9]:[0-5]?[0-9]:[0-5]?[0-9](\.[0-9]+)?$") {
    $ss="-ss $ss"
} else {
    $ss=""
}
Do {
    "ends at (enter nothing to set ending)"
    $to=Read-Host
} Until ($to -match "^[1-9]?[0-9]+(\.[0-9]+)?$|^[0-5][0-9]:[0-5]?[0-9](\.[0-9]+)?$|^[0-5]?[0-9]:[0-5]?[0-9]:[0-5]?[0-9](\.[0-9]+)?$|^$")
if ($to -match "^[1-9]?[0-9]+(\.[0-9]+)?$|^[0-5][0-9]:[0-5]?[0-9](\.[0-9]+)?$|^[0-5]?[0-9]:[0-5]?[0-9]:[0-5]?[0-9](\.[0-9]+)?$") {
    $to="-to $to"
} else {
    $to=""
}
Do {
    $flag=$true
    "output filename without extension"
    $out=Read-Host
    if ($out -match "^.*[/:\*\?<>\|""].*$") {
        $flag=$false
    }
    if (Test-Path ".\$out.$ext") {
        Do {
            "overwrite?(y/n)"
            $ow=Read-Host
        } Until ($ow -match "^[yYnN]$")
        if ($ow -match "^[nN]$") {
            $flag=$false
        } else {
        }
    }
} Until ($flag)
Do {
    "1: copy   2: recode"
    $coding=Read-Host
} Until ($coding -match "^[12]$")
if ($coding -eq 1) {
    ffmpeg -hide_banner -y $ss $to -i "$in" -c copy "$out.$ext"
} else {
    ffmpeg -hide_banner -y $ss $to -i "$in" -c:v h264_nvenc -b:v 0 -qmax 18 -qmin 18 -pix_fmt yuv420p "$out.$ext"
}
Read-Host