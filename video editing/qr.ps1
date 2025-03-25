chcp 65001

[string]$directory = $PSScriptRoot
[string]$size = ""
[string]$pad = ""
[string]$text = ""
[string]$confirm = ""
[string]$guid = (New-Guid).Guid
[int]$ffplay = 0
[int]$minimum = 80 # can edit
[int]$maximum = 540 # can edit

Set-Location $directory
do {
    Clear-Host
    do {
        do {
            $size = Read-Host -Prompt "size between ${minimum} and ${maximum}"
        } until ($size -match "^\d+$")
    }until ([int]$size -ge $minimum -and [int]$size -le $maximum)
    do {
        do {
            $pad = Read-Host -Prompt "pad size(even)"
        } until ($pad -match "^\d+$")
    } while (([int]$pad) % 2)
    do {
        $text = Read-Host -Prompt "text"
    } until ($text -notmatch "^ *$")

    $colors = (ffmpeg -hide_banner -colors)[1..(ffmpeg -hide_banner -colors).Count] | ForEach-Object {$_.SubString(0,$_.Length - 7).Trim()}
    do {
        $bg = Read-Host -Prompt "background color"
    } until ($bg -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $bg -in $colors)
    do {
        $fg = Read-Host -Prompt "foreground color"
    } until ($fg -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $fg -in $colors)
    $text = $text -replace '([%,.:;{}])', '\$1'
    $text = $text -replace '(\\%|\\:)', '\\$1'
    if ($text -match "\\$") {$text = "${text}\\"}
    $ffplay = (Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel -8 -f lavfi -i ""color=c=00000000:r=1:s=$([int]$size + [int]$pad)x$([int]$size + [int]$pad),qrencode=Q=$([int]$size + [int]$pad):bc=${bg}:fc=${fg}:q=${size}:text='${text}'""" -NoNewWindow -PassThru).Id
    do {
        $confirm = Read-Host -Prompt "save this to ${guid}.png?"
    } until ($confirm -match "^[yn]$")
    Stop-Process -Id $ffplay
} until ($confirm -match "^y$")
ffmpeg -hide_banner -loglevel -8 -f lavfi -i "color=c=00000000:r=1:s=$([int]$size + [int]$pad)x$([int]$size + [int]$pad),qrencode=Q=$([int]$size + [int]$pad):bc=${bg}:fc=${fg}:q=${size}:text='${text}'" -c:v png -frames:v 1 "${guid}.png"