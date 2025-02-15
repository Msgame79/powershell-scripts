# force encoding to utf-8 without bom
chcp 65001

# default values
[string]$text = ""
[int]$hour = 0
[int]$minute = 0
[int]$second = 0
[int]$hours = 0
[int]$minutes = 0
[int]$seconds = 0
[int]$milliseconds = 0
[string]$hourtext = "0"
[string]$minutetext = "00"
[string]$secondtext = "00"
[string]$millisecondtext = "000"
[string]$hourstext = "0"
[string]$minutestext = "00"
[string]$secondstext = "00"
[string]$millisecondstext = "000"

# text formatting
function formatv2 {
    param (
        [Int64]$a,  # convert from
        [string]$b, # convert to
        [int]$c     # num of digits
    )
    $b = $a.ToString()
    $b = $b.PadLeft($c,'0')
    return $b
}

# main area
while ($true) {
    do {
        Clear-Host
        "Previous Input:${hourtext}:${minutetext}:${secondtext}.${millisecondtext}`n`nSum of inputs:${hourstext}:${minutestext}:${secondstext}.${millisecondstext}`n`nEnter Time`nor type r to reset`nor e to exit"
        $text = Read-Host
    } until ($text -match "^(((0?[1-9]|[1-9]\d*):)?(0?[1-9]|[1-5][0-9]):)?(0?\d|[1-5][0-9])(\.(\d{1,3}))?$|^(\d+)(\.(\d{1,3}))?$|^r$|^e$")
    if ($text -match "^(((0?[1-9]|[1-9]\d*):)?(0?[1-9]|[1-5][0-9]):)?(0?\d|[1-5][0-9])(\.(\d{1,3}))?$") {
        $hour = $Matches.3
        $minute = $Matches.4
        $second = $Matches.5
        $hourtext = formatv2 $hour $hourtext 1
        $minutetext = formatv2 $minute $minutetext 2
        $secondtext = formatv2 $second $secondtext 2
        $millisecondtext = "" + $Matches.7
    } elseif ($text -match "^(((0?[1-9]|[1-9]\d*):)?(0?[1-9]|[1-5][0-9]):)?(0?\d|[1-5][0-9])(\.(\d{1,3}))?$|^(\d+)(\.(\d{1,3}))?$") {
        $second = $Matches.8 % 60
        $minute = [math]::floor($matches.8 / 60)
        $hour = [math]::floor($matches.8 / 3600)
        $millisecondtext = "" + $Matches.10
    } elseif ($text -match "^r$") {
        [int]$hour = 0
        [int]$minute = 0
        [int]$second = 0
        [int]$hours = 0
        [int]$minutes = 0
        [int]$seconds = 0
        [int]$milliseconds = 0
        [string]$hourtext = "0"
        [string]$minutetext = "00"
        [string]$secondtext = "00"
        [string]$millisecondtext = "000"
        [string]$hourstext = "0"
        [string]$minutestext = "00"
        [string]$secondstext = "00"
        [string]$millisecondstext = "000"
    } elseif ($text -match "^e$") {
        exit
    }
    $millisecondtext = $millisecondtext.PadRight(3,'0')
    $milliseconds += $millisecondtext
    if ($milliseconds -ge 1000) {
        $seconds += 1
        $milliseconds -= 1000
    }
    $seconds += $second
    do {
        if ($seconds -ge 60) {
            $minutes += 1
            $seconds -= 60
        }
    } until ($seconds -lt 60)
    $minutes += $minute
    do {
        if ($minutes -ge 60) {
            $hours += 1
            $minutes -= 60
        }
    } until ($minutes -lt 60)
    $hours += $hour
    $hourstext = formatv2 $hours $hourstext 1
    $minutestext = formatv2 $minutes $minutestext 2
    $secondstext = formatv2 $seconds $secondstext 2
    $millisecondstext = "" + $milliseconds
    $millisecondstext = $millisecondstext.PadLeft(3,'0')
}