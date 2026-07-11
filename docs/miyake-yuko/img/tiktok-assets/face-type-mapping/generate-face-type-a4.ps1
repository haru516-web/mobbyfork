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

function Get-FittingFont {
  param(
    [Drawing.Graphics]$Graphics,
    [string]$Text,
    [string[]]$Families,
    [float]$StartSize,
    [float]$MinSize,
    [float]$MaxWidth,
    [Drawing.FontStyle]$Style
  )
  for ($size = $StartSize; $size -ge $MinSize; $size -= 4) {
    $font = Get-Font -Families $Families -Size $size -Style $Style
    $measured = $Graphics.MeasureString($Text, $font)
    if ($measured.Width -le $MaxWidth) {
      return $font
    }
    $font.Dispose()
  }
  return Get-Font -Families $Families -Size $MinSize -Style $Style
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
  @{ File='1-写真1.jpg'; Output='01-cool-korean-idol-mobby.jpg'; Source='クール'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=190; CropH=790; BoxX=183; BoxY=505; BoxW=224; BoxH=212; Accent=[Drawing.ColorTranslator]::FromHtml('#263f74'); Fill=[Drawing.ColorTranslator]::FromHtml('#071d48') },
  @{ File='2-写真2.jpg'; Output='02-elegant-kdrama-actress-mobby.jpg'; Source='エレガント'; Type='韓ドラ女優モビー'; Code='わとじ'; CropY=166; CropH=787; BoxX=184; BoxY=455; BoxW=222; BoxH=210; Accent=[Drawing.ColorTranslator]::FromHtml('#b44a54'); Fill=[Drawing.ColorTranslator]::FromHtml('#a50f15') },
  @{ File='3-写真3.jpg'; Output='03-soft-elegant-kdrama-actress-mobby.jpg'; Source='ソフトエレガント'; Type='韓ドラ女優モビー'; Code='わとじ'; CropY=164; CropH=786; BoxX=180; BoxY=452; BoxW=230; BoxH=205; Accent=[Drawing.ColorTranslator]::FromHtml('#8fb7c8'); Fill=[Drawing.ColorTranslator]::FromHtml('#f8fbf8') },
  @{ File='4-写真4.jpg'; Output='04-fresh-clear-model-mobby.jpg'; Source='フレッシュ'; Type='透明感モデルモビー'; Code='つとじ'; CropY=170; CropH=784; BoxX=184; BoxY=454; BoxW=222; BoxH=214; Accent=[Drawing.ColorTranslator]::FromHtml('#77a98f'); Fill=[Drawing.ColorTranslator]::FromHtml('#d9ebcf') },
  @{ File='5-写真5.jpg'; Output='05-cool-casual-korean-idol-mobby.jpg'; Source='クールカジュアル'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=166; CropH=798; BoxX=181; BoxY=450; BoxW=228; BoxH=214; Accent=[Drawing.ColorTranslator]::FromHtml('#7891ac'); Fill=[Drawing.ColorTranslator]::FromHtml('#b9cadd') },
  @{ File='6-写真6.jpg'; Output='06-feminine-korean-idol-mobby.jpg'; Source='フェミニン'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=166; CropH=786; BoxX=183; BoxY=457; BoxW=224; BoxH=209; Accent=[Drawing.ColorTranslator]::FromHtml('#c98fca'); Fill=[Drawing.ColorTranslator]::FromHtml('#dfc7f2') },
  @{ File='7-写真7.jpg'; Output='07-active-cute-korean-idol-mobby.jpg'; Source='アクティブキュート'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=185; CropH=790; BoxX=184; BoxY=493; BoxW=222; BoxH=214; Accent=[Drawing.ColorTranslator]::FromHtml('#eda676'); Fill=[Drawing.ColorTranslator]::FromHtml('#f3b58d') },
  @{ File='8-写真8.jpg'; Output='08-cute-korean-idol-mobby.jpg'; Source='キュート'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=175; CropH=788; BoxX=183; BoxY=461; BoxW=224; BoxH=214; Accent=[Drawing.ColorTranslator]::FromHtml('#e7a5b8'); Fill=[Drawing.ColorTranslator]::FromHtml('#f4c5d0') }
)

$canvasW = 2480
$canvasH = 3508
$cream = [Drawing.ColorTranslator]::FromHtml('#fff5e7')
$ink = [Drawing.ColorTranslator]::FromHtml('#26334f')
$sub = [Drawing.ColorTranslator]::FromHtml('#7d6b68')
$titleFamilies = @('HG丸ｺﾞｼｯｸM-PRO', 'Noto Sans JP Medium', 'UD デジタル 教科書体 NP', 'Yu Gothic UI Semibold', 'Meiryo')
$accentFamilies = @('UD デジタル 教科書体 NP', 'HGP教科書体', 'Noto Serif JP Medium', 'Yu Gothic UI', 'Meiryo')

