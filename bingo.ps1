chcp 65001

[array]$row1 = @()
[array]$row2 = @()
[array]$row3 = @()
[array]$row4 = @()
[array]$row5 = @()
[string]$col1 = ""
[string]$col2 = ""
[string]$col3 = ""
[string]$col4 = ""
[string]$col5 = ""
[string]$sheet = ""
[array]$numbers = @()
[int]$bingos = 0

if ($PSVersionTable.PSVersion.Major -lt 6) {
    "run this script on powershell 6 or newer"
    Read-Host
    exit
}

while (1) {
    $row1 = 1..15 | Get-SecureRandom -Count 5 | ForEach-Object {($_.ToString()).PadLeft(2,' ')}
    $row2 = 16..30 | Get-SecureRandom -Count 5 | ForEach-Object {$_.ToString()}
    $row3 = 31..45 | Get-SecureRandom -Count 4 | ForEach-Object {$_.ToString()}
    $row3 = @($row3[0], $row3[1], "  ", $row3[2], $row3[3])
    $row4 = 46..60 | Get-SecureRandom -Count 5 | ForEach-Object {$_.ToString()}
    $row5 = 61..75 | Get-SecureRandom -Count 5 | ForEach-Object {$_.ToString()}
    $col1 = "│" + $row1[0] + "│" + $row2[0] + "│" + $row3[0] + "│" + $row4[0] +"│" + $row5[0] + "│"
    $col2 = "│" + $row1[1] + "│" + $row2[1] + "│" + $row3[1] + "│" + $row4[1] +"│" + $row5[1] + "│"
    $col3 = "│" + $row1[2] + "│" + $row2[2] + "│" + $row3[2] + "│" + $row4[2] +"│" + $row5[2] + "│"
    $col4 = "│" + $row1[3] + "│" + $row2[3] + "│" + $row3[3] + "│" + $row4[3] +"│" + $row5[3] + "│"
    $col5 = "│" + $row1[4] + "│" + $row2[4] + "│" + $row3[4] + "│" + $row4[4] +"│" + $row5[4] + "│"
    Clear-Host
    $sheet = "┌──┬──┬──┬──┬──┐`n$col1`n├──┼──┼──┼──┼──┤`n$col2`n├──┼──┼──┼──┼──┤`n$col3`n├──┼──┼──┼──┼──┤`n$col4`n├──┼──┼──┼──┼──┤`n$col5`n└──┴──┴──┴──┴──┘"
    $numbers = 1..75 | Get-SecureRandom -Shuffle | ForEach-Object {($_.ToString()).PadLeft(2,' ')}
    $sheet
    "Enter to show numbers"
    Read-Host
    0..74 | ForEach-Object {
        Clear-Host
        switch ($numbers[$_]) {
            $row1[0] {$row1[0] = "  "}
            $row1[1] {$row1[1] = "  "}
            $row1[2] {$row1[2] = "  "}
            $row1[3] {$row1[3] = "  "}
            $row1[4] {$row1[4] = "  "}
            $row2[0] {$row2[0] = "  "}
            $row2[1] {$row2[1] = "  "}
            $row2[2] {$row2[2] = "  "}
            $row2[3] {$row2[3] = "  "}
            $row2[4] {$row2[4] = "  "}
            $row3[0] {$row3[0] = "  "}
            $row3[1] {$row3[1] = "  "}
            $row3[2] {$row3[2] = "  "}
            $row3[3] {$row3[3] = "  "}
            $row3[4] {$row3[4] = "  "}
            $row4[0] {$row4[0] = "  "}
            $row4[1] {$row4[1] = "  "}
            $row4[2] {$row4[2] = "  "}
            $row4[3] {$row4[3] = "  "}
            $row4[4] {$row4[4] = "  "}
            $row5[0] {$row5[0] = "  "}
            $row5[1] {$row5[1] = "  "}
            $row5[2] {$row5[2] = "  "}
            $row5[3] {$row5[3] = "  "}
            $row5[4] {$row5[4] = "  "}
        }
        $bingos = 0
        if ($row1[0] -eq "  " -and $row1[1] -eq "  " -and $row1[2] -eq "  " -and $row1[3] -eq "  " -and $row1[4] -eq "  ") {
            $bingos += 1
        }
        if ($row2[0] -eq "  " -and $row2[1] -eq "  " -and $row2[2] -eq "  " -and $row2[3] -eq "  " -and $row2[4] -eq "  ") {
            $bingos += 1
        }
        if ($row3[0] -eq "  " -and $row3[1] -eq "  " -and $row3[2] -eq "  " -and $row3[3] -eq "  " -and $row3[4] -eq "  ") {
            $bingos += 1
        }
        if ($row4[0] -eq "  " -and $row4[1] -eq "  " -and $row4[2] -eq "  " -and $row4[3] -eq "  " -and $row4[4] -eq "  ") {
            $bingos += 1
        }
        if ($row5[0] -eq "  " -and $row5[1] -eq "  " -and $row5[2] -eq "  " -and $row5[3] -eq "  " -and $row5[4] -eq "  ") {
            $bingos += 1
        }
        if ($row1[0] -eq "  " -and $row2[0] -eq "  " -and $row3[0] -eq "  " -and $row4[0] -eq "  " -and $row5[0] -eq "  ") {
            $bingos += 1
        }
        if ($row1[1] -eq "  " -and $row2[1] -eq "  " -and $row3[1] -eq "  " -and $row4[1] -eq "  " -and $row5[1] -eq "  ") {
            $bingos += 1
        }
        if ($row1[2] -eq "  " -and $row2[2] -eq "  " -and $row3[2] -eq "  " -and $row4[2] -eq "  " -and $row5[2] -eq "  ") {
            $bingos += 1
        }
        if ($row1[3] -eq "  " -and $row2[3] -eq "  " -and $row3[3] -eq "  " -and $row4[3] -eq "  " -and $row5[3] -eq "  ") {
            $bingos += 1
        }
        if ($row1[4] -eq "  " -and $row2[4] -eq "  " -and $row3[4] -eq "  " -and $row4[4] -eq "  " -and $row5[4] -eq "  ") {
            $bingos += 1
        }
        if ($row1[0] -eq "  " -and $row2[1] -eq "  " -and $row3[2] -eq "  " -and $row4[3] -eq "  " -and $row5[4] -eq "  ") {
            $bingos += 1
        }
        if ($row1[4] -eq "  " -and $row2[3] -eq "  " -and $row3[2] -eq "  " -and $row4[1] -eq "  " -and $row5[0] -eq "  ") {
            $bingos += 1
        }
        $col1 = "│" + $row1[0] + "│" + $row2[0] + "│" + $row3[0] + "│" + $row4[0] +"│" + $row5[0] + "│"
        $col2 = "│" + $row1[1] + "│" + $row2[1] + "│" + $row3[1] + "│" + $row4[1] +"│" + $row5[1] + "│"
        $col3 = "│" + $row1[2] + "│" + $row2[2] + "│" + $row3[2] + "│" + $row4[2] +"│" + $row5[2] + "│"
        $col4 = "│" + $row1[3] + "│" + $row2[3] + "│" + $row3[3] + "│" + $row4[3] +"│" + $row5[3] + "│"
        $col5 = "│" + $row1[4] + "│" + $row2[4] + "│" + $row3[4] + "│" + $row4[4] +"│" + $row5[4] + "│"
        $sheet = "┌──┬──┬──┬──┬──┐`n$col1`n├──┼──┼──┼──┼──┤`n$col2`n├──┼──┼──┼──┼──┤`n$col3`n├──┼──┼──┼──┼──┤`n$col4`n├──┼──┼──┼──┼──┤`n$col5`n└──┴──┴──┴──┴──┘`nYou got $bingos lines"
        0..$_ | ForEach-Object {"No." + (($_ + 1).ToString()).PadLeft(2,' ') + ": " + $numbers[$_]} # 過去の全てを表示
        #"No." + (($_ + 1).ToString()).PadLeft(2,' ') + ": " + $numbers[$_] # 現在の1行だけ表示
        $sheet
        Read-Host
    }
    "Done`nEnter to return"
    Read-Host
}