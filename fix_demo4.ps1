$file = 'C:\Users\bigto\cadentra\how-it-works.html'
$bytes = [System.IO.File]::ReadAllBytes($file)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

# Em dash mojibake: UTF-8 bytes E2 80 94 read as cp1252 = a + euro + right-double-quote (U+201D)
$mojibakeEmDash = [char]0x00E2 + [char]0x20AC + [char]0x201D
# Middle dot mojibake: UTF-8 bytes C2 B7 read as cp1252 = A-with-circ + middle-dot
$mojibakeMiddot = [char]0x00C2 + [char]0x00B7

Write-Host "Found em-dash mojibake: $($content.Contains($mojibakeEmDash))"
Write-Host "Found middot mojibake: $($content.Contains($mojibakeMiddot))"

$content = $content.Replace($mojibakeEmDash, '&mdash;')
$content = $content.Replace($mojibakeMiddot, '&middot;')

[System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
Write-Host 'Done'
