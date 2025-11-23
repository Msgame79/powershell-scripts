Set-Location $PSScriptRoot
while ((Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics)$"}).Count)
{
    Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics)$"} | Remove-Item -Recurse -Force
}
while ((Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(credits\.txt|wget2\.exe|7zr\.exe|ffmpeg\.7z)$"}).Count)
{
    Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(credits\.txt|wget2\.exe|7zr\.exe|ffmpeg\.7z)$"} | Remove-Item -Force -Recurse
}
New-Item -ItemType Directory "musics","musics\temp" | Out-Null
Invoke-RestMethod "https://github.com/rockdaboot/wget2/releases/latest/download/wget2.exe" -OutFile "wget2.exe"
Invoke-RestMethod "https://www.7-zip.org/a/7zr.exe" -OutFile "7zr.exe"
Invoke-RestMethod ("https://github.com/GyanD/codexffmpeg/releases/download/"+[regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"),"\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value+"/ffmpeg-"+[regex]::Matches((Invoke-RestMethod "https://github.com/GyanD/codexffmpeg/tags"),"\d{4}-\d{2}-\d{2}-git-[0-9a-f]+")[0].Value+"-full_build.7z") -OutFile "ffmpeg.7z"
.\7zr.exe 
.\wget2.exe --max-threads (Get-ComputerInfo).CsNumberOfLogicalProcessors -r -X "artist,static,track,usage-policy" --reject-regex "artists|index|music|usage-policy|privacy|contact|AroundUs|about|favicon|robots" --no-robots ncs.io
Set-Location "ncs.io"
$uuids = [System.Collections.ArrayList]::New()
$artists = [System.Collections.ArrayList]::New()
$genres = [System.Collections.ArrayList]::New()
$tracks = [System.Collections.ArrayList]::New()
$credits = [System.Collections.ArrayList]::New()
Get-ChildItem | ForEach-Object {
    $a = New-Object -ComObject HTMLfile
    $a.write([system.text.encoding]::Unicode.GetBytes((Get-Content $_ -Raw)))
    $uuids.AddRange(@(@($a.getElementsByClassName("btn black")).nameprop))
    $artists.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-artist=\`" *(.+?[^\\])\`"").Groups[-1].Value)
    $genres.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-genre=\`" *(.+?[^\\])\`"").Groups[-1].Value)
    $tracks.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-track=\`" *(.+?[^\\])\`"").Groups[-1].Value)
    $credits.Add(@($a.GetElementsByClassName("p-copy")).innerText)
    if ($uuids[-1] -match "^i_")
    {
        $artists.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-artist=\`" *(.+?[^\\])\`"").Groups[-1].Value)
        $genres.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-genre=\`" *(.+?[^\\])\`"").Groups[-1].Value)
        $tracks.Add([Regex]::matches(@($a.getElementsByClassName("btn black")).outerHTML,"data-track=\`" *(.+?[^\\])\`"").Groups[-1].Value + " (Instrumental)")
    }
    Remove-Variable a
}
Set-Location $PSScriptRoot
$uuids  | ForEach-Object {"https://ncs.io/track/download/${_}"} | Out-File "musics\temp\uuids.txt"
$credits | Out-File "credits.txt"
#Remove-Variable "uuids","credits"
Set-Location "musics\temp"
..\..\wget2.exe --max-threads (Get-ComputerInfo).CsNumberOfLogicalProcessors --no-robots -i uuids.txt
while ((Get-Childitem -Name -File | Where-Object {$_ -match "^(uuids\.txt)$"}).Count)
{
    Get-Childitem -Name -File | Where-Object {$_ -match "^(uuids\.txt)$"} | Remove-Item -Force
}
for ($b = 0; $b -lt $uuids.Count; $b++)
{
    Start-Process ".\ffmpeg.exe" " -loglevel -8 -i ""$($uuids[$b])"" -metadata artist=""$($artists[$b])"" -metadata title=""$($tracks[$b])"" -metadata genre=""$($genres[$b])"" -map a:0 -c copy ""..\$($uuids[$b]).mp3""" -NoNewWindow
}
Set-Location $PSScriptRoot
while ((Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics\\temp)$"}).Count)
{
    Get-Childitem -Name -Directory -Recurse | Where-Object {$_ -match "^(ncs\.io|musics\\temp)$"} | Remove-Item -Recurse -Force
}
while ((Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(wget2\.exe|7zr\.exe|ffmpeg\.7z)$"}).Count)
{
    Get-Childitem -Name -File -Recurse | Where-Object {$_ -match "^(wget2\.exe|7zr\.exe|ffmpeg\.7z)$"} | Remove-Item -Force -Recurse
}