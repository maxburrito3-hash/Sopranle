# Tiny static file server for Sopranle (no Python or Node needed).
# YouTube embeds refuse to play on pages opened from disk (file://), so the game
# has to be served over http://localhost.
param(
  [int]$Port = 8000,
  [switch]$NoBrowser
)

$root = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path)).TrimEnd('\') + '\'
$prefix = "http://localhost:${Port}/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
  $listener.Start()
} catch {
  Write-Host "Could not start the server on port ${Port}: $($_.Exception.Message)"
  Write-Host "Is it already running? Try opening $prefix in your browser."
  exit 1
}

Write-Host "Sopranle is running at $prefix"
Write-Host "Keep this window open while you play. Press Ctrl+C to stop."
if (-not $NoBrowser) { Start-Process $prefix }

$mime = @{
  '.html' = 'text/html; charset=utf-8'; '.js' = 'text/javascript; charset=utf-8'
  '.css' = 'text/css; charset=utf-8'; '.json' = 'application/json; charset=utf-8'
  '.png' = 'image/png'; '.jpg' = 'image/jpeg'; '.svg' = 'image/svg+xml'; '.ico' = 'image/x-icon'
}

try {
  while ($listener.IsListening) {
    $pending = $listener.GetContextAsync()
    # Wait in short slices so Ctrl+C can stop the server.
    while (-not $pending.AsyncWaitHandle.WaitOne(500)) { }
    $ctx = $pending.GetAwaiter().GetResult()
    $res = $ctx.Response
    try {
      $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
      if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
      $full = [IO.Path]::GetFullPath([IO.Path]::Combine($root, $rel))
      if ($full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -and [IO.File]::Exists($full)) {
        $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
        $res.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
        $res.Headers['Cache-Control'] = 'no-cache'
        $bytes = [IO.File]::ReadAllBytes($full)
      } else {
        $res.StatusCode = 404
        $res.ContentType = 'text/plain; charset=utf-8'
        $bytes = [Text.Encoding]::UTF8.GetBytes('Not found')
      }
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {
      Write-Host "Request failed: $($_.Exception.Message)"
    } finally {
      $res.Close()
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
