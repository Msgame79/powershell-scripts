<#
Exponential Idle 理論9補題5: \lim_{t\to\infty}\\frac{e^{t}f(e^{t})}{f(t)}>1 (証明する式なので関与はない)
\dot{\rho}=\frac{q}{|e-\frac{c_{1}}{c_{2}}|}
\dot{q}=q_{1}q_{2}
\dot{var}は1秒(10tick)当たりの増加量
\dot{\rho}の値を最大化したい
q_{1}q_{2}は増えるだけなので最適化の必要はない。
|e-\frac{c_{1}}{c_{2}}|については最小のものを探す必要がある。
結論、このスクリプトは分数でeの近似をしている。
(本来はPythonのdecimalでも使うべきなのだろう)
#>

$E = 2.7182818284590452353602874714d
$c1 = 1d
$c2 = 1d
$lowest = 1d
$logtext = ""
Clear-Host
while($true) {
    if (($E)-($c1/$c2) -gt 0d) { # e > c1/c2
        $c1+=1d
    } else { # e < c1/c2
        $c2+=1d
    }
    $current = [Decimal]::Abs(($E)-($c1/$c2))
    if ($current -lt $lowest) {
        $logtext += "c_{1}=$c1`nc_{2}=$c2`ne-\frac{c_{1}}{c_{2}}=$(($E)-($c1/$c2))`n|e-\frac{c_{1}}{c_{2}}|=$current`n`n"
        Clear-Host
        $logtext
        $lowest = $current
        Read-Host
    }
}