chcp 65001

<#
使い方

PowerShell Core 7以上で動作します。インストールしていない場合はhttps://github.com/PowerShell/PowerShell/releases でwindows用インストーラーをダウンロードまたはwingetでインストール(winget install Microsoft.PowerShellまたはwinget install Microsoft.PowerShell.Preview)
ILsガチャを回してILsgacha.txt(160行目で変更可能)にリアルタイムで書き込みます。OBSのテキストソースで読み込むことができます。
#>

#同じフォーマットで追加可能
$categories = @(
    'Any%'
    'Checkpoint%'
)

$subcategories01 = @(
    'Glitchless'
    'Glitches Allowed'
)

$subcategories10 = @(
    'Pinch'
    'No Pinch'
)

$subcategories11 = @(
    'Pinch'
    'No Pinch'
    'Glitchless'
)

<#
ILslist.csvの内容。csv(UTF-8 Without BOM)で保存すれば75行目をコメントアウトして高速化できます。

"Name","Categories<Pinch,Glitchless>","levelid"
"Mansion","10","0"
"Train","10","1"
"Carry","00","2"
"Mountain","10","3"
"Demolition","01","4"
"Castle","00","5"
"Water","01","6"
"Power Plant","01","7"
"Aztec","01","8"
"Dark","01","9"
"Steam","11","10"
"Ice","01","11"
"Reprise","00","12"
"Thermal","01","100"
"Factory","01","101"
"Golf","01","102"
"City","01","103"
"Forest","01","104"
"Laboratory","01","105"
"Lumber","01","106"
"Red Rock","01","107"
"Tower","11","108"
"Miniature","01","109"
"Copper World","01","110"
"Port","01","112"
"Underwater","01","113"
"Dockyard","01","114"
"Museum","01","115"
"Hike","01","116"
#>

Clear-Host

$list=""

# Google Driveからダウンロードして使うなら↓のコメントアウトを解除(遅い)
$list = Invoke-RestMethod -URI "https://drive.usercontent.google.com/u/0/uc?id=1flE518Q2o2fVXdnEpWS-S_8-d4N-86hk&export=download"

# csvをどこかに保存して使うなら↓のコメントアウトを解除(速い)ダウンロードはhttps://drive.usercontent.google.com/u/0/uc?id=1flE518Q2o2fVXdnEpWS-S_8-d4N-86hk&export=download
# $list = Get-Content -Path .\ILslist.csv -Encoding utf8NoBOM

if ($list -eq "") {

    "72行目もしくは75行目をコメントアウトしてください。Enterで終了。"

    Read-Host

    exit

}

$csvlist = $list | ConvertFrom-Csv

$levellist = @()

foreach ($row in $csvlist) {

    $levellist += ,@($row.PSObject.Properties.Value)
}

While ($true) {

    $randomid=Get-SecureRandom -Minimum 0 -Maximum $levellist.Count

    $level=$levellist[$randomid][0]

    $levelid=$levellist[$randomid][2]

    $randomcategory=Get-SecureRandom -Minimum 0 -Maximum $categories.Count

    $category=$categories[$randomcategory]

    switch -Exact ($levellist[$randomid][1]) {

        "00" {

            $subcategory=""

        }

        "01" {

            $subcategoryid=Get-SecureRandom -Minimum 1 -Maximum $subcategories01.Count

            $subcategory=" "+$subcategories01[$subcategoryid]

        }

        "10" {

            $subcategoryid=Get-SecureRandom -Minimum 1 -Maximum $subcategories10.Count

            $subcategory=" "+$subcategories10[$subcategoryid]

        }

        "11" {

            $subcategoryid=Get-SecureRandom -Minimum 1 -Maximum $subcategories11.Count

            $subcategory=" "+$subcategories11[$subcategoryid]

        }

    }

    "$level ($levelid) $category$subcategory"

    Do {

        Try {

            $flag=$true

            "$level $category$subcategory" | Out-File -FilePath ".\ILsgacha.txt" -Encoding utf8NoBOM

        } Catch {

            $flag=$false

        }
    
    } Until ($flag)

    "Enterで再抽選、Ctrl+Cで終了"

    Read-Host

    Clear-Host

}
