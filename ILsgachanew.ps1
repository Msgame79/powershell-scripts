chcp 65001

<#
CSVの書式(CategoriesType)
normal(PinchとGlitchlessの存在を2進数判定)
0=Pinch、Glitchlessなし    (00)
1=Pinchなし、Glitchlessあり(01)
2=Pinchあり、Glitchlessなし(10)
3=Pinch、Glitchlessあり    (11)
workshop(プレイできないカテゴリ(Any% Glitched,Any% Glitchless,All Checkpoint% Glitched,All Checkpoint% Glitchless)を2進数判定)
0=なし                                                              (0000)
1=All Checkpoint% Glitchless                                        (0001)
2=All Checkpoint% Glitched                                          (0010)
3=All Checkpoint% Glitched,All Checkpoint% Glitchless               (0011)
4=Any% Glitchless                                                   (0100)
5=Any% Glitchless,All Checkpoint% Glitchless                        (0101)
6=Any% Glitchless,All Checkpoint% Glitched                          (0110)
7=Any% Glitchless,All Checkpoint% GlitchedAll Checkpoint% Glitchless(0111)
8=Any% Glitched                                                     (1000)
9=Any% Glitched,All Checkpoint% Glitchless                          (1001)
10=Any% Glitched,All Checkpoint% Glitched                           (1010)
11=Any% Glitched,All Checkpoint% Glitched,All Checkpoint% Glitchless(1011)
12=Any% Glitched,Any% Glitchless                                    (1100)
13=Any% Glitched,Any% Glitchless,All Checkpoint% Glitchless         (1101)
14=Any% Glitched,Any% Glitchless,All Checkpoint% Glitched           (1110)
15は全てプレイできないことになるので存在しない                      (1111)
#>

$categories=@(
    'Any%'
    'Checkpoint%'
    'Any% Pinch'
    'Checkpoint% Pinch'
    'Any% No Pinch'
    'Checkpoint% No Pinch'
    'Any% Glitchless'
    'Checkpoint% Glitchless'
    'Any% Glitches Allowed'
    'Checkpoint% Glitches Allowed'
    # below here are used for workshop
    'Any% Glitched'
    'All Checkpoints% Glitched'
    'Any% Glitchless'
    'All Checkpoints% Glitchless'
)

Clear-Host

$list=""

# Githubからダウンロードして使うなら↓のコメントアウトを解除(遅い)
# $list = Invoke-RestMethod -URI "https://raw.githubusercontent.com/Msgame79/powershell-scripts/refs/heads/main/ILsListNew.csv"

# csvをどこかに保存して使うなら↓のコメントアウトを解除(速い)ダウンロードはhttps://raw.githubusercontent.com/Msgame79/powershell-scripts/refs/heads/main/ILsListNew.csv
$list = Get-Content -Path .\ILsListNew.csv -Encoding utf8NoBOM

if ($list -eq "") {

    "csv取得部分をコメントアウト解除してください。Enterで終了。"

    Read-Host

    exit

}

$csvlist = $list | ConvertFrom-Csv

$levellist = @()

foreach ($row in $csvlist) {

    $levellist += ,@($row.PSObject.Properties.Value)
}

""

$levelscount=$levellist.Count-1

$levelindex=Get-SecureRandom -Minimum 0 -Maximum $levelscount

$level=$levellist[$levelindex]

$levelname=$level[0]

$leveltype=$level[1]

[string]$levelid=$level[2]

$levelname

$leveltype

$levelid

if ($levelid -match "^[0-9]{1,5}$") { #normal

    switch ($leveltype) {

        0 {

            

        }

        1 {



        }

        2 {



        }

        3 {



        }

    }

} else { # workshop

    "workshop"

}