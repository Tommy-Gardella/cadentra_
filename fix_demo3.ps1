$file = 'C:\Users\bigto\cadentra\how-it-works.html'
$bytes = [System.IO.File]::ReadAllBytes($file)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

# Replace mojibake for em dash (UTF-8 bytes E2 80 94 misread as cp1252 = a-euro-quote)
$emDashMojibake = [System.Text.Encoding]::UTF8.GetString([byte[]](0xC3, 0xA2, 0xC2, 0x80, 0xC2, 0x9C))
# Actually use the literal mojibake string via char codes
# a (U+00E2) + euro (U+20AC) + " (U+201C) = the mojibake for em dash
$mojibake1 = [char]0x00E2 + [char]0x20AC + [char]0x201C
$mojibake2 = [char]0x00C2 + [char]0x00B7

$content = $content.Replace($mojibake1, '&mdash;')
$content = $content.Replace($mojibake2, '&middot;')

[System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
Write-Host 'Done'
