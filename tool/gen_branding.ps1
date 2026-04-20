$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path "$PSScriptRoot\..\assets\branding" | Out-Null
Add-Type -AssemblyName System.Drawing
$outDir = Join-Path $PSScriptRoot '..\assets\branding'

function Draw-RFIcon([int]$w) {
  $bmp = New-Object System.Drawing.Bitmap $w, $w
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(255, 1, 34, 23))
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pad = [int]($w * 0.08)
  $path.AddEllipse($pad, $pad, $w - 2 * $pad, $w - 2 * $pad)
  $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $w
  $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(255, 1, 50, 32),
    [System.Drawing.Color]::FromArgb(255, 0, 26, 16),
    45.0)
  $g.FillPath($gb, $path)
  $penW = [Math]::Max(8, [int]($w * 0.028))
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 212, 175, 55), $penW)
  $ring = [int]($w * 0.12)
  $g.DrawEllipse($pen, $ring, $ring, $w - 2 * $ring, $w - 2 * $ring)
  $fontSize = [int]($w * 0.22)
  if ($fontSize -lt 24) { $fontSize = 24 }
  $font = New-Object System.Drawing.Font 'Segoe UI', $fontSize, ([System.Drawing.FontStyle]::Bold)
  $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 212, 175, 55))
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $g.DrawString('RF', $font, $brush, (New-Object System.Drawing.RectangleF 0, 0, $w, $w), $sf)
  $g.Dispose()
  return $bmp
}

$icon = Draw-RFIcon 1024
$icon.Save((Join-Path $outDir 'app_icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$icon.Dispose()

$splash = Draw-RFIcon 512
$splash.Save((Join-Path $outDir 'splash_logo.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$splash.Dispose()

Write-Host 'Branding PNGs written to assets/branding'
