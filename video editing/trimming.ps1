$ErrorActionPreference = 'SilentlyContinue'
<#
このps1ファイルはバージョン6以降で動作します。versioncheckが使用できないのでここに書きますがPowerShellのバージョン6以降をGitHubかMSStoreより入手してください。
URL: https://github.com/PowerShell/PowerShell/releases/latest

可変フォントしかない場合はweightを指定してstaticフォントにする
必要なもの
Python 3.13
fonttools package
インストール: pip install fonttools
コマンド
fonttools varLib.mutator filename.ttf wght=value
#>

# 変数一覧(変更可能)
[string]$defaultfolder = "$PSScriptRoot" # デフォルト: $PSScriptRoot
[string]$vencodesetting = "-c:v libx264 -crf 21" # デフォルト: "-c:v libx264 -crf 21" キーフレームで常にトリミングを開始する(もしくはGOPを0にしている)なら"-c:v copy"でも良い
[string]$aencodesetting = "-c:a aac -q:a 1" # デフォルト: "-c:a aac -q:a 1" デフォルトではあえて再エンコードするように書いているが、できるなら"-c:a copy"が良い
[string]$outputextension = "mp4" # デフォルト: "mp4" デフォルトがmp4向けのエンコード設定のため。ただし上のエンコード設定によっては変える必要あり、あとここで編集させているのはすぐ上にエンコード設定があるから
<#
目的別いろんなエンコードメモ
再生できればいいからとにかく容量を小さくしたい場合
hevc+Opus,mkv Container(環境によるかも)
[string]$vencodesetting = "-c:v libx265 -qp 18"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "mkv"

互換性が欲しい場合
h264+aac, mp4 container(伝統的な組み合わせで大抵のデバイスで再生可能)
[string]$vencodesetting = "-c:v libx264 -qp 18"
[string]$aencodesetting = "-c:a aac -q:a 1"
[string]$outputextension = "mp4"
VP9+Opus, webm container(YouTubeでも使われてる)
[string]$vencodesetting = "-c:v libvpx-vp9"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "webm"

可逆圧縮したい場合
h264(lossless)+alac, mp4 container(mp4で可逆圧縮したい場合。flacはmp4コンテナに入らない)
[string]$vencodesetting = "-c:v libx264 -qp 0"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mp4"
utvideo+flac, mkv container (ファイルサイズがでかくなる)
[string]$vencodesetting = "-c:v utvideo"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
ffv1+flac, mkv container(ファイルの保存に一番向いている)
[string]$vencodesetting = "-c:v ffv1 -level 3"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
VP9(lissless)+Opus(非可逆圧縮だがWebm側が可逆圧縮の音声コーデックをサポートしていない), webm container(エンコードがめちゃ遅い)
[string]$vencodesetting = "-c:v libvpx-vp9 -lossless 1"
[string]$aencodesetting = "-c:a libopus -b:a 128k"
[string]$outputextension = "webm"
#>

# 変数一覧(変更不可能)
[string]$inputfilename = ""
[int]$ffplay = 0
[int]$starttime = -1
[int]$endtime = -1
[string]$startat = ""
[string]$endat = ""
[int]$hour = 0
[int]$minute = 0
[int]$second = 0
[int]$millisecond = 0
[System.Object]$encodinglength = $null

ffmpeg -version | Out-Null
if (-not $?) {
    Write-Host "ffmpegを実行できません`nEnterで終了"
    Read-Host
    exit
}
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
if ($outputextension -notmatch "^(avi|flv|gif|mkv|mov|mp4|webm|ogv|asf|aac|aiff|alac|flac|m4a|mka|mp3|ogg|opus|vorbis|wav)$") {
    "`$outputextensionの値が不正です`nEnterで終了"
    Read-Host
    exit
}

