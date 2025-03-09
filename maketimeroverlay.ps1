chcp 65001
$ErrorActionPreference = 'SilentlyContinue'
<#
このps1ファイルはバージョン6以降で動作します。versioncheckが使用できないのでここに書きますがPowerShellのバージョン6以降をGitHubかMSStoreより入手してください。
URL: https://github.com/PowerShell/PowerShell/releases/latest

可変フォントしかない場合はweightを指定してstaticフォントにする
必要なもの
Python 3.13
fonttools package
install: pip install fonttools
コマンド
fonttools varLib.mutator filename.ttf wght=value
#>

# 変数一覧(変更可能)
[string]$defaultfolder = "$PSScriptRoot\av1test" # デフォルト: $PSScriptRoot
[string]$vencodesetting = "-c:v h264_nvenc -qp 18" # デフォルト: "-c:v libx264 -qp 21" フィルターをかけるので"-c:v copy"は使えない
[string]$aencodesetting = "-c:a copy" # デフォルト: "-c:a aac -q:a 1" デフォルトではあえて再エンコードするように書いているが、できるなら"-c:a copy"が良い
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
VP9+Opus, webm container
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
[array]$colors = @()
[array]$inputfilelist = @()
[string]$inputfilename = ""
[string]$fontfile = ""
[array]$logtext = @()
[string]$fps = ""
[string]$mode = ""
[string]$textcolor = ""
[string]$textsize = ""
[string]$textx = ""
[string]$texty = ""
[string]$appearat = ""
[string]$startat = ""
[Single]$duration = 0
[string]$timertext = ""
[string]$millisecond = ""
[string]$second = ""
[string]$minute = ""
[string]$hour = ""
[string]$hourpad = ""
[string]$confirm = ""
[string]$outputfilename = ""
[System.Object]$encodinglength = $null

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
    $inputfilelist = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"} | Where-Object {$_}
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
    Start-Process -FilePath "ffplay" -ArgumentList "-fs -hide_banner -loglevel -8 -window_title ""フレーム確認"" -loop 0 -i ""${inputfilename}"" -vf ""pad=w=iw:h=ih+75:x=0:y=75,drawtext=fontsize=70:fontcolor=white:y_align=font:fontfile=c\\:/Windows/Fonts/cour.ttf:text='Frames\: %{eif\:ceil(t*${fps})\:u\:0}'""" -NoNewWindow -Wait

    # モード選択
    do {
        Clear-Host
        $logtext
        $mode = Read-Host -Prompt "1:ILs 2:Full-Game"
    } until ($mode -match "^[12]$")

    if ($mode -match "^1$") { # ILs
        do {
            $logtext += "モード: ILs"
            # フォント選択
            if ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -eq 1) { # フォント1個
                $fontfile = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                $logtext += "フォント: ${defaultfolder}\${fontfile}"
            } elseif ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -ge 2) { # フォント2個以上
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "フォントを選択してください"
                } until ((Test-Path "${defaultfolder}\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Force
                $logtext += "フォント: ${defaultfolder}\${fontfile}"
            } else { # フォント0個
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "インストールされているフォントから選択してください"
                } until ((Test-Path "C:\Windows\Fonts\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Force
                $logtext += "フォント: C:\Windows\Fonts\${fontfile}"
                $fontfile = "C\\:/Windows/Fonts/${fontfile}"
            }
            # 文字色の入力
            do {
                Clear-Host
                $logtext
                $textcolor = Read-Host -Prompt "文字の色(RGB(A)カラーコードまたは色の名前)Aは小さくすると消えます"
            } until ($textcolor -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor -in $colors)
            $textcolor | Out-File -FilePath option.txt -Append
            if ($textcolor -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor = $Matches[1]
            }
            $logtext += "文字色: ${textcolor}"

            # 文字サイズの指定
            do {
                Clear-Host
                $logtext
                $textsize = Read-Host -Prompt "文字サイズ(0以上の整数)"
            } until ($textsize -match "^[1-9]\d*$") # 1以上の整数
            $textsize | Out-File -FilePath option.txt -Append
            $logtext += "文字サイズ: ${textsize}"

            # 文字座標の指定
            do {
                Clear-Host
                $logtext
                $textx = Read-Host -Prompt "文字のx座標(正負の整数)"
            } until ($textx -match "^-?\d+$")
            $textx | Out-File -FilePath option.txt -Append
            $logtext += "文字x座標: ${textx}"
            do {
                Clear-Host
                $logtext
                $texty = Read-Host -Prompt "文字のy座標(正負の整数)"
            } until ($texty -match "^-?\d+$")
            $texty | Out-File -FilePath option.txt -Append
            $logtext += "文字y座標: ${texty}"

            # 表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $appearat = Read-Host -Prompt "タイマーを出すフレーム(0以上の整数)0で最初から表示します"
                } until ($appearat -match "^(0|[1-9]\d*)$")
            } until ([int]$appearat -le [int](ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames") - 3)
            $appearat | Out-File -FilePath option.txt -Append
            $logtext += "表示フレーム: ${appearat}"

            # 開始フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $startat = Read-Host -Prompt "タイマーを始めるフレーム(読み込み時のフリーズから動き出したフレーム)"
                } until ($startat -match "^(0|[1-9]\d*)$")
            } until ([int]$startat -ge [int]$appearat -and [int]$startat -le [int](ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames") - 2)
            $startat | Out-File -FilePath option.txt -Append
            $logtext += "開始フレーム: ${startat}"

            # 停止フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $stopat = Read-Host -Prompt "タイマーを止めるフレーム(ロード中が表示されたフレーム)"
                } until ($stopat -match "^(0|[1-9]\d*)$")
            } until ([int]$stopat -gt [int]$startat -and [int]$stopat -le [int](ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames") - 1)
            $stopat | Out-File -FilePath option.txt -Append
            $logtext += "停止フレーム: ${stopat}"

            # 非表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $disappearat = Read-Host -Prompt "タイマーを非表示にするフレーム、-1で最後のフレームを選択します"
                } until ($disappearat -match "^(0|-1|[1-9]\d*)$")
            } until (([int]$disappearat -gt [int]$stopat -and [int]$disappearat -le [int](ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames")) -or $disappearat -match "^-1$")
            $disappearat | Out-File -FilePath option.txt -Append
            if ($disappearat -match "^-1$") {
                $disappearat = [int](ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames")
            }
            $logtext += "非表示フレーム: ${disappearat}"

            $duration = [Math]::Round(([int]$stopat - [int]$startat) / ($fps | Invoke-Expression), 3, 1)
            $hour = ([Math]::Floor($duration / 3600))
            $minute = (([Math]::Floor(($duration % 3600) / 60)).ToString()).PadLeft(2,'0')
            $second = (([Math]::Floor(($duration % 60))).ToString()).PadLeft(2,'0')
            $millisecond = (([Math]::Round(($duration % 1)*1000,0,1)).ToString()).PadLeft(3,'0')
            if ([Math]::Floor($duration / 10) -eq 0) { # 10秒未満
                $second = [Math]::Floor(($duration % 60))
                $timertext = "drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 5) { # 10秒以上1分未満
                $timertext = "drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 59) { # 1分以上10分未満
                $minute = [Math]::Floor(($duration % 3600) / 60)
                $timertext = "drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 359) { # 10分以上1時間未満
                $timertext = "drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } else { # 1時間以上
                $hourpad = ("").PadLeft($hour.Length,'0')
                $timertext = "drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hourpad}\:00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor((t-(${startat}/${fps}))/3600)\:d\:$($hour.Length)}\:%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=fontfile=${fontfile}:fontcolor=${textcolor}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hour}\:${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            }
            Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel -8 -window_title ""プレビュー"" -loop 0 -i ""${inputfilename}"" -vf ""${timertext}""" -NoNewWindow
            do {
                Clear-Host
                $logtext
                $confirm = Read-Host -Prompt "これで動画を作成しますか?(yn)`nNを選ぶとフォント選択に戻ります`nこれまでの入力はoption.txtに自動で保存されています"
            } until ($confirm -match "^[YyNn]$")
            if ($confirm -match "^[nN]$") {
                $logtext = @()
                $logtext += "入力ファイル: ${inputfilename}"
            }
        } until ($confirm -match "^[yY]$")
        $confirm = ""
        do {
            do {
                Clear-Host
                $logtext
                $outputfilename=Read-Host -Prompt "拡張子なしのファイル名(拡張子には${outputextension}が付きます)"
            } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}${filename}").Length -le 250)
            if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
                do {
                    Clear-Host
                    $logtext
                    Write-Host "現在のファイル名: ${defaultfolder}\${outputfilename}.${outputextension}"
                    $confirm=Read-Host -Prompt "ファイルが既に存在します。上書きしますか?(yn)"
                } until ($confirm -match "^[yYnN]$")
            }
        } until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
        $encodinglength = Measure-Command -Expression {ffmpeg -hide_banner -loglevel -8 -y -i "${inputfilename}" -vf "${timertext}" $vencodesetting $aencodesetting "${defaultfolder}\${outputfilename}.${outputextension}"}
        Write-Host "Encoded ${defaultfolder}\${outputfilename}.${outputextension} in $((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))"
    } else { # Full-Game
        $logtext += "モード: Full-Game"
        # フォント選択
        if ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -eq 1) { # フォント1個
            $fontfile = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
            $logtext += "フォント: ${defaultfolder}\${fontfile}"
        } elseif ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -ge 2) { # フォント2個以上
            do {
                Clear-Host
                $logtext
                Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                $fontfile = Read-Host -Prompt "フォントを選択してください"
            } until ((Test-Path "${defaultfolder}\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
            $logtext += "フォント: ${defaultfolder}\${fontfile}"
        } else { # フォント0個
            do {
                Clear-Host
                $logtext
                Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                $fontfile = Read-Host -Prompt "インストールされているフォントから選択してください"
            } until ((Test-Path "C:\Windows\Fonts\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
            $logtext += "フォント: C:\Windows\Fonts\${fontfile}"
            $fontfile = "C\\:/Windows/Fonts/${fontfile}"
        }
    }
} else {
    Write-Host "現在このps1ファイルはWindowsでのみ動作します`nEnterで終了"
    Read-Host
}