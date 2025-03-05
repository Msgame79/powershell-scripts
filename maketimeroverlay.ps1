chcp 65001
$ErrorActionPreference = 'SilentlyContinue'

# 変数一覧(変更可能)
[string]$defaultfolder = "C:\Users\Msgames79\Videos" # デフォルト: $PSScriptRoot
[string]$vencodesetting = "" # デフォルト: "-c:v libx264 -qp 21" フィルターをかけるので"-c:v copy"は使えない
[string]$vencodesetting = "" # デフォルト: "-c:a " デフォルトではあえて再エンコードするように書いているが、できるなら"-c:a copy"が良い
[string]$outputextension = "mp4" # デフォルト: "mp4" デフォルトがmp4向けのエンコード設定のため。ただし上のエンコード設定によっては変える必要あり、あとここで編集させているのはすぐ上にエンコード設定があるから
<#
いろんなエンコードメモ
ffplayがあるから基本的にどんなコーデックでもいい
それなら


#>

# 変数一覧(変更不可能)
[array]$colors = @()
[array]$inputfilelist = @()
[string]$inputfilename = ""

function versioncheck { # 特定以上のメジャーバージョンを使うよう指示
    param ( # 引数一覧(コンマで区切るのを忘れない!)
        [int]$a = 5 # 引数を取らなかったときの初期値
    )
    if ($PSVersionTable.PSVersion.Major -lt $a) {
        Write-Host "バージョン${a}以上のPowerShellで実行してください`nEnterで終了"
        Read-Host
        Start-Process "https://github.com/PowerShell/PowerShell/releases/latest"
        Exit
    }
}
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
    versioncheck 5
    # 動画選択
    $inputfilelist = Get-ChildItem -Name | Where-Object {$_ -match "^.+\.(mp4|mov|mkv|avi|webm|mpg|flv|wmv|ogv|asf)$"}
    do {
        Clear-Host
        $inputfilelist
        $inputfilename = Read-Host -Prompt "動画ファイルを選択"
    } until ($inputfilename -in $inputfilelist)
} else {
    Write-Host "現在このps1ファイルはWindowsでのみ動作します`nEnterで終了"
    Read-Host
    exit
}