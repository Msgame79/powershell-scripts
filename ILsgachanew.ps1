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
    'Any%' # 0
    'Checkpoint%' # 1
    'Any% Pinch' # 2
    'Checkpoint% Pinch' # 3
    'Any% No Pinch' # 4
    'Checkpoint% No Pinch' # 5
    'Any% Glitchless' # 6
    'Checkpoint% Glitchless' # 7
    'Any% Glitches Allowed' # 8
    'Checkpoint% Glitches Allowed' # 9
    # below here are used for workshop
    'Any% Glitched' # 10
    'All Checkpoints% Glitched' # 11
    'Any% Glitchless' # 12
    'All Checkpoints% Glitchless' # 13
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

While ($true) {

    $levelindex=Get-SecureRandom -Minimum 0 -Maximum $levelscount

    $levelinfo=$levellist[$levelindex]

    $levelname=$levelinfo[0]

    $leveltype=$levelinfo[1]

    [string]$levelid=$levelinfo[2]

    if ($levelid -match "^[0-9]{1,3}$") { #normal

        switch -Exact ($leveltype) {

            0 {

                $categoryindex=0, 1 | Get-SecureRandom

            }

            1 {

                $categoryindex=6, 7, 8, 9 | Get-SecureRandom

            }

            2 {

                $categoryindex=2, 3, 4, 5 | Get-SecureRandom

            }

            3 {

                $categoryindex=2, 3, 4, 5, 6, 7 | Get-SecureRandom

            }

        }

    } else { # workshop

        switch -Exact ($leveltype) {

            0 {

                $categoryindex=10, 11, 12, 13 | Get-SecureRandom

            }

            1 {

                $categoryindex=10, 11, 12 | Get-SecureRandom

            }

            2 {

                $categoryindex=10, 11, 13 | Get-SecureRandom

            }

            3 {

                $categoryindex=10, 11 | Get-SecureRandom

            }

            4 {

                $categoryindex=10, 12, 13 | Get-SecureRandom

            }

            5 {

                $categoryindex=10, 12 | Get-SecureRandom

            }

            6 {

                $categoryindex=10, 13 | Get-SecureRandom

            }

            7 {

                $categoryindex=10

            }

            8 {

                $categoryindex=11, 12, 13 | Get-SecureRandom

            }

            9 {

                $categoryindex=11, 12 | Get-SecureRandom

            }

            10 {

                $categoryindex=11, 13 | Get-SecureRandom

            }

            11 {

                $categoryindex=11

            }

            12 {

                $categoryindex=12, 13 | Get-SecureRandom

            }

            13 {

                $categoryindex=12

            }

            14 {

                $categoryindex=13

            }

        }

    }

    $category=$categories[$categoryindex]

    $pbindex=$categoryindex * 2 + 3

    $wrindex=$categoryindex * 2 + 4

    $pb=$levelinfo[$pbindex]

    $wr=$levelinfo[$wrindex]

    Do { #おなじみの成功するまで書き込み

        Try {

            $flag=$true

            "$levelname $category`n$levelid`nPB: $pb`nWR: $wr"

            "$levelname $category`nPB: $pb|WR: $wr" | Out-File -FilePath "..\sources\ILsgacha.txt" -Encoding utf8NoBOM

        } Catch {

            $flag=$false

        }

    } Until ($flag)

    "Enterで再抽選、Ctrl+Cで終了"

    Read-Host

    Clear-Host

}

$categories
