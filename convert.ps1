chcp 65001
$char = "0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
[Decimal]$num = 0
[int]$base = 0
[int]$int = 0
[Decimal]$int1 = 0
[int]$idigit = 0
[int]$a = 0
[Decimal]$b = 0
[Decimal]$c = 0
[decimal]$d = 0
while (1)
{
    Clear-Host
    $ninput = Read-Host "Enter a decimal number"
    if ([decimal]::TryParse($ninput, [ref]$num))
    {
        do
        {
            Clear-Host
            Write-Host "Enter a decimal number: $num"
            $binput = Read-Host "Enter base"
        } until ($binput -match "^([2-9]|[1-2]\d|3[0-6])$")
        $base = [int]$binput
        $int = $num - ($num % 1)
        $int1 = $int
        $idigit = 0
        do
        {
            $idigit++
            $int1 /= $base
        } while ($int1 -ge 1)
        do
        {
            $a = 1
            for ($i = 0; $i -lt $idigit - 1; $i++) {
                $a *= $base
            }
            $b = [Decimal]::Floor($int / $a)
            Write-Host $char[$b] -NoNewline
            $int -= $a * $b
            $idigit--
        } while ($idigit)
        if ($num % 1)
        {
            Write-Host "." -NoNewline
            $c = $num % 1
            $d = 1
            do
            {
                $c *= 10
                $d *= 10
            }
            while ($c % 1)
            while ($c)
            {
                $c *= $base
                if ($c -ge $d)
                {
                    Write-Host $char[([Decimal]::Floor($c / $d))] -NoNewline
                    $c -= $d * [Decimal]::Floor($c / $d)
                }
                else
                {
                    Write-Host 0 -NoNewline
                }
            }
        }       
    }
    Read-Host
}