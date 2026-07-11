$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath (Convert-Path .)

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
  param(
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [float]$Radius
  )
  $path = [Drawing.Drawing2D.GraphicsPath]::new()
  $d = $Radius * 2
  $path.AddArc($X, $Y, $d, $d, 180, 90)
  $path.AddArc($X + $Width - $d, $Y, $d, $d, 270, 90)
  $path.AddArc($X + $Width - $d, $Y + $Height - $d, $d, $d, 0, 90)
  $path.AddArc($X, $Y + $Height - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Get-Font {
  param([string[]]$Families, [float]$Size, [Drawing.FontStyle]$Style)
  foreach ($family in $Families) {
    try { return [Drawing.Font]::new($family, $Size, $Style, [Drawing.GraphicsUnit]::Pixel) } catch {}
  }
  return [Drawing.Font]::new([Drawing.FontFamily]::GenericSansSerif, $Size, $Style, [Drawing.GraphicsUnit]::Pixel)
}

function Save-Jpeg {
  param([Drawing.Bitmap]$Bitmap, [string]$Path, [long]$Quality = 94)
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
  $params = [Drawing.Imaging.EncoderParameters]::new(1)
  $params.Param[0] = [Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality, $Quality)
  $tmp = [IO.Path]::GetTempFileName()
  try {
    $Bitmap.Save($tmp, $codec, $params)
    Move-Item -LiteralPath $tmp -Destination $Path -Force
  }
  finally {
    if (Test-Path -LiteralPath $tmp) {
      Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
    $params.Dispose()
  }
}

$sourceDir = 'C:\Users\harui\.codex\codex-remote-attachments\019f5054-e3a5-7122-8f7e-ff51aa624aa5\A1CED5BA-7F39-4B5C-8B90-C8E6C4552119'
$outputDir = 'docs/miyake-yuko/img/tiktok-assets/face-type-mapping'

$items = @(
  @{ File='1-写真1.jpg'; Output='01-cool-korean-idol-mobby.jpg'; Source='クール'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=190; CropH=790; Accent=[Drawing.ColorTranslator]::FromHtml('#7b86b8') },
  @{ File='2-写真2.jpg'; Output='02-elegant-kdrama-actress-mobby.jpg'; Source='エレガント'; Type='韓ドラ女優モビー'; Code='わとじ'; CropY=166; CropH=787; Accent=[Drawing.ColorTranslator]::FromHtml('#b44a54') },
  @{ File='3-写真3.jpg'; Output='03-soft-elegant-kdrama-actress-mobby.jpg'; Source='ソフトエレガント'; Type='韓ドラ女優モビー'; Code='わとじ'; CropY=164; CropH=786; Accent=[Drawing.ColorTranslator]::FromHtml('#8fb7c8') },
  @{ File='4-写真4.jpg'; Output='04-fresh-clear-model-mobby.jpg'; Source='フレッシュ'; Type='透明感モデルモビー'; Code='つとじ'; CropY=170; CropH=784; Accent=[Drawing.ColorTranslator]::FromHtml('#89b69f') },
  @{ File='5-写真5.jpg'; Output='05-cool-casual-korean-idol-mobby.jpg'; Source='クールカジュアル'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=166; CropH=798; Accent=[Drawing.ColorTranslator]::FromHtml('#7891ac') },
  @{ File='6-写真6.jpg'; Output='06-feminine-korean-idol-mobby.jpg'; Source='フェミニン'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=166; CropH=786; Accent=[Drawing.ColorTranslator]::FromHtml('#c98fca') },
  @{ File='7-写真7.jpg'; Output='07-active-cute-korean-idol-mobby.jpg'; Source='アクティブキュート'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=185; CropH=790; Accent=[Drawing.ColorTranslator]::FromHtml('#eda676') },
  @{ File='8-写真8.jpg'; Output='08-cute-korean-idol-mobby.jpg'; Source='キュート'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=175; CropH=788; Accent=[Drawing.ColorTranslator]::FromHtml('#e7a5b8') }
)

$canvasW = 2480
$canvasH = 3508
$cream = [Drawing.ColorTranslator]::FromHtml('#fff5e7')
$ink = [Drawing.ColorTranslator]::FromHtml('#24324a')
$sub = [Drawing.ColorTranslator]::FromHtml('#806f69')
$fontFamilies = @('Yu Gothic UI', 'Meiryo', 'Yu Gothic', 'MS Gothic')

$titleFont = Get-Font -Families $fontFamilies -Size 118 -Style ([Drawing.FontStyle]::Bold)
$codeFont = Get-Font -Families $fontFamilies -Size 64 -Style ([Drawing.FontStyle]::Regular)
$smallFont = Get-Font -Families $fontFamilies -Size 46 -Style ([Drawing.FontStyle]::Regular)

foreach ($item in $items) {
  $srcPath = Join-Path $sourceDir $item.File
  $src = [Drawing.Image]::FromFile($srcPath)
  try {
    $bmp = [Drawing.Bitmap]::new($canvasW, $canvasH)
    $g = [Drawing.Graphics]::FromImage($bmp)
    try {
      $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
      $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
      $g.Clear($cream)

      $crop = [Drawing.Rectangle]::new(0, [int]$item.CropY, $src.Width, [int]$item.CropH)
      $targetW = 2310
      $targetH = [int]([double]$targetW * $crop.Height / $crop.Width)
      if ($targetH -gt 3180) {
        $targetH = 3180
        $targetW = [int]([double]$targetH * $crop.Width / $crop.Height)
      }
      $targetX = [int](($canvasW - $targetW) / 2)
      $targetY = [int](($canvasH - $targetH) / 2)
      $dest = [Drawing.Rectangle]::new($targetX, $targetY, $targetW, $targetH)
      $g.DrawImage($src, $dest, $crop, [Drawing.GraphicsUnit]::Pixel)

      $panelW = 1240
      $panelH = 470
      $panelX = [int](($canvasW - $panelW) / 2)
      $panelY = [int]($targetY + ($targetH * 0.44))
      $shadowPath = New-RoundedRectanglePath -X ($panelX + 18) -Y ($panelY + 22) -Width $panelW -Height $panelH -Radius 46
      $shadowBrush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(70, 49, 39, 58))
      $g.FillPath($shadowBrush, $shadowPath)
      $shadowBrush.Dispose()
      $shadowPath.Dispose()

      $panelPath = New-RoundedRectanglePath -X $panelX -Y $panelY -Width $panelW -Height $panelH -Radius 46
      $panelBrush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(236, $cream.R, $cream.G, $cream.B))
      $g.FillPath($panelBrush, $panelPath)
      $panelBrush.Dispose()
      $pen = [Drawing.Pen]::new($item.Accent, 8)
      $g.DrawPath($pen, $panelPath)
      $pen.Dispose()
      $panelPath.Dispose()

      $sf = [Drawing.StringFormat]::new()
      $sf.Alignment = [Drawing.StringAlignment]::Center
      $sf.LineAlignment = [Drawing.StringAlignment]::Center
      $accentBrush = [Drawing.SolidBrush]::new($item.Accent)
      $inkBrush = [Drawing.SolidBrush]::new($ink)
      $subBrush = [Drawing.SolidBrush]::new($sub)

      $g.DrawString($item.Source, $smallFont, $accentBrush, [Drawing.RectangleF]::new($panelX, $panelY + 42, $panelW, 70), $sf)
      $g.DrawString($item.Type, $titleFont, $inkBrush, [Drawing.RectangleF]::new($panelX + 30, $panelY + 130, $panelW - 60, 150), $sf)
      $g.DrawString(('(' + $item.Code + ')'), $codeFont, $subBrush, [Drawing.RectangleF]::new($panelX, $panelY + 288, $panelW, 88), $sf)

      $linePen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(170, $item.Accent.R, $item.Accent.G, $item.Accent.B), 5)
      $g.DrawLine($linePen, $panelX + 420, $panelY + 390, $panelX + 820, $panelY + 390)
      $linePen.Dispose()

      $accentBrush.Dispose()
      $inkBrush.Dispose()
      $subBrush.Dispose()
      $sf.Dispose()
    }
    finally {
      $g.Dispose()
    }
    Save-Jpeg -Bitmap $bmp -Path (Join-Path $outputDir $item.Output)
  }
  finally {
    if ($bmp) { $bmp.Dispose() }
    $src.Dispose()
  }
}

$titleFont.Dispose()
$codeFont.Dispose()
$smallFont.Dispose()

Write-Output "Generated $($items.Count) A4 images in $outputDir"
