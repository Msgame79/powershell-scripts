# 編集可能な変数
[string]$outputfilename = "" # テキストファイル(UTF-8 Without BOM)に書き込む場合はフルパスで指定(拡張子.txtも忘れずに書く、拡張子がない場合は書き込みません)
[array]$levellist = @( # ステージ一覧
    "Mansion"
    "Train"
    "Carry"
    "Mountain"
    "Demolition"
    "Castle"
    "Water"
    "Power Plant"
    "Aztec"
    "Dark"
    "Steam"
    "Ice"
    "Reprise"<# # エクストラステージを入れるならコメントアウト解除
    "Thermal"
    "Factory"
    "Golf"
    "City"
    "Forest"
    "Laboratory"
    "Lumber"
    "Red Rock"
    "Tower"
    "Miniature"
    "Copper World"
    "Port"
    "Underwater"
    "Dockyard"
    "Museum"
    "Hike"
    "Candyland"#>
)
[uint]$levelnumber = $levellist.Count # $levellist.Count($levellistの個数)で全てをシャッフル、$levellistの個数を越えた値でも全てをシャッフル

# 編集不可能な変数
[array]$numlist = @()
[string]$lvlstring = ""
[uint]$counter = 1

# スクリプトの始まり
chcp 65001
$ErrorActionPreference = 'continue'
# 無限ループ
if ($levellist.Count -eq 0) {
    Write-Host -Object "`$levellistが空です`nEnterで終了"
    Read-Host
    exit
}
while (1) {
    Clear-Host
    # $numlistの配列は整数値で取得
    if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 4) {
        $numlist = 1..$levellist.Count | Get-SecureRandom -Count $levelnumber
    } else {
        $numlist = 1..$levellist.Count | Get-Random -Count $levelnumber
    }
    $counter = 1
    $lvlstring = ""
    $numlist | ForEach-Object {
        $lvlstring += "$(([string]$counter).PadLeft((($numlist.Count).ToString()).Length," ")). $($levellist[($_ - 1)])$(if ($counter -lt $numlist.Count) {"`n"} else {})"
        $counter++
    }
    try {
        if ($outputfilename.Substring(($outputfilename.Length - 4), 4) -eq ".txt") {
            if (Test-Path -Path "${outputfilename}") {
                do {
                    Remove-Item -Path "${outputfilename}"
                } until (-not (Test-Path -Path "${outputfilename}"))
            }
            New-Item -Type "File" -Value "$lvlstring" -Path "${outputfilename}" | Out-Null
        }
    }
    catch {}
    Write-Host -Object "${lvlstring}`nEnterで再抽選、Ctrl+CやAlt+F4で終了"
    Read-Host
}