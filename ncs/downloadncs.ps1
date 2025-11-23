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
while (Test-Path ".\musics")
{
    Remove-Item -Recurse -Force ".\musics"
} 
while (Test-Path ".\invalids")
{
    Remove-Item -Recurse -Force ".\invalids"
}
while (Test-Path ".\log.txt")
{
    Remove-Item -Force ".\log.txt"
}
New-Item -ItemType Directory -Path ".\musics" | Out-Null
New-Item -ItemType Directory -Path ".\musics\temp" | Out-Null
New-Item -ItemType File -Path ".\log.txt" | Out-Null
Write-Host "Open log.txt on vscode to wacth log"
Invoke-RestMethod "https://github.com/rockdaboot/wget2/releases/latest/download/wget2.exe" -OutFile ".\wget2.exe"
(Invoke-RestMethod "https://raw.githubusercontent.com/Msgame79/powershell-scripts/refs/heads/main/ncs/uuids.txt").split("`n") | ForEach-Object {"https://ncs.io/track/download/$_"} | Out-File "urls.txt"
Set-Location .\musics\temp
wget2.exe --max-threads (Get-ComputerInfo).CsNumberOfLogicalProcessors -i ..\..\urls.txt
Get-ChildItem -Name | Foreach-Object -ThrottleLimit (Get-ComputerInfo).CsNumberOfLogicalProcessors -Parallel {
  $uuid = [Regex]::Matches($_,"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")[0].Value
  $artist = 
}
"All files downloaded in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))" | Out-File -FilePath ".\log.txt" -Append
while (Test-Path ".\musics\temp")
{
    Remove-Item -Recurse -Force ".\musics\temp"
}
Get-ChildItem -Path ".\musics" | Where-Object {$_.Length -eq 0} | Remove-Item
"All files downloaded in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))"
Write-Host -Object "Done`nEnter to exit"
Read-Host
exit