$codeFont = Get-Font -Families $accentFamilies -Size 70 -Style ([Drawing.FontStyle]::Regular)
$smallFont = Get-Font -Families $accentFamilies -Size 48 -Style ([Drawing.FontStyle]::Regular)

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

      $scale = [double]$targetW / $src.Width
      $panelX = [int]($targetX + ([double]$item.BoxX * $scale))
      $panelY = [int]($targetY + (([double]$item.BoxY - [double]$item.CropY) * $scale))
      $panelW = [int]([double]$item.BoxW * $scale)
      $panelH = [int]([double]$item.BoxH * $scale)
      $radius = [float]([Math]::Max(38, $scale * 14))
      $shadowPath = New-RoundedRectanglePath -X ($panelX + 16) -Y ($panelY + 20) -Width $panelW -Height $panelH -Radius $radius
      $shadowBrush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(54, 67, 52, 67))
      $g.FillPath($shadowBrush, $shadowPath)
      $shadowBrush.Dispose()
      $shadowPath.Dispose()

      $panelPath = New-RoundedRectanglePath -X $panelX -Y $panelY -Width $panelW -Height $panelH -Radius $radius
      $panelBrush = [Drawing.SolidBrush]::new($item.Fill)
      $g.FillPath($panelBrush, $panelPath)
      $panelBrush.Dispose()
      $pen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(235, $item.Accent.R, $item.Accent.G, $item.Accent.B), 5)
      $g.DrawPath($pen, $panelPath)
      $pen.Dispose()
      $panelPath.Dispose()

      $sf = [Drawing.StringFormat]::new()
      $sf.Alignment = [Drawing.StringAlignment]::Center
      $sf.LineAlignment = [Drawing.StringAlignment]::Center
      $sf.FormatFlags = [Drawing.StringFormatFlags]::NoClip
      $darkPanel = (($item.Fill.R + $item.Fill.G + $item.Fill.B) -lt 280)
      if ($darkPanel) {
        $titleColor = [Drawing.ColorTranslator]::FromHtml('#fff8ee')
        $subColor = [Drawing.ColorTranslator]::FromHtml('#f7dbe4')
        $accentColor = [Drawing.ColorTranslator]::FromHtml('#f9c8d7')
      } else {
        $titleColor = $ink
        $subColor = $sub
        $accentColor = $item.Accent
      }
      $accentBrush = [Drawing.SolidBrush]::new($accentColor)
      $inkBrush = [Drawing.SolidBrush]::new($titleColor)
      $subBrush = [Drawing.SolidBrush]::new($subColor)

      $titleText = $item.Type -replace 'モビー$', "`nモビー"
      $sourceFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.075)) -Style ([Drawing.FontStyle]::Regular)
      $titleFont = Get-FittingFont -Graphics $g -Text $titleText -Families $titleFamilies -StartSize ([float]($panelH * 0.145)) -MinSize ([float]($panelH * 0.105)) -MaxWidth ($panelW - 90) -Style ([Drawing.FontStyle]::Regular)
      $codePanelFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.082)) -Style ([Drawing.FontStyle]::Regular)
      $g.DrawString($item.Source, $sourceFont, $accentBrush, [Drawing.RectangleF]::new($panelX + 24, $panelY + ($panelH * 0.10), $panelW - 48, $panelH * 0.12), $sf)
      $g.DrawString($titleText, $titleFont, $inkBrush, [Drawing.RectangleF]::new($panelX + 38, $panelY + ($panelH * 0.24), $panelW - 76, $panelH * 0.40), $sf)
      $g.DrawString(('(' + $item.Code + ')'), $codePanelFont, $subBrush, [Drawing.RectangleF]::new($panelX + 24, $panelY + ($panelH * 0.65), $panelW - 48, $panelH * 0.13), $sf)

      $linePen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(160, $accentColor.R, $accentColor.G, $accentColor.B), 4)
      $linePen.StartCap = [Drawing.Drawing2D.LineCap]::Round
      $linePen.EndCap = [Drawing.Drawing2D.LineCap]::Round
      $lineY = [int]($panelY + ($panelH * 0.83))
      $g.DrawLine($linePen, [int]($panelX + ($panelW * 0.34)), $lineY, [int]($panelX + ($panelW * 0.66)), $lineY)
      $linePen.Dispose()

      $sourceFont.Dispose()
      $titleFont.Dispose()
      $codePanelFont.Dispose()
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

$codeFont.Dispose()
$smallFont.Dispose()

Write-Output "Generated $($items.Count) A4 images in $outputDir"
