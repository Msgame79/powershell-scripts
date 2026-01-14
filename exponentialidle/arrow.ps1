<#
Exponential Idle ミニゲームの1つ、矢印パズルを総当たりで解く。
#>
Clear-Host
while (1) {
    switch -regex (Read-Host "Difficulty") {
        "easy" { # 3×3、4方向
        }
        "normal" { # 4×4、4方向
        }
        "hard" { # 3×3、2方向
        }
        "expert" { # 3×3、6方向
        }
        Default {
            Clear-Host
            "Wrong"
        }
    }
}