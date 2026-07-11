$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath (Convert-Path .)

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
  param([float]$X, [float]$Y, [float]$Width, [float]$Height, [float]$Radius)
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

$sourceDir = 'C:\Users\harui\.codex\codex-remote-attachments\019f5054-e3a5-7122-8f7e-ff51aa624aa5\BC5CE293-D04E-4909-B80F-8AF07C86D988'
$outputDir = 'docs/miyake-yuko/img/tiktok-assets/face-type-mapping-kingdom-7'

$items = @(
  @{ File='1-写真1.jpg'; Output='01-boukoku-kdrama-actress-mobby.jpg'; Source='亡国顔'; Type='韓ドラ女優モビー'; Code='わとじ'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f7f7f8'); Accent=[Drawing.ColorTranslator]::FromHtml('#a9a0bb') },
  @{ File='2-写真2.jpg'; Output='02-tekkoku-korean-idol-mobby.jpg'; Source='敵国顔'; Type='韓国アイドルモビー'; Code='わぐし'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f8f7f8'); Accent=[Drawing.ColorTranslator]::FromHtml('#b57087') },
  @{ File='3-写真3.jpg'; Output='03-kyuukoku-beauty-editor-mobby.jpg'; Source='救国顔'; Type='美容エディターモビー'; Code='つとし'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f9f8f7'); Accent=[Drawing.ColorTranslator]::FromHtml('#96b6c6') },
  @{ File='4-写真4.jpg'; Output='04-gokoku-clear-model-mobby.jpg'; Source='護国顔'; Type='透明感モデルモビー'; Code='つとじ'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f8f8f7'); Accent=[Drawing.ColorTranslator]::FromHtml('#8aa08f') },
  @{ File='5-写真5.jpg'; Output='05-keishou-gourmet-mobby.jpg'; Source='継承顔'; Type='グルメモビー'; Code='つぐじ'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f9f8f7'); Accent=[Drawing.ColorTranslator]::FromHtml('#d4a2b5') },
  @{ File='6-写真6.jpg'; Output='06-keikoku-beauty-influencer-mobby.jpg'; Source='傾国顔'; Type='美容インフルエンサーモビー'; Code='つぐし'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f8f7f8'); Accent=[Drawing.ColorTranslator]::FromHtml('#c28aa6') },
  @{ File='7-写真7.jpg'; Output='07-kenkoku-beauty-researcher-mobby.jpg'; Source='建国顔'; Type='美容研究家モビー'; Code='わぐじ'; CropY=286; CropH=560; BoxX=197; BoxY=485; BoxW=196; BoxH=196; Fill=[Drawing.ColorTranslator]::FromHtml('#f8f8f7'); Accent=[Drawing.ColorTranslator]::FromHtml('#8f948a') }
)

$canvasW = 2480
$canvasH = 3508
$cream = [Drawing.ColorTranslator]::FromHtml('#fff5e7')
$ink = [Drawing.ColorTranslator]::FromHtml('#202336')
$sub = [Drawing.ColorTranslator]::FromHtml('#776866')
$titleFamilies = @('HG丸ｺﾞｼｯｸM-PRO', 'Noto Sans JP Medium', 'UD デジタル 教科書体 NP', 'Yu Gothic UI Semibold', 'Meiryo')
$accentFamilies = @('UD デジタル 教科書体 NP', 'HGP教科書体', 'Noto Serif JP Medium', 'Yu Gothic UI', 'Meiryo')

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
      $targetX = [int](($canvasW - $targetW) / 2)
      $targetY = [int](($canvasH - $targetH) / 2)
      $dest = [Drawing.Rectangle]::new($targetX, $targetY, $targetW, $targetH)
      $g.DrawImage($src, $dest, $crop, [Drawing.GraphicsUnit]::Pixel)

      $scale = [double]$targetW / $src.Width
      $panelX = [int]($targetX + ([double]$item.BoxX * $scale))
      $panelY = [int]($targetY + (([double]$item.BoxY - [double]$item.CropY) * $scale))
      $panelW = [int]([double]$item.BoxW * $scale)
      $panelH = [int]([double]$item.BoxH * $scale)
      $radius = [float]([Math]::Max(36, $scale * 10))

      $panelPath = New-RoundedRectanglePath -X $panelX -Y $panelY -Width $panelW -Height $panelH -Radius $radius
      $panelBrush = [Drawing.SolidBrush]::new($item.Fill)
      $g.FillPath($panelBrush, $panelPath)
      $panelBrush.Dispose()
      $pen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(210, $item.Accent.R, $item.Accent.G, $item.Accent.B), 5)
      $g.DrawPath($pen, $panelPath)
      $pen.Dispose()
      $panelPath.Dispose()

      $sf = [Drawing.StringFormat]::new()
      $sf.Alignment = [Drawing.StringAlignment]::Center
      $sf.LineAlignment = [Drawing.StringAlignment]::Center
      $sf.FormatFlags = [Drawing.StringFormatFlags]::NoClip
      $accentBrush = [Drawing.SolidBrush]::new($item.Accent)
      $inkBrush = [Drawing.SolidBrush]::new($ink)
      $subBrush = [Drawing.SolidBrush]::new($sub)

      $titleText = $item.Type -replace 'モビー$', "`nモビー"
      $sourceFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.080)) -Style ([Drawing.FontStyle]::Regular)
      $titleFont = Get-FittingFont -Graphics $g -Text $titleText -Families $titleFamilies -StartSize ([float]($panelH * 0.118)) -MinSize ([float]($panelH * 0.072)) -MaxWidth ($panelW - 80) -Style ([Drawing.FontStyle]::Regular)
      $codeFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.070)) -Style ([Drawing.FontStyle]::Regular)

      $g.DrawString($item.Source, $sourceFont, $accentBrush, [Drawing.RectangleF]::new($panelX + 22, $panelY + ($panelH * 0.10), $panelW - 44, $panelH * 0.12), $sf)
      $g.DrawString($titleText, $titleFont, $inkBrush, [Drawing.RectangleF]::new($panelX + 34, $panelY + ($panelH * 0.25), $panelW - 68, $panelH * 0.38), $sf)
      $g.DrawString(('(' + $item.Code + ')'), $codeFont, $subBrush, [Drawing.RectangleF]::new($panelX + 22, $panelY + ($panelH * 0.65), $panelW - 44, $panelH * 0.12), $sf)

      $linePen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(150, $item.Accent.R, $item.Accent.G, $item.Accent.B), 4)
      $linePen.StartCap = [Drawing.Drawing2D.LineCap]::Round
      $linePen.EndCap = [Drawing.Drawing2D.LineCap]::Round
      $lineY = [int]($panelY + ($panelH * 0.82))
      $g.DrawLine($linePen, [int]($panelX + ($panelW * 0.36)), $lineY, [int]($panelX + ($panelW * 0.64)), $lineY)
      $linePen.Dispose()

      $sourceFont.Dispose()
      $titleFont.Dispose()
      $codeFont.Dispose()
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

Write-Output "Generated $($items.Count) A4 images in $outputDir"
