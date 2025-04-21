[Int16]$counter = 0
[decimal]$total = 0
[decimal]$resets = 0
[Int16]$maximum = 0
[string]$mode = ""
[string]$command = "Get-$(if ($PSVersionTable.PSVersion.Major -ge 7) {"Secure"})Random -Minimum 0 -Maximum 100"

do {
    Clear-Host
    $mode = Read-Host -Prompt "Mode 1:Manual 2:Automatic"
} until ($mode -match "^[12]$")

while (1) {
    Clear-Host
    Write-Host -Object "Mode: ${mode}`nCounter: ${counter}`nMaximum count: ${maximum}`nTotal presses: ${total}`nNumber of resets: ${resets}"
    if (($command | Invoke-Expression) -ge $counter) {
        $counter++
        if ($counter -gt $maximum) {
            $maximum++
        }
    } else {
        $counter = 0
        $resets++
    }
    $total++
    if ($counter -eq 100) {
        Clear-Host
        Write-Host -Object "Mode: ${mode}`nCounter: ${counter}`nMaximum count: ${maximum}`nTotal presses: ${total}`nNumber of resets: ${resets}`n`nCongratas you reached 100`nIt is 9.33E-41% probabillity"
        while (1) {Read-Host}
    }
    if (2 - [int]$mode) {
        Read-Host
    }
}