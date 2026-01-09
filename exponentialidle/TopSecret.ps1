<#
Exponential Idle 隠し実績「トップシークレット」
実績を獲得していない状態でこの実績の説明を5回開くごとに現れる文字列を起点として
base64デコード→GUID部分を抜き出し→SHA-256に2回かける
ことで答えの文字列がえられる
#>

do {
    Clear-Host
    $text = Read-Host "Enter first text"
} until ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($text)) -match "^topsecret\.html\?id=([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})$")
$text1 = $Matches.1
Clear-Host
$stream = [IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($text1))
$hash = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLower()
$stream = [IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($hash))
$hash1 = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLower()
$stream.Dispose()
$text
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($text))
$text1
$hash
$hash1
"https://conicgames.github.io/exponentialidle/$([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($text)))"
"https://conicgames.github.io/exponentialidle/topsecret2.html?id=${hash}"
$hash1 | clip