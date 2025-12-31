Set-Location $PSScriptRoot
if (-not (Test-Path .\ffmpeg.exe) -or -not (Test-Path .\ffplay.exe)) {
    while ((Get-Childitem -Name -File -Recurse | Where-Object { $_ -match "^(7zr\.exe|ffmpeg\.7z|ffmpeg\.exe|ffplay\.exe)$" }).Count) {
        Get-Childitem -Name -File -Recurse | Where-Object { $_ -match "^(7zr\.exe|ffmpeg\.7z|ffmpeg\.exe|ffplay\.exe)$" } | Remove-Item -Force -Recurse
    }
    Invoke-RestMethod "https://www.7-zip.org/a/7zr.exe" -OutFile "7zr.exe"
    Invoke-RestMethod ("https://github.com/GyanD/codexffmpeg/releases/download/" + [regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"), "\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value + "/ffmpeg-" + [regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"), "\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value + "-full_build.7z") -OutFile "ffmpeg.7z"
    .\7zr.exe e -r ffmpeg.7z ffmpeg.exe ffplay.exe | Out-Null

    while ((Get-Childitem -Name -File -Recurse | Where-Object { $_ -match "^(7zr\.exe|ffmpeg\.7z)$" }).Count) {
        Get-Childitem -Name -File -Recurse | Where-Object { $_ -match "^(7zr\.exe|ffmpeg\.7z)$" } | Remove-Item -Force -Recurse
    }
}
$colors = (.\ffmpeg.exe -hide_banner -colors)[1..(.\ffmpeg.exe -hide_banner -colors).Count] | ForEach-Object { $_.SubString(0, $_.Length - 7).Trim() }
while ($true) {
    $logtext = "QRコードに埋め込む文字列(エスケープ無し)"
    [string]$text = ""
    while ($text -eq "") {
        Clear-Host
        $text = Read-Host $logtext
    }
    $text = [Regex]::Replace([Regex]::Replace([Regex]::Replace([Regex]::Replace($text, "\\", "\\\\"), " ", "\ "), ":", "\:"), "'", "'\\\''")
    $logtext += ": ${text}`nQRコードのサイズ(40-4000px)"
    $size = 0
    while (40..4000 -notcontains $size) {
        Clear-Host
        $size = Read-Host $logtext
    }
    $logtext += ": ${size}`n余白(0-400px)"
    $pad = -1
    while (0..400 -notcontains $pad) {
        Clear-Host
        $pad = Read-Host $logtext
    }
    $logtext += ": ${pad}`n前景色(RGB(A)カラーコードまたは色の名前)"
    $fgcolor = ""
    while ($fgcolor -notmatch "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -and $colors -notcontains $fgcolor) {
        Clear-Host
        $fgcolor = Read-Host $logtext
    }
    if ($fgcolor -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2}))?$") {
        $fgcolor = $Matches[1]
    }
    $logtext += ": ${fgcolor}`n背景色(RGB(A)カラーコードまたは色の名前)"
    $bgcolor = ""
    while ($bgcolor -notmatch "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" -and $colors -notcontains $bgcolor -or $bgcolor -eq $fgcolor) {
        Clear-Host
        $bgcolor = Read-Host $logtext
    }
    if ($bgcolor -match "^#?([0-9a-fA-F]{6}([0-9a-fA-F]{2}))?$") {
        $bgcolor = $Matches[1]
    }
    $total = [int]$size + [int]$pad
    $fppid = (Start-Process ".\ffplay.exe" "-hide_banner -loglevel -8 -f lavfi -window_title ""プレビュー"" -i ""color=r=1:s=${total}x${total}:c=${bgcolor}"" -vf ""qrencode=expansion=none:text='${text}':bc='${bgcolor}':fc='${fgcolor}':text='${text}':q=${size}"":x=${pad}/2:y=${pad}/2" -PassThru -NoNewWindow).Id
    $logtext += ": ${bgcolor}`nこれで作成しますか?(YN)"
    $confirm = ""
    while ($confirm -notmatch "^[yYnN]$") {
        Clear-Host
        $confirm = Read-Host $logtext
    }
    Stop-Process -Id $fppid
    if ($confirm -match "^[yY]$") {
        $logtext += ": ${confirm}`n出力ファイル名(拡張子なし)"
        $filename = ""
        while ([System.IO.Path]::GetFullPath("${filename}.png").Length -gt 260 -or [system.string]::concat([System.IO.Path]::GetInvalidFileNameChars() + [System.IO.Path]::GetInvalidPathChars()).contains($filename)) {
            Clear-Host
            $filename = Read-Host $logtext
        }
        break
    }
}
.\ffmpeg.exe -y -hide_banner -loglevel -8 -f lavfi -i "color=r=1:s=${total}x${total}:c=${bgcolor}" -vf "qrencode=expansion=none:text='${text}':bc='${bgcolor}':fc='${fgcolor}':text='${text}':q=${size}:x=${pad}/2:y=${pad}/2" -frames:v 1 -c:v png "$filename.png"