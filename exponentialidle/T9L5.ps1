<#
Exponential Idle 理論9補題5: \lim_{t\to\infty}\tau>0 (証明する式なので関与はない)
\dot{\rho}=\sum_{i=1}^{8}{c_{i}}^{4}(2i^{2}-c_{i})q
\dot{q}=q_{1}q_{2}
\dot{var}は1秒当たりの増加量
\dot{\rho}の値を最大化したい
q_{1}q_{2}は増えるだけなので最適化の必要はないが、{c_{i}}^{4}(2i^{2}-c_{i})については慎重になる必要がある。
c_iは0以上の整数をとるため、整数に対するループを作成し、計算結果が最大になるものを見つければよい。
#>

$values = [System.Collections.Generic.List[PSCustomObject]]::new()

for ($i = 1; $i -le 8; $i++) {
    for ($c = 0; $c -le 2147483647; $c++) {
        $values.Add([PSCustomObject]@{
            i = $i
            c_i = $c
            "{c_{i}}^{4}(2i^{2}-c_{i})" = [long]($c * $c * $c * $c * (2 * $i * $i - $c))
        })
        if ($values[-1]."{c_{i}}^{4}(2i^{2}-c_{i})" -lt 0) {
            break
        }
    }
}

for ($i = 1; $i -le 8; $i++) {
    ($values | Where-Object {$_.i -eq $i} | Sort-Object -Property "{c_{i}}^{4}(2i^{2}-c_{i})")[-1]
}