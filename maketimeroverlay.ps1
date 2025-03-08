chcp 65001
$ErrorActionPreference = 'SilentlyContinue'
<#
このps1ファイルはバージョン6以降で動作します。versioncheckが使用できないのでここに書きますがPowerShellのバージョン6以降をGitHubかMSStoreより入手してください。
URL: https://github.com/PowerShell/PowerShell/releases/latest
#>

# 変数一覧(変更可能)
[string]$defaultfolder = "$PSScriptRoot\av1test" # デフォルト: $PSScriptRoot
[string]$vencodesetting = "-c:v h264_nvenc -qp 18" # デフォルト: "-c:v libx264 -qp 21" フィルターをかけるので"-c:v copy"は使えない
[string]$aencodesetting = "-c:a copy" # デフォルト: "-c:a aac -q:a 1" デフォルトではあえて再エンコードするように書いているが、できるなら"-c:a copy"が良い
[string]$outputextension = "mp4" # デフォルト: "mp4" デフォルトがmp4向けのエンコード設定のため。ただし上のエンコード設定によっては変える必要あり、あとここで編集させているのはすぐ上にエンコード設定があるから
<#
目的別いろんなエンコードメモ
再生できればいいからとにかく容量を小さくしたい場合
hevc+Opus,mkv Container
[string]$vencodesetting = "-c:v libx265 -qp 18"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "mkv"

互換性が欲しい場合
h264+aac, mp4 container
[string]$vencodesetting = "-c:v libx264 -qp 18"
[string]$aencodesetting = "-c:a aac -q:a 1"
[string]$outputextension = "mp4"
VP9+Opus, webm container
[string]$vencodesetting = "-c:v libvpx-vp9"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "webm"

可逆圧縮したい場合
h264(lossless)+alac, mp4 container
[string]$vencodesetting = "-c:v libx264 -qp 0"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mp4"
utvideo+flac, mkv container (ファイルサイズがでかくなる)
[string]$vencodesetting = "-c:v utvideo"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
ffv1+flac, mkv container
[string]$vencodesetting = "-c:v ffv1 -level 3"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
VP9(lissless)+Opus(非可逆圧縮だがWebm側が可逆圧縮の音声コーデックをサポートしていない), webm container(エンコードがめちゃ遅い)
[string]$vencodesetting = "-c:v libvpx-vp9 -lossless 1"
[string]$aencodesetting = "-c:a libopus -b:a 128k"
[string]$outputextension = "webm"
#>

# 変数一覧(変更不可能)
[array]$colors = @()
[array]$inputfilelist = @()
[string]$inputfilename = ""
[string]$fontfile = ""
[array]$logtext = @()
[string]$fps = ""
[string]$textcolor = ""
[string]$textsize = ""
[string]$textx = ""
[string]$texty = ""

ffmpeg -version | Out-Null
if (-not $?) {
    Write-Host "ffmpegを実行できません`nEnterで終了"
    Read-Host
    exit
}
$colors = (ffmpeg -hide_banner -colors)[1..(ffmpeg -hide_banner -colors).Count] | ForEach-Object {$_.SubString(0,$_.Length - 7).Trim()}
ffplay -version | Out-Null
if (-not $?) {
    Write-Host "ffplayを実行できません`nEnterで終了"
    Read-Host
    exit
}
ffprobe -version | Out-Null
if (-not $?) {
    Write-Host "ffprobeを実行できません`nEnterで終了"
    Read-Host
    exit
}

#メイン処理
if ($IsWindows) {
    Set-Location $defaultfolder
    # 動画選択
    $inputfilelist = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"}
    if ($inputfilelist.Count -eq 0) {
       "動画ファイルが${defaultfolder}で見つかりません`nEnterで終了"
       Read-Host
       exit
    }
    do {
        Clear-Host
        $inputfilelist
        $inputfilename = Read-Host -Prompt "動画ファイルを選択"
    } until ($inputfilename -in $inputfilelist)
    $logtext += "入力ファイル: ${inputfilename}"
    $fps = ffprobe -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=r_frame_rate"
    Start-Process -FilePath "ffplay" -ArgumentList "-fs -hide_banner -loglevel -8 -window_title ""フレーム確認"" -loop 0 -i ""${inputfilename}"" -vf ""pad=w=iw:h=ih+75:x=0:y=75,drawtext=fontsize=70:fontcolor=white:y_align=font:fontfile=c\\:/Windows/Fonts/SourceCodePro-Regular.ttf:text='%{eif\:ceil(t*${fps})\:u\:0}'""" -NoNewWindow
    # フォント選択
    if ((Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}).Count -eq 1) { # フォント1個
        $fontfile = Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
        $logtext += "フォント: ${defaultfolder}\${fontfile}"
    } elseif ((Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}).Count -ge 2) { # フォント2個以上
        do {
            Clear-Host
            $logtext
            Get-ChildItem -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
            $fontfile = Read-Host -Prompt "フォントを選択してください"
        } until (Test-Path "${defaultfolder}\${fontfile}")
        $logtext += "フォント: ${defaultfolder}\${fontfile}"
    } else { # フォント0個
        do {
            Clear-Host
            $logtext
            Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match ".+\.(ttf|otf|ttc)"}
            $fontfile = Read-Host -Prompt "インストールされているフォントから選択してください"
        } until (Test-Path "C:\Windows\Fonts\${fontfile}")
        $fontfile = "C\\:/Windows/Fonts/${fontfile}"
        $logtext += "フォント: C:\Windows\Fonts\${fontfile}"
    }
    # 文字色の入力
    do {
        Clear-Host
        $logtext
        $textcolor = Read-Host -Prompt "文字の色(RGB(A)カラーコードまたは色の名前)Aは小さくすると消えます"
    } until ($textcolor -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor -in $colors)
    if ($textcolor -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
        $textcolor = $Matches[1]
    }
    $logtext += "文字色: ${textcolor}"

    #文字サイズの指定
    do {
        Clear-Host
        $logtext
        $textsize = Read-Host -Prompt "文字サイズ(正の整数)"
    } until ($textsize -match "^[1-9]\d*$") # 1以上の整数
    $logtext += "文字サイズ: ${textsize}"

    #文字座標の指定
    do {
        Clear-Host
        $logtext
        $textx = Read-Host -Prompt "文字のx座標(正負の整数)"
    } until ($textx -match "^-?\d+$")
    $logtext += "文字x座標: ${textx}"
    do {
        Clear-Host
        $logtext
        $texty = Read-Host -Prompt "文字のy座標(正負の整数)"
    } until ($texty -match "^-?\d+$")
    $logtext += "文字y座標: ${texty}"
    


    
} else {
    Write-Host "現在このps1ファイルはWindowsでのみ動作します`nEnterで終了"
    Read-Host
}