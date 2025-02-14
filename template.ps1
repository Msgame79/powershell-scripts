# PowerShell テンプレートファイル
# 文字エンコードの指定
chcp 65001

<#
エラーメッセージの処理
Continue(デフォルト):表示しつつ続ける
SilentlyContinue:表示せずに続ける
#>
$ErrorActionPreference = 'Continue'

# 使う変数の初期値(これを書くことで編集を容易にできる)
# 同時に型を指定すると何を入れればいいのか明瞭になる
[string]$DefaultDirectory = $PSScriptRoot

# 関数一覧
function versioncheck { # 特定以上のバージョンを使うよう指示
    param ( # 引数一覧(コンマで区切るのを忘れない!)
        [int]$a = 5 # 初期値
    )
    if ($PSVersionTable.PSVersion.Major -lt $a) {
        "Please run this ps1 file on PowerShell $a or newer`nEnter to exit"
        Read-Host
        Start-Process "https://github.com/PowerShell/PowerShell/releases/latest"
        Exit
    }
}

# メイン処理
Set-Location $DefaultDirectory
versioncheck 7