#メイン処理
if (-not (Test-Path $defaultfolder)) {
    "フォルダ${defaultfolder}が存在しません`nEnterで終了"
    Read-Host
    exit
}
Set-Location $defaultfolder
if ((@(Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"})).Count -eq 0) {
    "動画ファイルが${defaultfolder}で見つかりません`nEnterで終了"
    Read-Host
    exit
}
do {
    do {
        Clear-Host
        Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"}
        $inputfilename = Read-Host -Prompt "動画ファイルを選択"
    } until (Test-Path $inputfilename)
    $ffplay = (Start-Process -FilePath "ffplay" -ArgumentList "-loglevel -8 -i ""${inputfilename}"" -window_title ""動画全体"" -fs -loop 0 -vf ""pad=w=if(lt(iw\,1047)\,1047\,iw):h=ih+70:x=0:y=70,drawtext=fontfile=C\\:/Windows/Fonts/cour.ttf:fontcolor=white:fontsize=70:y_align=font:text='%{eif\:floor(t/3600)\:d\:2}\:%{eif\:floor(mod(t,3600)/60)\:d\:2}\:%{eif\:floor(mod(t,60))\:d\:2}.%{eif\:round(mod(t,1)*1000)\:d\:3} %{eif\:floor(t)\:d\:6}.%{eif\:round(mod(t,1)*1000)\:d\:3} %{pict_type}'""" -NoNewWindow).Id
    do {
        do {
            Clear-Host
            $startat = Read-Host -Prompt "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から"
        } until ($startat -match "^(c|-1|\d+\.?\d{0,3}|((\d+:)?[0-5]?\d:)?[0-5]?\d\.?\d{0,3}$")
        $starttime = -1
        if ($startat -match "^((?<second>\d+)\.?(?<millisecond>\d{0,3})|(((?<hour>\d+):)?(?<minute>[0-5]?\d):)?(?<second>[0-5]?\d)\.?(?<millisecond>\d{0,3}))$") {
            $hour = [int]$Matches.hour
            $minute = [int]$Matches.minute
            $second = [int]$Matches.second
            $millisecond = if ([int]$Matches.millisecond) {[int]($Matches.millisecond).PadRight(3,"0")} else {0}
            $starttime = $hour * 3600000 + $minute * 60000 + $second * 1000 + $millisecond
            do {
                do {
                    Clear-Host
                    $endat = Read-Host -Prompt "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から: ${startat}`nトリミング終了時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、-1で最後まで"
                } until ($endat -match "^(c|-1|\d+\.?\d{0,3}|((\d+:)?[0-5]?\d:)?[0-5]?\d\.?\d{0,3}$")
                $endtime = -1
                if ($endat -match "^((?<second>\d+)\.?(?<millisecond>\d{0,3})|(((?<hour>\d+):)?(?<minute>[0-5]?\d):)?(?<second>[0-5]?\d)\.?(?<millisecond>\d{0,3}))$") {
                    $hour = [int]$Matches.hour
                    $minute = [int]$Matches.minute
                    $second = [int]$Matches.second
                    $millisecond = if ([int]$Matches.millisecond) {[int]($Matches.millisecond).PadRight(3,"0")} else {0}
                    $endtime = $hour * 3600000 + $minute * 60000 + $second * 1000 + $millisecond
                } elseif ($endat -match "^-1$") {
                    $endat = ""
                    $endtime = $starttime + 1
                }
            } until ($endtime -gt $starttime -or $endat -eq "c")
        }
    } until ($endtime -ge 0 -or $startat -eq "c")
} until ($starttime -ge 0)
do {
    do {
        Clear-Host
        $outputfilename = Read-Host -Prompt "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から: ${startat}`nトリミング終了時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、-1で最後まで: ${endat}`n拡張子なしのファイル名(拡張子には${outputextension}が付きます)"
    } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}\${filename}").Length -le 250)
    if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
        do {
            Clear-Host
            $confirm=Read-Host -Prompt "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から: ${startat}`nトリミング終了時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、-1で最後まで: ${endat}`n拡張子なしのファイル名(拡張子には${outputextension}が付きます): ${outputfilename}`nファイルが既に存在します。上書きしますか?(yn)"
        } until ($confirm -match "^[yYnN]$")
    }
} until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
Clear-Host
Write-Host "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から: ${startat}`nトリミング終了時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、-1で最後まで: ${endat}`n拡張子なしのファイル名(拡張子には${outputextension}が付きます): ${outputfilename}`n${defaultfolder}\${outputfilename}.${outputextension}を作成中..."
$encodinglength = Measure-Command -Expression {
    Start-Process -FilePath "ffmpeg" -ArgumentList "-hide_banner -loglevel -8 -y -ss ${startat} $(if ($endat.Length -ge 1) {"-to $endat"}) -i ""${inputfilename}"" ${vencodesetting} ${aencodesetting} ""${defaultfolder}\${outputfilename}.${outputextension}""" -Wait -NoNewWindow
}
while (1) {
    Clear-Host
    Write-Host "動画ファイルを選択: ${inputfilename}`nトリミング開始時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、0で最初から: ${startat}`nトリミング終了時間`nffplayと同じ秒.小数秒または時間:分:秒.小数秒で書く`ncで一つ戻る、-1で最後まで: ${endat}`n拡張子なしのファイル名(拡張子には${outputextension}が付きます): ${outputfilename}`n${defaultfolder}\${outputfilename}.${outputextension}を作成中...`n${defaultfolder}\${outputfilename}.${outputextension}は$((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))でエンコードしました`nCtrl+CまたはAlt+F4で終了"
    Read-Host
}