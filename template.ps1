<#
PowerShell テンプレートファイル

1.コメントアウト(VSCodeでは緑で表示)
# ←これより後は改行するまでコメント 
<#
複数行に
渡るコメント
#⁣> ←コメントアウトの最後じゃないのでU+2063を#と>の間に書いています

Get-Content <#行の一部だけコメント#⁣> -Recurse

2.基本コマンド
2.1 コマンド構文
PowerShell コマンドレットの場合
動詞-名詞 [-オプション...]
(エイリアスが存在する場合もある)

ps1ファイルの実行
.\hoge.ps1

cmd コマンド
コマンド名 [/オプション...]


Get-Help コマンド名 [-Online]
コマンドのヘルプを表示
-Onlineを付けるとMicrosoftの公式ドキュメントページを開く(おすすめ)
エイリアス: help

Set-Location フォルダ
作業フォルダを移動する
作業フォルダはエクスプローラーで言えば「フォルダを見ている状態」
パスの指定は絶対パス(ドライブ名からフォルダまでの全ての道のり、フルパスともいう)か相対パス(現在のフォルダを.、一つ上のフォルダを..としてフォルダを相対的に指定)
エイリアス: cd

Get-ChildItem [-Name] [-Recurse] [-Directory]
作業フォルダ内のファイルとフォルダを表示
-Nameオプションを付けるとファイル名とフォルダ名のみ表示
-Recurseオプションを付けるとフォルダの中のファイルやフォルダの中のフォルダ(サブフォルダとも呼ばれる)を表示
-Directoryオプションを付けるとフォルダのみ表示
ファイルのみ表示したい場合は
((Get-ChildItem [-Recurse]) | Where-Object{$_.Mode -match "^[^d]"}).Name
↑では()や|も書くので[]以外コピペがおすすめ
エイリアス:ls、dir、gci

Get-Content










#>

<#
文字エンコードの指定
932:Windows 932(Shift-JISと互換、cmdとWindows PowerShell(5.1)のデフォルト)
65001:UTF-8(世界共通の規格で最も推奨、PowerShell Coreのデフォルト)
1200:UTF-16(バイト数多め)
#>
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
Get-ChildItem 