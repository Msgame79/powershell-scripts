chcp 65001

Set-Location $PSScriptRoot

Clear-Host

[string]$downloadfolder = ".."

"format`nhttps://ncs.io/track/download/uuid`nhttps://ncs.io/track/download/i_uuid`n"

[string]$url=Read-Host -Prompt "Enter URL"

if ($url -match "^https://ncs.io/track/download/[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$") {

    $uuid=$url.Substring(30,36)

} elseif ($url -match "^https://ncs.io/track/download/i_[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$") {

    $uuid=$url.Substring(32,36)

} else {

    "Invalid`nEnter to exit"

    Read-Host

    exit

}

if (Test-Path "$downloadfolder\$uuid.mp3") {

    "Already exists`nEnter to exit"

    Read-Host

    exit

}

Try {

    Invoke-WebRequest -Uri "https://ncs.io/track/download/$uuid" -OutFile ".\$uuid.mp3"

    $headers=Invoke-WebRequest -Uri "https://ncs.io/track/download/$uuid" -Method Head

    [String]$cd=$headers.Headers["Content-Disposition"]

    $title=$cd.SubString(22,$cd.Length - 41)

    ffmpeg -hide_banner -loglevel -8 -y -i "$uuid.mp3" -metadata Title="$title" -c copy "$downloadfolder\$uuid.mp3"

} Catch {

    "Couldn't download`nEnter to exit"

    Read-Host

    exit

}

Do {

    Try {

        $flag=$true

        Remove-Item -Path ".\$uuid.mp3"

    } Catch {

        $flag=$false

    }

} until ($flag)

Try {

    Invoke-WebRequest -Uri "https://ncs.io/track/download/i_$uuid"-OutFile ".\i_$uuid.mp3"

    ffmpeg -hide_banner -loglevel -8 -y -i "i_$uuid.mp3" -metadata Title="$title (Instrumental)" -c copy "$downloadfolder\i_$uuid.mp3"

    Remove-Item -Path ".\i_$uuid.mp3"

    "Downloaded successfully`nEnter to exit"

    Read-Host

    exit

} Catch {

    "Instrumental does not exist(not a error)`nEnter to exit"

    Read-Host

    exit

}