chcp 65001
$ErrorActionPreference = 'Continue'

<#
可変フォントしかない場合はweightを指定してstaticフォントにする
必要なもの
Python 3.13
fonttools package
install: pip install fonttools
コマンド
fonttools varLib.mutator font.ttf wght=400
#>

# 使う変数の初期値(編集可能)
# 同時に型を指定すると何を入れればいいのか明確になる
[string]$DefaultDirectory = $PSScriptRoot
[string]$vencodingoptions = "-c:v h264_nvenc -qmax 22 -qmin 22"

# 使う変数の初期値(編集不可能)
# スクリプト内で変更されるので書き換える意味がない
[string]$fontfile = ""
[string]$dopad = ""
[string]$fpstext = ""
[Single]$fps = 0
[string]$textcolor = ""
[array]$colors = @()
[string]$backgroundcolor = ""
[int]$textsize = 0
[int]$width = 0
[int]$height = 0
[int]$textx = 0
[int]$texty = 0
[string]$timertext = ""
[int]$count = 0
[array]$ffplay = @()
[string]$confirm = ""
[string]$length = "0"
[Single]$length1 = 1
[int]$hour = 0
[int]$minute = 0
[int]$second = 0
[int]$millisecond = 0
[single]$1flength = 0
[single]$fulllength = 0
[string]$filename = ""
[bool]$flag = $true

# 関数一覧
function versioncheck { # 特定以上のバージョンを使うよう指示
    param ( # 引数一覧(コンマで区切るのを忘れない!)
        [int]$a = 5 # 引数を取らなかったときの初期値
    )
    if ($PSVersionTable.PSVersion.Major -lt $a) {
        "Please run this ps1 file on PowerShell $a or newer`nEnter to exit"
        Read-Host
        Start-Process "https://github.com/PowerShell/PowerShell/releases/latest"
        Exit
    }
}

# 環境の確認
$ErrorActionPreference = 'SilentlyContinue'
ffmpeg -version | Out-Null
if (-not $?) {
    "ffmpeg is unabailable`nenter to exit"
    Read-Host
    exit
}
[array]$colors = (ffmpeg -hide_banner -colors)[1..(ffmpeg -hide_banner -colors).Count] | ForEach-Object {$_.SubString(0,$_.Length - 7).Trim()}
ffplay -version | Out-Null
if (-not $?) {
    "ffplay is unabailable`nenter to exit"
    Read-Host
    exit
}
$ErrorActionPreference = 'Continue'

