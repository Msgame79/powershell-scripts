$ErrorActionPreference = 'SilentlyContinue'

[string]$a=""
[int]$b=0
[decimal]$c=0

while(1)
{
    do
    {
        Clear-Host
        $a = Read-Host "Insert an positive integer"
    }
    until 
    (
        $a -match "^\d{0,6}[1-9]$"
    )
    $b=([int]$a)-1
    $c=0
    do
    {
        $c++
    } until
    (
        !(Compare-Object (Get-SecureRandom @(0..$b) -shuffle) @(0..$b) -syncwindow 0).Length
    )
    Clear-Host
    Write-Host "Length:$a`ncount:$c"
    Read-Host
}