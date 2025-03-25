$ErrorActionPreference = 'SilentlyContinue'
<#
����ps1�t�@�C���̓o�[�W����6�ȍ~�œ��삵�܂��Bversioncheck���g�p�ł��Ȃ��̂ł����ɏ����܂���PowerShell�̃o�[�W����6�ȍ~��GitHub��MSStore�����肵�Ă��������B
URL: https://github.com/PowerShell/PowerShell/releases/latest

�σt�H���g�����Ȃ��ꍇ��weight���w�肵��static�t�H���g�ɂ���
�K�v�Ȃ���
Python 3.13
fonttools package
�C���X�g�[��: pip install fonttools
�R�}���h
fonttools varLib.mutator filename.ttf wght=value
#>

# �ϐ��ꗗ(�ύX�\)
[string]$defaultfolder = "$PSScriptRoot" # �f�t�H���g: $PSScriptRoot
[string]$vencodesetting = "-c:v libx264 -crf 21" # �f�t�H���g: "-c:v libx264 -crf 21" �t�B���^�[��������̂�"-c:v copy"�͎g���Ȃ�
[string]$aencodesetting = "-c:a aac -q:a 1" # �f�t�H���g: "-c:a aac -q:a 1" �f�t�H���g�ł͂����čăG���R�[�h����悤�ɏ����Ă��邪�A�ł���Ȃ�"-c:a copy"���ǂ�
[string]$outputextension = "mp4" # �f�t�H���g: "mp4" �f�t�H���g��mp4�����̃G���R�[�h�ݒ�̂��߁B��������̃G���R�[�h�ݒ�ɂ���Ă͕ς���K�v����A���Ƃ����ŕҏW�����Ă���̂͂�����ɃG���R�[�h�ݒ肪���邩��
<#
�ړI�ʂ����ȃG���R�[�h����
�Đ��ł���΂�������Ƃɂ����e�ʂ��������������ꍇ
hevc+Opus,mkv Container(���ɂ�邩��)
[string]$vencodesetting = "-c:v libx265 -qp 18"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "mkv"

�݊������~�����ꍇ
h264+aac, mp4 container(�`���I�ȑg�ݍ��킹�ő��̃f�o�C�X�ōĐ��\)
[string]$vencodesetting = "-c:v libx264 -qp 18"
[string]$aencodesetting = "-c:a aac -q:a 1"
[string]$outputextension = "mp4"
VP9+Opus, webm container(YouTube�ł��g���Ă�)
[string]$vencodesetting = "-c:v libvpx-vp9"
[string]$aencodesetting = "-c:a libopus -b:a 96k"
[string]$outputextension = "webm"

�t���k�������ꍇ
h264(lossless)+alac, mp4 container(mp4�ŉt���k�������ꍇ�Bflac��mp4�R���e�i�ɓ���Ȃ�)
[string]$vencodesetting = "-c:v libx264 -qp 0"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mp4"
utvideo+flac, mkv container (�t�@�C���T�C�Y���ł����Ȃ�)
[string]$vencodesetting = "-c:v utvideo"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
ffv1+flac, mkv container(�t�@�C���̕ۑ��Ɉ�Ԍ����Ă���)
[string]$vencodesetting = "-c:v ffv1 -level 3"
[string]$aencodesetting = "-c:a flac"
[string]$outputextension = "mkv"
VP9(lissless)+Opus(��t���k����Webm�����t���k�̉����R�[�f�b�N���T�|�[�g���Ă��Ȃ�), webm container(�G���R�[�h���߂���x��)
[string]$vencodesetting = "-c:v libvpx-vp9 -lossless 1"
[string]$aencodesetting = "-c:a libopus -b:a 128k"
[string]$outputextension = "webm"
#>

# �ϐ��ꗗ(�ύX�s�\)
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
    Write-Host "ffmpeg�����s�ł��܂���`nEnter�ŏI��"
    Read-Host
    exit
}
$colors = (ffmpeg -hide_banner -colors)[1..(ffmpeg -hide_banner -colors).Count] | ForEach-Object {$_.SubString(0,$_.Length - 7).Trim()}
ffplay -version | Out-Null
if (-not $?) {
    Write-Host "ffplay�����s�ł��܂���`nEnter�ŏI��"
    Read-Host
    exit
}
ffprobe -version | Out-Null
if (-not $?) {
    Write-Host "ffprobe�����s�ł��܂���`nEnter�ŏI��"
    Read-Host
    exit
}

#���C������
if ($IsWindows) {
    Set-Location $defaultfolder
    # ����I��
    $inputfilelist = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"} | Where-Object {$_}
    if ($inputfilelist.Count -eq 0) {
       "����t�@�C����${defaultfolder}�Ō�����܂���`nEnter�ŏI��"
       Read-Host
       exit
    }
    $logtext += "�ł��ł��Ə�������������`n`nSpeedrun.com�̃��[��(https://www.speedrun.com/ja-JP/hff?rules=game)�ɂ��`nPC�̏ꍇ�t�������̓I�[�g�X�v���b�^�[���g��Ȃ�����RT��GT���ꏏ�ɂȂ邵�R���\�[���ƃ��o�C�������f���[�^�[�ɂ�郊�^�C���͉���ł��Ȃ��̂ł����œ���ꂽ�^�C����`n`n""""""""�Q  �l  ��  �x""""""""`n`n�ɗ��߂Ă�������`n"
    do {
        Clear-Host
        $logtext
        $inputfilelist
        $inputfilename = Read-Host -Prompt "����t�@�C����I��"
    } until ($inputfilename -in $inputfilelist)
    $logtext += "���̓t�@�C��: ${inputfilename}"
    $fps = ffprobe -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=r_frame_rate"
    $videoframes = ffprobe -hide_banner -i "${inputfilename}" -loglevel 0 -select_streams v -of "default=nw=1:nk=1" -show_entries "stream=nb_frames"
    Start-Process -FilePath "ffplay" -ArgumentList "-fs -hide_banner -loglevel -8 -window_title ""�t���[���m�F"" -loop 0 -i ""${inputfilename}"" -vf ""pad=w=iw:h=ih+75:x=0:y=75,drawtext=y_align=font:fontsize=70:fontcolor=white:y_align=font:fontfile=c\\:/Windows/Fonts/cour.ttf:text='Frames\: %{eif\:ceil(t*${fps})\:u\:0}'""" -NoNewWindow

    # ���[�h�I��
    do {
        Clear-Host
        $logtext
        $mode = Read-Host -Prompt "1:ILs 2:Full-Game"
    } until ($mode -match "^[12]$")

    if ($mode -match "^1$") { # ILs
        do {
            $logtext += "���[�h: ILs"
            # �t�H���g�I��
            if ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -eq 1) { # �t�H���g1��
                $fontfile = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                $logtext += "�t�H���g: ${defaultfolder}\${fontfile}"
            } elseif ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -ge 2) { # �t�H���g2�ȏ�
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "�t�H���g��I�����Ă�������"
                } until ((Test-Path "${defaultfolder}\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Force
                $logtext += "�t�H���g: ${defaultfolder}\${fontfile}"
            } else { # �t�H���g0��
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "�C���X�g�[������Ă���t�H���g����I�����Ă�������"
                } until ((Test-Path "C:\Windows\Fonts\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Force
                $logtext += "�t�H���g: C:\Windows\Fonts\${fontfile}"
                $fontfile = "C\\:/Windows/Fonts/${fontfile}"
            }
            # �����F�̓���
            do {
                Clear-Host
                $logtext
                $textcolor = Read-Host -Prompt "�����̐F(RGB(A)�J���[�R�[�h�܂��͐F�̖��O)A�͏���������Ə����܂�"
            } until ($textcolor -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor -in $colors)
            $textcolor | Out-File -FilePath option.txt -Append
            if ($textcolor -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor = $Matches[1]
            }
            $logtext += "�����F: ${textcolor}"

            # �����T�C�Y�̎w��
            do {
                Clear-Host
                $logtext
                $textsize = Read-Host -Prompt "�����T�C�Y(1�ȏ�̐���)"
            } until ($textsize -match "^[1-9]\d*$") # 1�ȏ�̐���
            $textsize | Out-File -FilePath option.txt -Append
            $logtext += "�����T�C�Y: ${textsize}"

            # �������W�̎w��
            do {
                Clear-Host
                $logtext
                $textx = Read-Host -Prompt "������x���W(�����̐���)"
            } until ($textx -match "^(0|-?[1-9]\d*)$")
            $textx | Out-File -FilePath option.txt -Append
            $logtext += "����x���W: ${textx}"
            do {
                Clear-Host
                $logtext
                $texty = Read-Host -Prompt "������y���W(�����̐���)"
            } until ($texty -match "^(0|-?[1-9]\d*)$")
            $texty | Out-File -FilePath option.txt -Append
            $logtext += "����y���W: ${texty}"

            # �\���t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $appearat = Read-Host -Prompt "�^�C�}�[���o���t���[��(0�ȏ�̐���)0�ōŏ�����\�����܂�"
                } until ($appearat -match "^(0|[1-9]\d*)$")
            } until ([int]$appearat -le $videoframes - 3)
            $appearat | Out-File -FilePath option.txt -Append
            $logtext += "�\���t���[��: ${appearat}"

            # �J�n�t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $startat = Read-Host -Prompt "�^�C�}�[���n�߂�t���[��(�ǂݍ��ݎ��̃t���[�Y���瓮���o�����t���[��)"
                } until ($startat -match "^([1-9]\d*)$")
            } until ([int]$startat -ge [int]$appearat -and [int]$startat -le $videoframes - 2)
            $startat | Out-File -FilePath option.txt -Append
            $logtext += "�J�n�t���[��: ${startat}"

            # ��~�t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $stopat = Read-Host -Prompt "�^�C�}�[���~�߂�t���[��(���[�h�����\�����ꂽ�t���[��)"
                } until ($stopat -match "^(0|[1-9]\d*)$")
            } until ([int]$stopat -gt [int]$startat -and [int]$stopat -le $videoframes - 1)
            $stopat | Out-File -FilePath option.txt -Append
            $logtext += "��~�t���[��: ${stopat}"

            # ��\���t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $disappearat = Read-Host -Prompt "�^�C�}�[���\���ɂ���t���[���A-1�ōŌ�̃t���[����I�����܂�"
                } until ($disappearat -match "^(0|-1|[1-9]\d*)$")
            } until (([int]$disappearat -gt [int]$stopat -and [int]$disappearat -le $videoframes) -or $disappearat -match "^-1$")
            $disappearat | Out-File -FilePath option.txt -Append
            if ($disappearat -match "^-1$") {
                $disappearat = $videoframes
            }
            $logtext += "��\���t���[��: ${disappearat}"

            $duration = [Math]::Round(([int]$stopat - [int]$startat) / ($fps | Invoke-Expression), 3, 1)
            $hour = [Math]::Floor($duration / 3600)
            $minute = (([Math]::Floor(($duration % 3600) / 60)).ToString()).PadLeft(2,'0')
            $second = (([Math]::Floor(($duration % 60))).ToString()).PadLeft(2,'0')
            $millisecond = (([Math]::Round(($duration % 1)*1000,0,1)).ToString()).PadLeft(3,'0')
            if ([Math]::Floor($duration / 10) -eq 0) { # 10�b����
                $second = [Math]::Floor(($duration % 60))
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 5) { # 10�b�ȏ�1������
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(t-(${startat}/${fps}))\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 59) { # 1���ȏ�10������
                $minute = [Math]::Floor(($duration % 3600) / 60)
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='0\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } elseif ([Math]::Floor($duration / 10) -le 359) { # 10���ȏ�1���Ԗ���
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            } else { # 1���Ԉȏ�
                $hourpad = ("").PadLeft($hour.Length,'0')
                $timertext = "drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hourpad}\:00\:00.000':enable='gte(ceil(t*${fps}),${appearat})*lt(ceil(t*${fps}),${startat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='%{eif\:floor((t-(${startat}/${fps}))/3600)\:d\:$($hour.Length)}\:%{eif\:floor(mod(floor(t-(${startat}/${fps})),3600)/60)\:d\:2}\:%{eif\:mod(floor(t-(${startat}/${fps})),60)\:d\:2}.%{eif\:mod(round((t-${startat}/${fps})*1000),1000)\:d\:3}':enable='gte(ceil(t*${fps}),${startat})*lt(ceil(t*${fps}),${stopat})',drawtext=y_align=font:fontfile=${fontfile}:fontcolor=${textcolor}:fontsize=${textsize}:x=${textx}:y=${texty}:text='${hour}\:${minute}\:${second}.${millisecond}':enable='gte(ceil(t*${fps}),${stopat})*lt(ceil(t*${fps}),${disappearat})'"
            }
            Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel -8 -window_title ""�v���r���["" -loop 0 -i ""${inputfilename}"" -vf ""${timertext}""" -NoNewWindow
            do {
                Clear-Host
                $logtext
                $confirm = Read-Host -Prompt "����œ�����쐬���܂���?(yn)`nN��I�Ԃƃt�H���g�I���ɖ߂�܂�`n����܂ł̓��͂�option.txt�Ɏ����ŕۑ�����Ă��܂�"
            } until ($confirm -match "^[YyNn]$")
            if ($confirm -match "^[nN]$") {
                $logtext = @()
                $logtext += "���̓t�@�C��: ${inputfilename}"
            }
        } until ($confirm -match "^[yY]$")
        $confirm = ""
        do {
            do {
                Clear-Host
                $logtext
                $outputfilename=Read-Host -Prompt "�g���q�Ȃ��̃t�@�C����(�g���q�ɂ�${outputextension}���t���܂�)"
            } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}\${filename}").Length -le 250)
            if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
                do {
                    Clear-Host
                    $logtext
                    Write-Host "���݂̃t�@�C����: ${defaultfolder}\${outputfilename}.${outputextension}"
                    $confirm=Read-Host -Prompt "�t�@�C�������ɑ��݂��܂��B�㏑�����܂���?(yn)"
                } until ($confirm -match "^[yYnN]$")
            }
        } until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
        "${defaultfolder}\${outputfilename}.${outputextension}���쐬��..."
        $encodinglength = Measure-Command -Expression {
            Start-Process -FilePath "ffmpeg" -ArgumentList "-hide_banner -loglevel -8 -y -i ""${inputfilename}"" -vf ""${timertext}"" ${vencodesetting} ${aencodesetting} ""${defaultfolder}\${outputfilename}.${outputextension}""" -Wait -NoNewWindow
        }
        Write-Host "${defaultfolder}\${outputfilename}.${outputextension}��$((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))�ŃG���R�[�h���܂���`nEnter�ŏI��"
        Read-Host
        exit
    } else { # Full-Game
        $logtext += "���[�h: Full-Game"
        do {
            do {
                Clear-Host
                $logtext
                $row1 = Read-Host -Prompt "1�s��`n1:GT 2:RT 3:ST"
            } until ($row1 -match "^[123]$")
            switch  ([int]$row1) {
                1 {
                    $logtext += "1�s��: GT"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2�s��`n2:RT 3:ST"
                    } until ($row2 -match "^[23]$")
                    if ($row2 -match "^2$") { # 123
                        $row3 = "3"
                        $logtext += "2�s��: RT"
                        $logtext += "3�s��: ST"
                    } else { # 132
                        $row3 = "2"
                        $logtext += "2�s��: ST"
                        $logtext += "3�s��: RT"
                    }
                }
                2 {
                    $logtext += "1�s��: RT"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2�s��`n1:GT 3:ST"
                    } until ($row2 -match "^[13]$")
                    if ($row2 -match "^1$") { # 213
                        $row3 = "3"
                        $logtext += "2�s��: GT"
                        $logtext += "3�s��: ST"
                    } else { # 231
                        $row3 = "1"
                        $logtext += "2�s��: ST"
                        $logtext += "3�s��: GT"
                    }
                }
                3 {
                    $logtext += "1�s��: ST"
                    do {
                        Clear-Host
                        $logtext        
                        $row2 = Read-Host -Prompt "2�s��`n1:GT 2:RT"
                    } until ($row2 -match "^[12]$")
                    if ($row2 -match "^1$") { # 312
                        $row3 = "2"
                        $logtext += "2�s��: GT"
                        $logtext += "3�s��: RT"
                    } else { # 321
                        $row3 = "1"
                        $logtext += "2�s��: RT"
                        $logtext += "3�s��: GT"
                    }
                }
            }
            $row1 | Out-File -FilePath option.txt -Force
            $row2 | Out-File -FilePath option.txt -Append

            # �t�H���g�I��
            if ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -eq 1) { # �t�H���g1��
                $fontfile = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                $logtext += "�t�H���g: ${defaultfolder}\${fontfile}"
            } elseif ((Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}).Count -ge 2) { # �t�H���g2�ȏ�
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "�t�H���g��I�����Ă�������"
                } until ((Test-Path "${defaultfolder}\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Append
                $logtext += "�t�H���g: ${defaultfolder}\${fontfile}"
            } else { # �t�H���g0��
                do {
                    Clear-Host
                    $logtext
                    Get-ChildItem -Path "C:\Windows\Fonts" -Name | Where-Object {$_ -match "^.+\.(ttf|otf|ttc)$"}
                    $fontfile = Read-Host -Prompt "�C���X�g�[������Ă���t�H���g����I�����Ă�������"
                } until ((Test-Path "C:\Windows\Fonts\${fontfile}") -and $fontfile -match "^.+\.(ttf|otf|ttc)$")
                $fontfile | Out-File -FilePath option.txt -Append
                $logtext += "�t�H���g: C:\Windows\Fonts\${fontfile}"
                $fontfile = "C\\:/Windows/Fonts/${fontfile}"
            }

            # �����F�̓���1
            do {
                Clear-Host
                $logtext
                $textcolor1 = Read-Host -Prompt "1�s��($($logtext[2].Substring(5,2)))�̐F(RGB(A)�J���[�R�[�h�܂��͐F�̖��O)A�͏���������Ə����܂�"
            } until ($textcolor1 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor1 -in $colors)
            $textcolor1 | Out-File -FilePath option.txt -Append
            if ($textcolor1 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor1 = $Matches[1]
            }
            $logtext += "�����F(1�s��): ${textcolor1}"
            # �����T�C�Y�̎w��1
            do {
                Clear-Host
                $logtext
                $textsize1 = Read-Host -Prompt "1�s��($($logtext[2].Substring(5,2)))�̕����T�C�Y(1�ȏ�̐���)"
            } until ($textsize1 -match "^[1-9]\d*$") # 1�ȏ�̐���
            $textsize1 | Out-File -FilePath option.txt -Append
            $logtext += "�����T�C�Y(1�s��): ${textsize1}"
            # �����F�̓���2
            do {
                Clear-Host
                $logtext
                $textcolor2 = Read-Host -Prompt "2�s��($($logtext[3].Substring(5,2)))�̐F(RGB(A)�J���[�R�[�h�܂��͐F�̖��O)A�͏���������Ə����܂�"
            } until ($textcolor2 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor2 -in $colors)
            $textcolor2 | Out-File -FilePath option.txt -Append
            if ($textcolor2 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor2 = $Matches[1]
            }
            $logtext += "�����F(2�s��): ${textcolor2}"
            # �����T�C�Y�̎w��2
            do {
                Clear-Host
                $logtext
                $textsize2 = Read-Host -Prompt "2�s��($($logtext[3].Substring(5,2)))�̕����T�C�Y(1�ȏ�̐���)"
            } until ($textsize2 -match "^[1-9]\d*$") # 1�ȏ�̐���
            $textsize2 | Out-File -FilePath option.txt -Append
            $logtext += "�����T�C�Y(2�s��): ${textsize2}"
            # �����F�̓���3
            do {
                Clear-Host
                $logtext
                $textcolor3 = Read-Host -Prompt "3�s��($($logtext[4].Substring(5,2)))�̐F(RGB(A)�J���[�R�[�h�܂��͐F�̖��O)A�͏���������Ə����܂�"
            } until ($textcolor3 -match "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -or $textcolor3 -in $colors)
            $textcolor3 | Out-File -FilePath option.txt -Append
            if ($textcolor3 -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2})?)$") {
                $textcolor3 = $Matches[1]
            }
            $logtext += "�����F(3�s��): ${textcolor3}"
            # �����T�C�Y�̎w��3
            do {
                Clear-Host
                $logtext
                $textsize3 = Read-Host -Prompt "3�s��($($logtext[4].Substring(5,2)))�̕����T�C�Y(1�ȏ�̐���)"
            } until ($textsize3 -match "^[1-9]\d*$") # 1�ȏ�̐���
            $textsize3 | Out-File -FilePath option.txt -Append
            $logtext += "�����T�C�Y(3�s��): ${textsize3}"

            # �������W�̎w��
            do {
                Clear-Host
                $logtext
                $textx = Read-Host -Prompt "������x���W(�����̐���)1�s�ڂ̍�����ɂȂ�܂�"
            } until ($textx -match "^(0|-?[1-9]\d*)$")
            $textx | Out-File -FilePath option.txt -Append
            $logtext += "����x���W: ${textx}"
            do {
                Clear-Host
                $logtext
                $texty = Read-Host -Prompt "������y���W(�����̐���)1�s�ڂ̏オ��ɂȂ�܂�"
            } until ($texty -match "^(0|-?[1-9]\d*)$")
            $texty | Out-File -FilePath option.txt -Append
            $logtext += "����y���W: ${texty}"

            # �s�Ԃ̎w��1
            do {
                Clear-Host
                $logtext
                $linespace1 = Read-Host -Prompt "1�s��($($logtext[2].Substring(5,2)))��2�s��($($logtext[3].Substring(5,2)))�̍s��(�����̐���)�v���r���[�����Ȃ��猟�����Ă�������"
            } until ($linespace1 -match "^(0|-?[1-9]\d*)$")
            $linespace1 | Out-File option.txt -Append
            $logtext += "�s��1: ${linespace1}"
            # �s�Ԃ̎w��2
            do {
                Clear-Host
                $logtext
                $linespace2 = Read-Host -Prompt "2�s��($($logtext[3].Substring(5,2)))��3�s��($($logtext[4].Substring(5,2)))�̍s��(�����̐���)�v���r���[�����Ȃ��猟�����Ă�������"
            } until ($linespace2 -match "^(0|-?[1-9]\d*)$")
            $linespace2 | Out-File option.txt -Append
            $logtext += "�s��2: ${linespace2}"



            # ���悢��^�C�}�[������Ă���
            # �\���t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $appearat = Read-Host -Prompt "�^�C�}�[���o���t���[��(0�ȏ�̐���)0�ōŏ�����\�����܂�"
                } until ($appearat -match "^(0|[1-9]\d*)$")
            } until ([int]$appearat -le $videoframes)
            $appearat | Out-File -FilePath option.txt -Append
            $logtext += "�\���t���[��: ${appearat}"
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
                            $starts += Read-Host -Prompt "�^�C�}�[���n�߂�t���[��(�ǂݍ��ݎ��̃t���[�Y���瓮���o�����t���[��)"
                        } until ($starts[0] -match "^([1-9]\d*)$")
                    } until ($starts[0] -le $videoframes)
                    $logtext += "�J�n�t���[��1: $($starts[0])"
                    do {
                        do {
                            $stops = @()
                            Clear-Host
                            $logtext
                            $stops += Read-Host -Prompt "�^�C�}�[���~�߂�t���[��(���[�h�����\�����ꂽ�t���[��)"
                        } until ($stops[0] -match "^([1-9]\d*)$")
                    } until ([int]$stops[0] -le $videoframes -and [int]$stops[0] -gt [int]$starts[0])
                    $logtext += "��~�t���[��1: $($starts[0])"
                    $counter += 1
                } else {
                    do {
                        $starts = @($starts[0..($counter - 2)])
                        Clear-Host
                        $logtext
                        $starts += Read-Host -Prompt "�^�C�}�[���n�߂�t���[��(�ǂݍ��ݎ��̃t���[�Y���瓮���o�����t���[��)`n$(if ($counter -ge 3) {"end�ŏI���A"})undo��1�߂�"
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
                                $logtext += "�J�n�t���[��$($counter): $($starts[-1])"
                                $flag1 = 0
                                do {
                                    do {
                                        $stops = @($stops[0..($counter - 2)])
                                        Clear-Host
                                        $logtext
                                        $stops += Read-Host -Prompt "�^�C�}�[���~�߂�t���[��(���[�h�����\�����ꂽ�t���[��)`ncancel�ŊJ�n�t���[���ɖ߂�"
                                    } until ($stops[-1] -match "^([1-9]\d*|cancel)$")
                                    switch ($stops[-1]) {
                                        "cancel" {
                                            $stops = @($starts[0..($counter - 2)])
                                            $flag1 = 1
                                        }
                                        default {
                                            if ([int]$stops[-1] -gt [int]$starts[-1]) {
                                                $logtext += "��~�t���[��$($counter): $($starts[-1])"
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
                        $logtext += "�J�n�t���[��${_}: $($starts[($_ - 1)])"
                        $logtext += "��~�t���[��${_}: $($stops[($_ - 1)])"
                    }
                }
            } until ($isend)
            0..($starts.Count - 1) | ForEach-Object {
                $starts[$_] | Out-File -FilePath option.txt -Append
                $stops[$_] | Out-File -FilePath option.txt -Append
            }
            "end" | Out-File -FilePath option.txt -Append

            # ��\���t���[��
            do {
                do {
                    Clear-Host
                    $logtext
                    $disappearat = Read-Host -Prompt "�^�C�}�[���\���ɂ���t���[���A-1�ōŌ�̃t���[����I�����܂�"
                } until ($disappearat -match "^(0|-1|[1-9]\d*)$")
            } until (([int]$disappearat -gt [int]$stops[-1] -and [int]$disappearat -le $videoframes) -or $disappearat -match "^-1$")
            $disappearat | Out-File -FilePath option.txt -Append
            if ($disappearat -match "^-1$") {
                $disappearat = $videoframes
            }
            $logtext += "��\���t���[��: ${disappearat}"

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
            Start-Process -FilePath "ffplay" -ArgumentList "-hide_banner -loglevel error -window_title ""�v���r���["" -loop 0 -i ""${inputfilename}"" -vf ""${timertext}""" -NoNewWindow
            do {
                Clear-Host
                $logtext
                $confirm = Read-Host -Prompt "����œ�����쐬���܂���?(yn)`nN��I�Ԃƃt�H���g�I���ɖ߂�܂�`n����܂ł̓��͂�option.txt�Ɏ����ŕۑ�����Ă��܂�"
            } until ($confirm -match "^[YyNn]$")
            if ($confirm -match "^[nN]$") {
                $logtext = @()
                $logtext += "���̓t�@�C��: ${inputfilename}"
            }
        } until ($confirm -match "^[yY]$")
        do {
            do {
                Clear-Host
                $logtext
                $outputfilename=Read-Host -Prompt "�g���q�Ȃ��̃t�@�C����(�g���q�ɂ�${outputextension}���t���܂�)"
            } until (-not ($outputfilename -match "[\u0022\u002a\u002f\u003a\u003c\u003e\u003f\u005c\u007c]") -and ("${defaultfolder}\${filename}").Length -le 250)
            if ((Test-Path "${defaultfolder}\${outputfilename}.${outputextension}")) {
                do {
                    Clear-Host
                    $logtext
                    Write-Host "���݂̃t�@�C����: ${defaultfolder}\${outputfilename}.${outputextension}"
                    $confirm=Read-Host -Prompt "�t�@�C�������ɑ��݂��܂��B�㏑�����܂���?(yn)"
                } until ($confirm -match "^[yYnN]$")
            }
        } until (-not (Test-Path "${defaultfolder}\${outputfilename}.${outputextension}") -or $confirm -match "^[yY]$")
        "${defaultfolder}\${outputfilename}.${outputextension}���쐬��..."
        $encodinglength = Measure-Command -Expression {
            Start-Process -FilePath "ffmpeg" -ArgumentList "-hide_banner -loglevel -8 -y -i ""${inputfilename}"" -vf ""${timertext}"" ${vencodesetting} ${aencodesetting} ""${defaultfolder}\${outputfilename}.${outputextension}""" -Wait -NoNewWindow
        }
        Write-Host "${defaultfolder}\${outputfilename}.${outputextension}��$((($encodinglength.Hours).ToString()).PadLeft(2,'0')):$((($encodinglength.Minutes).ToString()).PadLeft(2,'0')):$((($encodinglength.Seconds).ToString()).PadLeft(2,'0')).$((($encodinglength.Milliseconds).ToString()).PadLeft(3,'0'))�ŃG���R�[�h���܂���`nEnter�ŏI��"
        Read-Host
        exit
    }
} else {
    Write-Host "���݂���ps1�t�@�C����Windows�ł̂ݓ��삵�܂�`nEnter�ŏI��"
    Read-Host
}