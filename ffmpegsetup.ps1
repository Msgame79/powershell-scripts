"install ffmpeg without using winget"

Set-Location $PSScriptRoot
Invoke-RestMethod -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z" -OutFile "ffmpeg.7z"
