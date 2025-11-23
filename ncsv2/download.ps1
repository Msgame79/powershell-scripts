if ($PSVersionTable.PSVersion.Major -lt 7)
{
    "Run this script on Version 7 or above`nhttps://github.com/PowerShell/PowerShell/releases/latest"

    Read-Host
    exit(1)
}
$ErrorActionPreference = 'SilentlyContinue'
$downloadlength = Measure-Command {
    Set-Location $PSScriptRoot
    Write-Host "Cleaning up files(1/8)..." -NoNewline
    while ((Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics)$"}).Count)
    {
        Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics)$"} | Remove-Item -Recurse -Force
    }
    while ((Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(credits\.txt|wget2\.exe|7zr\.exe|ffmpeg\.7z)$"}).Count)
    {
        Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(credits\.txt|wget2\.exe|7zr\.exe|ffmpeg\.7z)$"} | Remove-Item -Force -Recurse
    }
    Write-Host "Done`nSetting up files(2/8)..." -NoNewline
    New-Item -ItemType Directory "musics","musics\temp" | Out-Null
    Invoke-RestMethod "https://github.com/rockdaboot/wget2/releases/latest/download/wget2.exe" -OutFile "wget2.exe"
    Invoke-RestMethod "https://www.7-zip.org/a/7zr.exe" -OutFile "7zr.exe"
    Invoke-RestMethod ("https://github.com/GyanD/codexffmpeg/releases/download/"+[regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"),"\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value+"/ffmpeg-"+[regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"),"\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value+"-full_build.7z") -OutFile "ffmpeg.7z"
    .\7zr.exe e -r -omusics\temp ffmpeg.7z ffmpeg.exe | Out-Null
    Write-Host "Done`nDownloading HTMLs of each track(3/8)..." -NoNewline
    .\wget2.exe -q --max-threads (Get-ComputerInfo).CsNumberOfLogicalProcessors -r -X "artist,static,track,usage-policy" --reject-regex "artists|index|music|usage-policy|privacy|contact|AroundUs|about|favicon|robots" --no-robots ncs.io
    Write-Host "Done`nExtracting data from HTMLs(4/8)..." -NoNewline
    Set-Location "ncs.io"
    $uuids = [System.Collections.ArrayList]::New()
    $artists = [System.Collections.ArrayList]::New()
    $genres = [System.Collections.ArrayList]::New()
    $tracks = [System.Collections.ArrayList]::New()
    $credits = [System.Collections.ArrayList]::New()
    Get-ChildItem | ForEach-Object {
        $a = New-Object -ComObject HTMLfile
        $a.write([system.text.encoding]::Unicode.GetBytes((Get-Content $_ -Raw)))
        $uuids.AddRange(@(@($a.getElementsByClassName("btn black")).nameprop)) | Out-Null
        $artists.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-artist=\`" *(.+?[^\\])\`"").Groups[-1].Value) | Out-Null
        $genres.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-genre=\`" *(.+?[^\\])\`"").Groups[-1].Value) | Out-Null
        $tracks.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-track=\`" *(.+?[^\\])\`"").Groups[-1].Value) | Out-Null
        $credits.Add(@($a.GetElementsByClassName("p-copy")).innerText) | Out-Null
        if ($uuids[-1] -match "^i_")
        {
            $artists.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-artist=\`" *(.+?[^\\])\`"").Groups[-1].Value) | Out-Null
            $genres.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-genre=\`" *(.+?[^\\])\`"").Groups[-1].Value) | Out-Null
            $tracks.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-track=\`" *(.+?[^\\])\`"").Groups[-1].Value + " (Instrumental)") | Out-Null
        }
        Remove-Variable a
    }
    Set-Location $PSScriptRoot
    Write-Host "Done`nGenerating urls.txt(5/8)..." -NoNewline
    $uuids  | ForEach-Object {"https://ncs.io/track/download/${_}"} | Out-File "musics\temp\urls.txt"
    Write-Host "Done`nGenerating credits.txt..." -NoNewline
    $credits | Out-File "credits.txt"
    Remove-Variable "credits"
    Set-Location "musics\temp"
    Write-Host "Done`nDownloading tracks(6/8)..." -NoNewline
    ..\..\wget2.exe -q --max-threads (Get-ComputerInfo).CsNumberOfLogicalProcessors --no-robots -i urls.txt
    while ((Get-Childitem -Name -File | Where-Object {$_ -match "^(urls\.txt)$"}).Count)
    {
        Get-Childitem -Name -File | Where-Object {$_ -match "^(urls\.txt)$"} | Remove-Item -Force
    }
    Write-Host "Done`nRe-encoding tracks for more accurate data(7/8)..." -NoNewline
    for ($b - 0 ; $b -lt $uuids.count ; $b++)
    {
        Start-Process ".\ffmpeg.exe" " -v -8 -i ""$($uuids[$b])"" -metadata artist=""$($artists[$b])"" -metadata title=""$($tracks[$b])"" -metadata genre=""$($genres[$b])"" -map a:0 -c:a libmp3lame -b:a 320k ""..\$($uuids[$b]).mp3""" -NoNewWindow
    }
    Set-Location $PSScriptRoot
    Write-Host "Done`nCleaning up files(8/8)..." -NoNewline
    while ((Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics\\temp)$"}).Count)
    {
        Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics\\temp)$"} | Remove-Item -Recurse -Force
    }
    while ((Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(wget2\.exe|7zr\.exe|ffmpeg\.7z)$"}).Count)
    {
        Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(wget2\.exe|7zr\.exe|ffmpeg\.7z)$"} | Remove-Item -Force -Recurse
    }
}
Write-Host "Done`nI completed this script in $((($downloadlength.Hours).ToString()).PadLeft(2,'0')):$((($downloadlength.Minutes).ToString()).PadLeft(2,'0')):$((($downloadlength.Seconds).ToString()).PadLeft(2,'0')).$((($downloadlength.Milliseconds).ToString()).PadLeft(3,'0'))`nEnter to exit"
Read-Host