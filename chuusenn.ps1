<#
継続抽選シミュレーター
継続確率と目標継続数を入力すると
目標継続数に到達するまでにかかった抽選回数と
当選率(理論値、実測値)を出力します
#>

while (1) {
    $logtext = "無限ループの為終了にはCtrl+C等使用`n確率には整数比を使用`n分子"
    while (1) {
        $num = ""
        do {
            Clear-Host
            $num = Read-Host $logtext # numeratorの略らしい
        } until ($num -match "^[1-9]\d*$" -and [long]::TryParse($num, [ref]$num))
        $logtext += ": ${num}`n分母"
        $den = ""
        do {
            Clear-Host
            $den = Read-Host $logtext # denominatorの略
        } until ($den -match "^([1-9]\d+|[2-9])$" -and [long]::TryParse($den, [ref]$den))
        if ($num -ge $den) {
            $logtext = "無限ループの為終了にはCtrl+C等使用`n確率には整数比を使用`n${num}/${den}は1以上です`n分子"
            continue
        }
        break
    }
    $logtext += ": ${den}`n${num}/${den}=$($num / $den * 100)%`n目標継続数"
    $dest = ""
    do {
        Clear-Host
        $dest = Read-Host $logtext
    } until ($dest -match "^[1-9]\d*$" -and [long]::TryParse($dest, [ref]$dest))
    $logtext += ": ${dest}`n"
    Clear-Host
    Write-Host $logtext
    $ren = 0l
    $try = 0l
    $suc = 0l
    $retry = 0l
    while ($ren -lt $dest) {
        $try++
        if ((Get-Random -Maximum $den) -ge $num) {
            $ren = 0l
            $retry++
        } else {
            $suc++
            $ren++
        }
    }
    $logtext += "抽選回数: $($retry + 1)`n実測継続率: $($suc / $try * 100)%`nEnterで再抽選"
    Clear-Host
    Read-Host $logtext
}