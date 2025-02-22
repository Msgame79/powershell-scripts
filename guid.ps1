chcp 65001
# GUIDの衝突実験
[array]$array=@()
[string]$current=""
[int]$isduplicated = 0
[string]$ordinal = ""
[string]$textfile = ".\guids.txt"

if ($PSVersionTable.PSVersion.Major -le 5) {
    "Run this script on PowerShell 7"
    Read-Host
    exit
}
if (Test-Path $textfile) {
    do {
        Remove-Item $textfile
    } until (-not (Test-Path $textfile))
}
$current = (New-Guid).Guid
$array += $current
do {
    Clear-Host
    "" + $array.Count + "${ordinal} GUID"
    "${current}"
    $current | Out-File $textfile -append
    $current = (New-Guid).Guid
    if ($current -in $array) {
        $isduplicated = 1
    }
    $array += $current
    if ($array.Count -le 10 -or $array.Count -ge 20) {
        switch ($array.Count % 10) {
            1 {$ordinal = "st"}
            2 {$ordinal = "nd"}
            3 {$ordinal = "rd"}
            Default {$ordinal = "th"}
        }
    } else {
        $ordinal = "th"
    }
} until ($isduplicated)
"${current} is duplicated for the " + $array.Count + "${ordinal} GUID"
Read-Host