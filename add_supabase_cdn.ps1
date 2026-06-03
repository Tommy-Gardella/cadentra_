$pages = @('index.html', 'about.html', 'how-it-works.html', 'contact.html')
$base  = 'C:\Users\bigto\cadentra'

$oldScript = '  <script src="script.js"></script>'
$newScript  = '  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>' + "`r`n" +
              '  <script src="js/supabase-client.js"></script>' + "`r`n" +
              '  <script src="script.js"></script>'

foreach ($page in $pages) {
  $path    = Join-Path $base $page
  $bytes   = [System.IO.File]::ReadAllBytes($path)
  $content = [System.Text.Encoding]::UTF8.GetString($bytes)

  if ($content.Contains($oldScript)) {
    $content = $content.Replace($oldScript, $newScript)
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $page"
  } else {
    Write-Host "Skipped (script tag not found): $page"
  }
}
Write-Host 'Done'