# メイン処理
Set-Location $DefaultDirectory # DefaultDirectoryかPSScriptRootにするのが無難
versioncheck 5
While ($IsWindows) {
    Clear-Host
    # フォントファイルの確認
    if ((Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}).Count -eq 1) { # フォント1個
        $fontfile = Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
    } elseif ((Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}).Count -ge 2) { # フォント2個以上
        Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
        do {
            $fontfile = Read-Host -Prompt "フォントを選択してください"
        } until (Test-Path ".\$fontfile")
    } else { # フォント0個
        Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
        do {
            $fontfile = Read-Host -Prompt "インストールされているフォントから選択してください"
        } until (Test-Path "C:\Windows\Fonts\$fontfile")
        $fontfile = "C\:/Windows/Fonts/" + $fontfile
    }

    "入力する情報`nFPS`n文字の色`n背景の色`n文字サイズ`n背景の幅`n背景の高さ`n文字のx座標`n文字のy座標`n0埋めするか`n動画にするか`n動画時間`n拡張子なしのファイル名`nメモ帳などでパラメータをメモするのをおすすめします"

    # FPS入力
    $ErrorActionPreference = 'SilentlyContinue'
    do {
        do {
            $fpstext = Read-Host -Prompt "FPS(正の実数)"
        } until ($fpstext -match "^\d+\.?\d*$" -and ($fpstext) -ne 0)
        $fps = $fpstext
    } until ($?)
    $ErrorActionPreference = 'Continue'

    # 文字色の入力
    do {
        $textcolor = Read-Host -Prompt "文字の色(RGB(A)カラーコードまたは色の名前)"
    } until ($textcolor -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor -in $colors)
    if ($textcolor -match "^#?([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$") {
        $textcolor = $Matches[1] + $Matches[2]
    }

    # 背景色の入力
    do {
        $backgroundcolor = Read-Host -Prompt "背景の色(RGB(A)カラーコードまたは色の名前)透過すると黒になります"
    } until ($backgroundcolor -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $backgroundcolor -in $colors)
    if ($backgroundcolor -match "^#?([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$") {
        $backgroundcolor = $Matches[1] + $Matches[2]
    }

    #文字サイズの指定
    do {
        $textsizetext = Read-Host -Prompt "文字サイズ(正の整数)"
    } until ($textsizetext -match "\d+" -and ($textsizetext) -ne 0)
    $textsize = $textsizetext

    #画面サイズの指定
    do {
        $widthtext = Read-Host -Prompt "背景の幅(正の整数)"
    } until ($widthtext -match "\d+" -and ($widthtext) -ne 0)
    $width = $widthtext
    do {
        $heighttext = Read-Host -Prompt "背景の高さ(正の整数)"
    } until ($heighttext -match "\d+" -and ($heighttext) -ne 0)
    $height = $heighttext

    #文字座標の指定
    do {
        $textxtext = Read-Host -Prompt "文字のx座標(正負の整数)"
    } until ($textxtext -match "-?\d+")
    $textx = $textxtext
    do {
        $textytext = Read-Host -Prompt "文字のy座標(正負の整数)"
    } until ($textytext -match "-?\d+")
    $texty = $textytext

    # 0埋めの確認
    do {
        $dopad = Read-Host -Prompt "1: 0埋めする 2: 0埋めしない"
    } until ($dopad -match "^[12]$")
    if ([int]$dopad - 2 * -1) {# 1を選んだ場合
        $timertext = "drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:fontcolor=${textcolor}:text='%{eif\:mod(floor(mod(floor(t/3600),60)/24),100)\:u\:2}\:%{eif\:mod(mod(floor(t/3600),60),24)\:u\:2}\:%{eif\:mod(floor(t/60),60)\:u\:2}\:%{eif\:mod(floor(t),60)\:u\:2}.%{eif\:floor(mod(n/${fps},1)*1000)\:u\:3}'"
    } else {# 2を選んだ場合
        $timertext = "drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:fontcolor=${textcolor}:text='%{eif\:mod(floor(mod(floor(t/3600),60)/24),100)\:u\:2}\:%{eif\:mod(mod(floor(t/3600),60),24)\:u\:2}\:%{eif\:mod(floor(t/60),60)\:u\:2}\:%{eif\:mod(floor(t),60)\:u\:2}.%{eif\:floor(mod(n/${fps},1)*1000)\:u\:3}',drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:00\:00\:0':enable=lt(mod(t\,8640000)\,10),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:00\:00\:':enable=lt(mod(t\,8640000)\,60),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:00\:0':enable=lt(mod(t\,8640000)\,600),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:00\:':enable=lt(mod(t\,8640000)\,3600),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:0':enable=lt(mod(t\,8640000)\,36000),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='00\:':enable=lt(mod(t\,8640000)\,86400),drawtext=x=${textx}:y=${texty}:fontfile='${fontfile}':fontsize=${textsize}:borderw=2:bordercolor=${backgroundcolor}:fontcolor=${backgroundcolor}:text='0':enable=lt(mod(t\,8640000)\,864000)"
    }

    # プレビュー
    "プレビューの準備完了。ffplayを終了するにはffplayをフォーカスしてEscやAlt+F4を使用してください"
    $count = $ffplay.Count + 1
    do {
        $ffplay += (Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel -8 -window_title ""Preview${count}"" -f lavfi -i ""color=c=${backgroundcolor}:s=${width}x${height}:r=${fps}"" -vf ""${timertext}""" -NoNewWindow -PassThru).Id

        # 動画作成に入る前の確認
        do {
            $confirm = Read-Host -Prompt "これで動画を作成しますか?(yY|nN|rR)`nnNを選択すると最初からやりなおします`nRで現在のプレビューを最初に戻します"
        } until ($confirm -match "^[yYnNrR]$")
        if (($confirm -match "^[rR]$") -and ($ffplay.Count -eq $count)) {
            Stop-Process -Id $ffplay[$ffplay.Count - 1]
        }
    } until ($confirm -match "^[yYnN]$")
    if ($confirm -match "^[yY]$") {
        $ffplay | ForEach-Object{
            Stop-Process -Id $_
        }
        $ffplay = @()

        # 動画時間の取得
        do {
            $length = Read-Host -Prompt "動画時間([秒(.ミリ秒)]表記と[((時間:)分:)秒(.ミリ秒)]表記のどちらにも対応`n(時間と分、分と秒のデリミタは:;のどちらか、秒とミリ秒のデリミタは.))"
        } until ($length -match "^(((0?[1-9]|[1-9]\d*)[:;])?(0?[1-9]|[1-5][0-9][:;]:)?(0?\d|[1-5][0-9])(\.(\d{1,3}))?$|^\d+(\.(\d{1,3}))?$")
        if ($text -match "^(((0?[1-9]|[1-9]\d*)[:;])?(0?[1-9]|[1-5][0-9][:;]:)?(0?\d|[1-5][0-9])(\.(\d{1,3}))?$") {
            $hour = $Matches.3
            $minute = $Matches.4
            $second = $Matches.5
            $millisecond = ([string]$Matches.7).PadRight(3,'0').ToInt32()
            $length1 = $hour * 3600 + $minute + 60 + $second + $millisecond / 1000
        }
        $1flength = -1 / $fps
        $fulllength = $length1 + 1 / $fps

        # 出力ファイル名の指定
        do {
            do {
                $filename=Read-Host -Prompt "拡張子なしのファイル名(拡張子にはmp4が付きます)"
            } until (-not ($filename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("$PSScriptRoot" + [string]$filename).Length -le 250)
            $flag = $true
            if ((Test-Path ".\${filename}.mp4") -or (Test-Path ".\${filename}_begin.png") -or (Test-Path ".\${filename}_final.png.mp4")) {
                do {
                    "上書きしますか?(y/n)"
                    $overwriteconfirm=Read-Host
                } until ($overwriteconfirm -match "^[yYnN]$")
                if ($overwriteconfirm -match "^[nN]$") {
                    $flag=$false
                }
            }
        } until ($flag)

        #実際に出力
        ffmpeg -y -hide_banner -loglevel -8 -f lavfi -i "color=c=${backgroundcolor}:s=${width}x${height}:r=${fps}" -vf "${timertext}" -t $fulllength $vencodingoptions "${filename}.mp4"
        ffmpeg -hide_banner -loglevel -8 -i "${filename}.mp4" -frames:v 1 "${filename}_begin.png"
        ffmpeg -hide_banner -loglevel -8 -sseof $1flength -i "${filename}.mp4" -frames:v 1 "${filename}_final.png"
        "完成。Enterで最初に戻る"
        Read-Host
    }
}
"Windows以外は実装していませんので諦めてください(MacもLinuxもないからわからん)"