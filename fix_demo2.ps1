$file = 'C:\Users\bigto\cadentra\how-it-works.html'
$bytes = [System.IO.File]::ReadAllBytes($file)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

# Fix each broken string individually using index-based replacement
$fixes = @(
    @{ From = 'A live preview of the training dashboard'; To = 'A live preview of the training dashboard' },
    @{ From = 'Cadentra'; To = 'Cadentra' },
    @{ From = 'Training Dashboard &nbsp;'; To = 'Training Dashboard &nbsp;' },
    @{ From = 'Week 6 of 16 &nbsp;'; To = 'Week 6 of 16 &nbsp;' },
    @{ From = "This Week's Training"; To = "This Week's Training" }
)

# The real fix: replace the mojibake sequences with correct HTML entities
# â€" is the UTF-8 mojibake for em-dash (—)
# Â· is the mojibake for middle dot (·)
$content = $content -replace 'â€"', '&mdash;'
$content = $content -replace 'Â·', '&middot;'

[System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
Write-Host 'Done'
