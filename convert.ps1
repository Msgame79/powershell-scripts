chcp 65001
$char = "0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
[Decimal]$num = 0
[int]$base = 0
[Decimal]$int = 0
[Decimal]$int1 = 0
[int]$idigit = 0
[string]$digits = ""
[Decimal]$a = 0
[Decimal]$b = 0
[Decimal]$c = 0
[decimal]$d = 0
$e = @()
[int]$f = 0
while (1)
{
    Clear-Host
    $ninput = Read-Host "10進数で入力"
    if ([decimal]::TryParse($ninput, [ref]$num))
    {
        do
        {
            Clear-Host
            Write-Host "10進数で入力: $num"
            $binput = Read-Host "基数(10進整数で2から36)を入力"
        } until ($binput -match "^([2-9]|[1-2]\d|3[0-6])$")
        $base = [int]$binput

        # 整数部と小数部を分割
        $int = [Decimal]::Floor($num)
        $fraction = $num - $int

        # 整数部の変換（繰り返し除算で高速化）
        $digits = ""
        if ($int -eq 0) {
            $digits = "0"
        } else {
            $intTemp = $int
            $intChars = New-Object System.Collections.Generic.List[string]
            while ($intTemp -gt 0) {
                $rem = [int]($intTemp % $base)
                $intChars.Insert(0, $char[$rem])
                $intTemp = [Decimal]::Floor($intTemp / $base)
            }
            $digits = ($intChars -join "")
        }

        $f = 0
        if ($fraction -gt 0)
        {
            $digits += "."
            # 小数部を分数（numerator/denominator）へ変換：10進の有限小数を整数化
            $c = $fraction
            $d = 1
            do {
                $c *= 10
                $d *= 10
            } while ($c % 1 -ne 0)

            $numerator = [int]$c
            $denominator = [int]$d

            # 循環検出用にハッシュテーブルを使用（高速）
            $seen = @{}
            $fractionChars = New-Object System.Collections.Generic.List[string]
            $pos = 0
            while ($numerator -ne 0) {
                if ($seen.ContainsKey($numerator)) {
                    $startPos = $seen[$numerator]
                    $f = $fractionChars.Count - $startPos
                    # ループを組み立てて終了
                    if ($startPos -gt 0) {
                        $digits += ($fractionChars[0..($startPos - 1)] -join "")
                    }
                    $digits += "["
                    if ($startPos -le $fractionChars.Count - 1) {
                        $digits += ($fractionChars[$startPos..($fractionChars.Count - 1)] -join "")
                    }
                    $digits += "]"
                    break
                }
                $seen[$numerator] = $pos

                $numerator *= $base
                $digitVal = [int]([Decimal]::Floor($numerator / $denominator))
                $fractionChars.Add($char[$digitVal])
                $numerator = $numerator % $denominator
                $pos++
            }

            if ($numerator -eq 0) {
                # 非循環（終端）
                if ($fractionChars.Count -gt 0) {
                    $digits += ($fractionChars -join "")
                }
            }
        }

    }
    Write-Host "$digits`n$(if ($f) {"${f}桁循環`n"})完了"
    Read-Host
}