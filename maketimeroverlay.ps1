chcp 65001
$ErrorActionPreference = 'Continue'
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
[string]$defaultfolder = "$PSScriptRoot" # デフォルト: $PSScriptRoot
[string]$vencodesetting = "-c:v libx264 -qp 21" # デフォルト: "-c:v libx264 -qp 21" フィルターをかけるので"-c:v copy"は使えない
[string]$aencodesetting = "-c:a aac -q:a 1" # デフォルト: "-c:a aac -q:a 1" デフォルトではあえて再エンコードするように書いているが、できるなら"-c:a copy"が良い
[string]$outputextension = "mp4" # デフォルト: "mp4" デフォルトがmp4向けのエンコード設定のため。ただし上のエンコード設定によっては変える必要あり、あとここで編集させているのはすぐ上にエンコード設定があるから
[string]$vencodesetting = "-c:v ffv1 -level 3"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
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
[string]$row1 = ""
[string]$row2 = ""
[string]$row3 = ""
[string]$textcolor1 = ""
[string]$textsize1 = ""
[string]$textcolor2 = ""
[string]$textsize2 = ""
[string]$textcolor3 = ""
[string]$textsize3 = ""
[string]$linespace1 = ""
[string]$linespace2 = ""
[array]$starts = @()
[array]$stops = @()
[uint]$counter = 0
[int]$isend = 0
[int]$videoframes = 0
[int]$flag1 = 0
[int]$gtframe = 0
[array]$rtframes = @()
[array]$gtframes = @()
[array]$stframes = @()
[int]$interval = 0
[array]$intervals = @()
[array]$sts = @()
[array]$gts = @()
[array]$rts = @()


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
    $videoframes = ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames"
    Start-Process -FilePath "ffplay" -ArgumentList "-fs -hide_banner -loglevel -8 -window_title ""フレーム確認"" -loop 0 -i ""${inputfilename}"" -vf ""pad=w=iw:h=ih+75:x=0:y=75,drawtext=y_align=font:fontsize=70:fontcolor=white:y_align=font:fontfile=c\\:/Windows/Fonts/cour.ttf:text='Frames\: %{eif\:ceil(t*${fps})\:u\:0}'""" -NoNewWindow

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
                $textsize = Read-Host -Prompt "文字サイズ(1以上の整数)"
            } until ($textsize -match "^[1-9]\d*$") # 1以上の整数
            $textsize | Out-File -FilePath option.txt -Append
            $logtext += "文字サイズ: ${textsize}"

            # 文字座標の指定
            do {
                Clear-Host
                $logtext
                $textx = Read-Host -Prompt "文字のx座標(正負の整数)"
            } until ($textx -match "^(0|-?[1-9]\d*)$")
            $textx | Out-File -FilePath option.txt -Append
            $logtext += "文字x座標: ${textx}"
            do {
                Clear-Host
                $logtext
                $texty = Read-Host -Prompt "文字のy座標(正負の整数)"
            } until ($texty -match "^(0|-?[1-9]\d*)$")
            $texty | Out-File -FilePath option.txt -Append
            $logtext += "文字y座標: ${texty}"

            # 表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $appearat = Read-Host -Prompt "タイマーを出すフレーム(0以上の整数)0で最初から表示します"
                } until ($appearat -match "^(0|[1-9]\d*)$")
            } until ([int]$appearat -le $videoframes - 3)
            $appearat | Out-File -FilePath option.txt -Append
            $logtext += "表示フレーム: ${appearat}"

            # 開始フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $startat = Read-Host -Prompt "タイマーを始めるフレーム(読み込み時のフリーズから動き出したフレーム)"
                } until ($startat -match "^([1-9]\d*)$")
            } until ([int]$startat -ge [int]$appearat -and [int]$startat -le $videoframes - 2)
            $startat | Out-File -FilePath option.txt -Append
            $logtext += "開始フレーム: ${startat}"

            # 停止フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $stopat = Read-Host -Prompt "タイマーを止めるフレーム(ロード中が表示されたフレーム)"
                } until ($stopat -match "^(0|[1-9]\d*)$")
            } until ([int]$stopat -gt [int]$startat -and [int]$stopat -le $videoframes - 1)
            $stopat | Out-File -FilePath option.txt -Append
            $logtext += "停止フレーム: ${stopat}"

            # 非表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $disappearat = Read-Host -Prompt "タイマーを非表示にするフレーム、-1で最後のフレームを選択します"
                } until ($disappearat -match "^(0|-1|[1-9]\d*)$")
            } until (([int]$disappearat -gt [int]$stopat -and [int]$disappearat -le $videoframes) -or $disappearat -match "^-1$")
            $disappearat | Out-File -FilePath option.txt -Append
            if ($disappearat -match "^-1$") {
                $disappearat = $videoframes
            }
            $logtext += "非表示フレーム: ${disappearat}"

            $duration = [Math]::Round(([int]$stopat - [int]$startat) / ($fps | Invoke-Expression), 3, 1)
            $hour = [Math]::Floor($duration / 3600)
            $minute = (([Math]::Floor(($duration % 3600) / 60)).ToString()).PadLeft(2,'0')
            $second = (([Math]::Floor(($duration % 60))).ToString()).PadLeft(2,'0')
            $millisecond = (([Math]::Round(($duration % 1)*1000,0,1)).ToString()).PadLeft(3,'0')
            if ([Math]::Floor($duration / 10) -eq 0) { # 10秒未満
                $second = [Math]::Floor(($duration % 60))
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 5) { # 10秒以上1分未満
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 59) { # 1分以上10分未満
                $minute = [Math]::Floor(($duration % 3600) / 60)
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 359) { # 10分以上1時間未満
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } else { # 1時間以上
                $hourpad = ("").PadLeft($hour.Length,'0')
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hourpad}\:00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor((t-(${startat}/${fps}))/3600)\:d\:$($hour.Length)}\:%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hour}\:${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
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
            } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}\${filename}").Length -le 250)
            if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
                do {
                    Clear-Host
                    $logtext
                    Write-Host "現在のファイル名: ${defaultfolder}\${outputfilename}.${outputextension}"
                    $confirm=Read-Host -Prompt "ファイルが既に存在します。上書きしますか?(yn)"
                } until ($confirm -match "^[yYnN]$")
            }
        } until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
        "${defaultfolder}\${outputfilename}.${outputextension}を作成中..."
        $encodinglength = Measure-Command -Expression {
            Start-Process -FilePath "ffmpeg" -ArgumentList "-hide_banner -loglevel -8 -y -i ""${inputfilename}"" -vf ""${timertext}"" ${vencodesetting} ${aencodesetting} ""${defaultfolder}\${outputfilename}.${outputextension}""" -Wait -NoNewWindow
        }
        Write-Host "${defaultfolder}\${outputfilename}.${outputextension}は$((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))でエンコードしました`nEnterで終了"
        Read-Host
        exit
    } else { # Full-Game
        $logtext += "モード: Full-Game"
        do {
            do {
                Clear-Host
                $logtext
                $row1 = Read-Host -Prompt "1行目`n1:GT 2:RT 3:ST"
            } until ($row1 -match "^[123]$")
            switch  ([int]$row1) {
                1 {
                    $logtext += "1行目: GT"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2行目`n2:RT 3:ST"
                    } until ($row2 -match "^[23]$")
                    if ($row2 -match "^2$") { # 123
                        $row3 = "3"
                        $logtext += "2行目: RT"
                        $logtext += "3行目: ST"
                    } else { # 132
                        $row3 = "2"
                        $logtext += "2行目: ST"
                        $logtext += "3行目: RT"
                    }
                }
                2 {
                    $logtext += "1行目: RT"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2行目`n1:GT 3:ST"
                    } until ($row2 -match "^[13]$")
                    if ($row2 -match "^1$") { # 213
                        $row3 = "3"
                        $logtext += "2行目: GT"
                        $logtext += "3行目: ST"
                    } else { # 231
                        $row3 = "1"
                        $logtext += "2行目: ST"
                        $logtext += "3行目: GT"
                    }
                }
                3 {
                    $logtext += "1行目: ST"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2行目`n1:GT 2:RT"
                    } until ($row2 -match "^[12]$")
                    if ($row2 -match "^1$") { # 312
                        $row3 = "2"
                        $logtext += "2行目: GT"
                        $logtext += "3行目: RT"
                    } else { # 321
                        $row3 = "1"
                        $logtext += "2行目: RT"
                        $logtext += "3行目: GT"
                    }
                }
            }
            $row1 | Out-File -FilePath option.txt -Force
            $row2 | Out-File -FilePath option.txt -Append

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
                $fontfile | Out-File -FilePath option.txt -Append
                $logtext += "フォント: ${defaultfolder}\${fontfile}"
            } else { # フォント0個
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "インストールされているフォントから選択してください"
                } until ((Test-Path "C:\Windows\Fonts\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Append
                $logtext += "フォント: C:\Windows\Fonts\${fontfile}"
                $fontfile = "C\\:/Windows/Fonts/${fontfile}"
            }

            # 文字色の入力1
            do {
                Clear-Host
                $logtext
                $textcolor1 = Read-Host -Prompt "1行目($($logtext[2].Substring(5,2)))の色(RGB(A)カラーコードまたは色の名前)Aは小さくすると消えます"
            } until ($textcolor1 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor1 -in $colors)
            $textcolor1 | Out-File -FilePath option.txt -Append
            if ($textcolor1 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor1 = $Matches[1]
            }
            $logtext += "文字色(1行目): ${textcolor1}"
            # 文字サイズの指定1
            do {
                Clear-Host
                $logtext
                $textsize1 = Read-Host -Prompt "1行目($($logtext[2].Substring(5,2)))の文字サイズ(1以上の整数)"
            } until ($textsize1 -match "^[1-9]\d*$") # 1以上の整数
            $textsize1 | Out-File -FilePath option.txt -Append
            $logtext += "文字サイズ(1行目): ${textsize1}"
            # 文字色の入力2
            do {
                Clear-Host
                $logtext
                $textcolor2 = Read-Host -Prompt "2行目($($logtext[3].Substring(5,2)))の色(RGB(A)カラーコードまたは色の名前)Aは小さくすると消えます"
            } until ($textcolor2 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor2 -in $colors)
            $textcolor2 | Out-File -FilePath option.txt -Append
            if ($textcolor2 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor2 = $Matches[1]
            }
            $logtext += "文字色(2行目): ${textcolor2}"
            # 文字サイズの指定2
            do {
                Clear-Host
                $logtext
                $textsize2 = Read-Host -Prompt "2行目($($logtext[3].Substring(5,2)))の文字サイズ(1以上の整数)"
            } until ($textsize2 -match "^[1-9]\d*$") # 1以上の整数
            $textsize2 | Out-File -FilePath option.txt -Append
            $logtext += "文字サイズ(2行目): ${textsize2}"
            # 文字色の入力3
            do {
                Clear-Host
                $logtext
                $textcolor3 = Read-Host -Prompt "3行目($($logtext[4].Substring(5,2)))の色(RGB(A)カラーコードまたは色の名前)Aは小さくすると消えます"
            } until ($textcolor3 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor3 -in $colors)
            $textcolor3 | Out-File -FilePath option.txt -Append
            if ($textcolor3 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor3 = $Matches[1]
            }
            $logtext += "文字色(3行目): ${textcolor3}"
            # 文字サイズの指定3
            do {
                Clear-Host
                $logtext
                $textsize3 = Read-Host -Prompt "3行目($($logtext[4].Substring(5,2)))の文字サイズ(1以上の整数)"
            } until ($textsize3 -match "^[1-9]\d*$") # 1以上の整数
            $textsize3 | Out-File -FilePath option.txt -Append
            $logtext += "文字サイズ(3行目): ${textsize3}"

            # 文字座標の指定
            do {
                Clear-Host
                $logtext
                $textx = Read-Host -Prompt "文字のx座標(正負の整数)1行目の左が基準になります"
            } until ($textx -match "^(0|-?[1-9]\d*)$")
            $textx | Out-File -FilePath option.txt -Append
            $logtext += "文字x座標: ${textx}"
            do {
                Clear-Host
                $logtext
                $texty = Read-Host -Prompt "文字のy座標(正負の整数)1行目の上が基準になります"
            } until ($texty -match "^(0|-?[1-9]\d*)$")
            $texty | Out-File -FilePath option.txt -Append
            $logtext += "文字y座標: ${texty}"

            # 行間の指定1
            do {
                Clear-Host
                $logtext
                $linespace1 = Read-Host -Prompt "1行目($($logtext[2].Substring(5,2)))と2行目($($logtext[3].Substring(5,2)))の行間(正負の整数)プレビューを見ながら検討してください"
            } until ($linespace1 -match "^(0|-?[1-9]\d*)$")
            $linespace1 | Out-File option.txt -Append
            $logtext += "行間1: ${linespace1}"
            # 行間の指定2
            do {
                Clear-Host
                $logtext
                $linespace2 = Read-Host -Prompt "2行目($($logtext[3].Substring(5,2)))と3行目($($logtext[4].Substring(5,2)))の行間(正負の整数)プレビューを見ながら検討してください"
            } until ($linespace2 -match "^(0|-?[1-9]\d*)$")
            $linespace2 | Out-File option.txt -Append
            $logtext += "行間2: ${linespace2}"



            # いよいよタイマーを作っていく
            # 表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $appearat = Read-Host -Prompt "タイマーを出すフレーム(0以上の整数)0で最初から表示します"
                } until ($appearat -match "^(0|[1-9]\d*)$")
            } until ([int]$appearat -le $videoframes)
            $appearat | Out-File -FilePath option.txt -Append
            $logtext += "表示フレーム: ${appearat}"
            $counter = 1
            $isend = 0
            do {
                if ($counter -eq 1) {
                    $logtext = $logtext[0..16]
                    do {
                        do {
                            $starts = @()
                            Clear-Host
                            $logtext
                            $starts += Read-Host -Prompt "タイマーを始めるフレーム(読み込み時のフリーズから動き出したフレーム)"
                        } until ($starts[0] -match "^([1-9]\d*)$")
                    } until ($starts[0] -le $videoframes)
                    $logtext += "開始フレーム1: $($starts[0])"
                    do {
                        do {
                            $stops = @()
                            Clear-Host
                            $logtext
                            $stops += Read-Host -Prompt "タイマーを止めるフレーム(ロード中が表示されたフレーム)"
                        } until ($stops[0] -match "^([1-9]\d*)$")
                    } until ([int]$stops[0] -le $videoframes -and [int]$stops[0] -gt [int]$starts[0])
                    $logtext += "停止フレーム1: $($starts[0])"
                    $counter += 1
                } else {
                    do {
                        $starts = @($starts[0..($counter - 2)])
                        Clear-Host
                        $logtext
                        $starts += Read-Host -Prompt "タイマーを始めるフレーム(読み込み時のフリーズから動き出したフレーム)`n$(if ($counter -ge 3) {"endで終了、"})undoで1つ戻る"
                    } until ($starts[-1] -match "^([1-9]\d*|end|undo)$")
                    switch ($starts[-1]) {
                        "end" {
                            if ($counter -ge 3) {
                                $isend = 1
                                $starts = $starts[0..($starts.Count - 2)]
                            }
                        }
                        "undo" {
                            $counter -= 1
                        }
                        default {
                            if ([int]$starts[-1] -gt [int]$stops[-1]) {
                                $logtext += "開始フレーム$($counter): $($starts[-1])"
                                $flag1 = 0
                                do {
                                    do {
                                        $stops = @($stops[0..($counter - 2)])
                                        Clear-Host
                                        $logtext
                                        $stops += Read-Host -Prompt "タイマーを止めるフレーム(ロード中が表示されたフレーム)`ncancelで開始フレームに戻る"
                                    } until ($stops[-1] -match "^([1-9]\d*|cancel)$")
                                    switch ($stops[-1]) {
                                        "cancel" {
                                            $stops = @($starts[0..($counter - 2)])
                                            $flag1 = 1
                                        }
                                        default {
                                            if ([int]$stops[-1] -gt [int]$starts[-1]) {
                                                $logtext += "停止フレーム$($counter): $($starts[-1])"
                                                $counter += 1
                                                $flag1 = 1
                                            }
                                        }
                                    }
                                } until ($flag1)
                            }
                        }
                    }
                    $logtext = $logtext[0..16]
                    1..($counter - 1) | ForEach-Object {
                        $logtext += "開始フレーム${_}: $($starts[($_ - 1)])"
                        $logtext += "停止フレーム${_}: $($stops[($_ - 1)])"
                    }
                }
            } until ($isend)
            0..($starts.Count - 1) | ForEach-Object {
                $starts[$_] | Out-File -FilePath option.txt -Append
                $stops[$_] | Out-File -FilePath option.txt -Append
            }
            "end" | Out-File -FilePath option.txt -Append

            # 非表示フレーム
            do {
                do {
                    Clear-Host
                    $logtext
                    $disappearat = Read-Host -Prompt "タイマーを非表示にするフレーム、-1で最後のフレームを選択します"
                } until ($disappearat -match "^(0|-1|[1-9]\d*)$")
            } until (([int]$disappearat -gt [int]$stops[-1] -and [int]$disappearat -le $videoframes) -or $disappearat -match "^-1$")
            $disappearat | Out-File -FilePath option.txt -Append
            if ($disappearat -match "^-1$") {
                $disappearat = $videoframes
            }
            $logtext += "非表示フレーム: ${disappearat}"

            $gtframes = @()
            $rtframes = @()
            $stframes = @()
            $intervals = @()
            $interval = 0
            $gtframe = 0
            $gts = @()
            $rts = @()
            $sts = @()
            0..($starts.Count - 1) | ForEach-Object {
                $stframes += [int]$stops[$_] - [int]$starts[$_]
                $rtframes += [int]$stops[$_] - [int]$starts[0]
                $interval += [int]$starts[($_ + 1)] - [int]$stops[$_]
                $intervals += $interval
            }
            $stframes | ForEach-Object {
                $gtframe += [int]$_
                $gtframes += $gtframe
            }
            $sts = $stframes | ForEach-Object {
                [Math]::Round($_ / ($fps | Invoke-Expression), 3, 1)
            }
            $gts = $gtframes | ForEach-Object {
                [Math]::Round($_ / ($fps | Invoke-Expression), 3, 1)
            }
            $rts = $rtframes | ForEach-Object {
                [Math]::Round($_ / ($fps | Invoke-Expression), 3, 1)
            }
            $format = "0.000"
            $gtmoveformat = '%{eif\:mod(floor((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})),10)\:d\:1}.%{eif\:mod(round((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})*1000),1000)\:d\:3}'
            $rtmoveformat = '%{eif\:mod(floor((t-($($starts[0])/${fps}))),10)\:d\:1}.%{eif\:mod(round((t-($($starts[0])/${fps}))*1000),1000)\:d\:3}'
            $stmoveformat = '%{eif\:mod(floor((t-($($starts[$_])/${fps}))),10)\:d\:1}.%{eif\:mod(round((t-($($starts[$_])/${fps}))*1000),1000)\:d\:3}'
            $gtstopformat = '%{eif\:mod(floor(($($gtframes[$_])/${fps})),10)\:d\:1}.%{eif\:mod(round(($($gtframes[$_])/${fps})*1000),1000)\:d\:3}'
            $rtstopformat = '%{eif\:mod(floor(($($rtframes[$_])/${fps})),10)\:d\:1}.%{eif\:mod(round(($($rtframes[$_])/${fps})*1000),1000)\:d\:3}'
            $ststopformat = '%{eif\:mod(floor(($($stframes[$_])/${fps})),10)\:d\:1}.%{eif\:mod(round(($($stframes[$_])/${fps})*1000),1000)\:d\:3}'
            if ([Math]::Floor($rts[-1] / 10)) {
                $format = "0${format}"
                $gtmoveformat = '%{eif\:mod(floor((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})/10),6)\:d\:1}' + $gtmoveformat
                $rtmoveformat = '%{eif\:mod(floor((t-($($starts[0])/${fps}))/10),6)\:d\:1}' + $rtmoveformat
                $stmoveformat = '%{eif\:mod(floor((t-($($starts[$_])/${fps}))/10),6)\:d\:1}' + $stmoveformat
                $gtstopformat = '%{eif\:mod(floor(($($gtframes[$_])/${fps})/10),6)\:d\:1}' + $gtstopformat
                $rtstopformat = '%{eif\:mod(floor(($($rtframes[$_])/${fps})/10),6)\:d\:1}' + $rtstopformat
                $ststopformat = '%{eif\:mod(floor(($($stframes[$_])/${fps})/10),6)\:d\:1}' + $ststopformat
                if ([Math]::Floor($rts[-1] / 60)) {
                    $format = "0\:${format}"
                    $gtmoveformat = '%{eif\:mod(floor((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})/60),10)\:d\:1}\:' + $gtmoveformat
                    $rtmoveformat = '%{eif\:mod(floor((t-($($starts[0])/${fps}))/60),10)\:d\:1}\:' + $rtmoveformat
                    $stmoveformat = '%{eif\:mod(floor((t-($($starts[$_])/${fps}))/60),10)\:d\:1}\:' + $stmoveformat
                    $gtstopformat = '%{eif\:mod(floor(($($gtframes[$_])/${fps})/60),10)\:d\:1}\:' + $gtstopformat
                    $rtstopformat = '%{eif\:mod(floor(($($rtframes[$_])/${fps})/60),10)\:d\:1}\:' + $rtstopformat
                    $ststopformat = '%{eif\:mod(floor(($($stframes[$_])/${fps})/60),10)\:d\:1}\:' + $ststopformat
                    if ([Math]::Floor($rts[-1] / 600)) {
                        $format = "0${format}"
                        $gtmoveformat = '%{eif\:mod(floor((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})/360),6)\:d\:1}' + $gtmoveformat
                        $rtmoveformat = '%{eif\:mod(floor((t-($($starts[0])/${fps}))/360),6)\:d\:1}' + $rtmoveformat
                        $stmoveformat = '%{eif\:mod(floor((t-($($starts[$_])/${fps}))/360),6)\:d\:1}' + $stmoveformat
                        $gtstopformat = '%{eif\:mod(floor(($($gtframes[$_])/${fps})/360),6)\:d\:1}' + $gtstopformat
                        $rtstopformat = '%{eif\:mod(floor(($($rtframes[$_])/${fps})/360),6)\:d\:1}' + $rtstopformat
                        $ststopformat = '%{eif\:mod(floor(($($stframes[$_])/${fps})/360),6)\:d\:1}' + $ststopformat
                        if ([Math]::Floor($rts[-1] / 3600)) {
                            $hourlength = (([Math]::Floor($rts[-1] / 3600)).ToString()).Length
                            $format = "" + ("").PadLeft($hourlength,'0') + "\:${format}"
                            $gtmoveformat = '%{eif\:floor((t-($($starts[0])+$(if ($_ -eq 0) {"0"} else {$intervals[($_ - 1)]}))/${fps})/3600)\:d\:${hourlength}}\:' + $gtmoveformat
                            $rtmoveformat = '%{eif\:floor((t-($($starts[0])/${fps}))/3600)\:d\:${hourlength}}\:' + $rtmoveformat
                            $stmoveformat = '%{eif\:floor((t-($($starts[$_])/${fps}))/3600)\:d\:${hourlength}}\:' + $stmoveformat
                            $gtstopformat = '%{eif\:floor(($($gtframes[$_])/${fps})/3600)\:d\:${hourlength}}\:' + $gtstopformat
                            $rtstopformat = '%{eif\:floor(($($rtframes[$_])/${fps})/3600)\:d\:${hourlength}}\:' + $rtstopformat
                            $ststopformat = '%{eif\:floor(($($stframes[$_])/${fps})/3600)\:d\:${hourlength}}\:' + $ststopformat
                        }
                    }
                }
            }
            $gtmoveformat = '"GT\: ' + $gtmoveformat + '"'
            $rtmoveformat = '"RT\: ' + $rtmoveformat + '"'
            $stmoveformat = '"ST\: ' + $stmoveformat + '"'
            $gtstopformat = '"GT\: ' + $gtstopformat + '"'
            $rtstopformat = '"RT\: ' + $rtstopformat + '"'
            $ststopformat = '"ST\: ' + $ststopformat + '"'
            
            switch ("${row1}${row2}${row3}") {
                "123" {
                    #GT
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #RT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #ST
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
                "132" {
                    #GT
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #ST
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #RT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
                "213" {
                    #RT
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #GT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #ST
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
                "231" {
                    #RT
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #ST
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #GT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
                "312" {
                    #ST
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #GT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #RT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
                "321" {
                    #ST
                    $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='ST\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($sts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($stmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor1}:fontsize=${textsize1}:x=${textx}:y=${texty}:text='$($ststopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #RT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='RT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($rts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($rtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor2}:fontsize=${textsize2}:x=${textx}:y=${texty}+${linespace1}+lh:text='$($rtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                    #GT
                    $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='GT\: ${format}':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),$($starts[0]))',"
                    0..($gts.Count - 1) | ForEach-Object {
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($gtmoveformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($starts[$_]))*lt(ceil(t*${fps}),$($stops[$_]))',"
                        $timertext += "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor3}:fontsize=${textsize3}:x=${textx}:y=${texty}+${linespace1}+${linespace2}+lh+lh:text='$($gtstopformat | Invoke-Expression)':enable='gte(ceil(t*${fps}),$($stops[$_]))*lt(ceil(t*${fps}),$(if ($_ -eq ($gts.Count - 1)) {$disappearat} else {$starts[($_ + 1)]}))',"
                    }
                }
            }
            $timertext += "null"
            Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel error -window_title ""プレビュー"" -loop 0 -i ""${inputfilename}"" -vf ""${timertext}""" -NoNewWindow
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
        do {
            do {
                Clear-Host
                $logtext
                $outputfilename=Read-Host -Prompt "拡張子なしのファイル名(拡張子には${outputextension}が付きます)"
            } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}\${filename}").Length -le 250)
            if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
                do {
                    Clear-Host
                    $logtext
                    Write-Host "現在のファイル名: ${defaultfolder}\${outputfilename}.${outputextension}"
                    $confirm=Read-Host -Prompt "ファイルが既に存在します。上書きしますか?(yn)"
                } until ($confirm -match "^[yYnN]$")
            }
        } until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
        "${defaultfolder}\${outputfilename}.${outputextension}を作成中..."
        $encodinglength = Measure-Command -Expression {
            Start-Process -FilePath "ffmpeg" -ArgumentList "-hide_banner -loglevel -8 -y -i ""${inputfilename}"" -vf ""${timertext}"" ${vencodesetting} ${aencodesetting} ""${defaultfolder}\${outputfilename}.${outputextension}""" -Wait -NoNewWindow
        }
        Write-Host "${defaultfolder}\${outputfilename}.${outputextension}は$((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))でエンコードしました`nEnterで終了"
        Read-Host
        exit
    }
} else {
    Write-Host "現在このps1ファイルはWindowsでのみ動作します`nEnterで終了"
    Read-Host
}