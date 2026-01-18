<#
C#と同じように[Console]::SetCursorPosition(int left, int top)で毎回Clear-Hostをしなくてもログの書き換えができるんだって
関数にすればよさそう?
#>

Clear-Host
$b = 0
while (1) {
    $a = Read-Host "positive integer between -2147483648 and 2147483647"
    if ([int]::TryParse($a, [ref]$b)) {
        break
    }
    "Previous input $a was not correct." + " " * ([Console]::WindowWidth - ("Previous input $a was not correct.").Length)
    [Console]::SetCursorPosition(0, [Console]::CursorTop - 2)
    "positive integer between -2147483648 and 2147483647: " + " " * ([Console]::WindowWidth - 53)
    [Console]::SetCursorPosition(0, [Console]::CursorTop - 1)
}