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
  for ($size = $StartSize; $size -ge $MinSize; $size -= 2) {
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
  param([Drawing.Bitmap]$Bitmap, [string]$Path, [long]$Quality = 95)
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

$sourceDir = 'C:\Users\harui\.codex\generated_images\019f5054-e3a5-7122-8f7e-ff51aa624aa5'
$outputDir = 'docs/miyake-yuko/img/tiktok-assets/face-type-mapping-male-kingdom-7-ai'

$items = @(
  @{ SourceFile='ig_064d6e4e1b41dd1c016a53635715c88191b21015fcf8f0dcd8.png'; Output='01-boukoku-kdrama-actress-mobby.jpg'; Source='亡国顔'; Type='韓ドラ女優モビー'; Code='わとじ'; Fill=[Drawing.ColorTranslator]::FromHtml('#d8e4f2'); Accent=[Drawing.ColorTranslator]::FromHtml('#6d8ab0') },
  @{ SourceFile='ig_01fc5f29cd0acad1016a53646dd0b88191b07efc0be4c04e27.png'; Output='02-gokoku-clear-model-mobby.jpg'; Source='護国顔'; Type='透明感モデルモビー'; Code='つとじ'; Fill=[Drawing.ColorTranslator]::FromHtml('#2f3037'); Accent=[Drawing.ColorTranslator]::FromHtml('#b9b8c2'); Dark=$true },
  @{ SourceFile='ig_01fc5f29cd0acad1016a5365641e6481919f3e915934d01ec4.png'; Output='03-kyuukoku-beauty-editor-mobby.jpg'; Source='救国顔'; Type='美容エディターモビー'; Code='つとし'; Fill=[Drawing.ColorTranslator]::FromHtml('#d9c4cd'); Accent=[Drawing.ColorTranslator]::FromHtml('#ad7890') },
  @{ SourceFile='ig_01fc5f29cd0acad1016a5365cbb0508191b64c9c335c565b90.png'; Output='04-tekkoku-korean-idol-mobby.jpg'; Source='敵国顔'; Type='韓国アイドルモビー'; Code='わぐし'; Fill=[Drawing.ColorTranslator]::FromHtml('#28161c'); Accent=[Drawing.ColorTranslator]::FromHtml('#bd5e72'); Dark=$true },
  @{ SourceFile='ig_01fc5f29cd0acad1016a53663237f08191bc5dfd8fb3a0cfef.png'; Output='05-keishou-gourmet-mobby.jpg'; Source='継承顔'; Type='グルメモビー'; Code='つぐじ'; Fill=[Drawing.ColorTranslator]::FromHtml('#d8d2ca'); Accent=[Drawing.ColorTranslator]::FromHtml('#9c8f86') },
  @{ SourceFile='ig_01fc5f29cd0acad1016a5366985a648191bd0f0b3150bf905a.png'; Output='06-keikoku-beauty-influencer-mobby.jpg'; Source='傾国顔'; Type='美容インフルエンサーモビー'; Code='つぐし'; Fill=[Drawing.ColorTranslator]::FromHtml('#dddfe1'); Accent=[Drawing.ColorTranslator]::FromHtml('#a6a9b0') },
  @{ SourceFile='ig_006dd6001505572a016a5367f91be88191ab0142853367b24b.png'; Output='07-kenkoku-beauty-researcher-mobby.jpg'; Source='建国顔'; Type='美容研究家モビー'; Code='わぐじ'; Fill=[Drawing.ColorTranslator]::FromHtml('#3f3f43'); Accent=[Drawing.ColorTranslator]::FromHtml('#b7b0bf'); Dark=$true }
)

$titleFamilies = @('HG丸ｺﾞｼｯｸM-PRO', 'Noto Sans JP Medium', 'UD デジタル 教科書体 NP', 'Yu Gothic UI Semibold', 'Meiryo')
$accentFamilies = @('UD デジタル 教科書体 NP', 'HGP教科書体', 'Noto Serif JP Medium', 'Yu Gothic UI', 'Meiryo')
$ink = [Drawing.ColorTranslator]::FromHtml('#202336')
$sub = [Drawing.ColorTranslator]::FromHtml('#746869')

foreach ($item in $items) {
  $srcPath = Join-Path $sourceDir $item.SourceFile
  $src = [Drawing.Image]::FromFile($srcPath)
  try {
    $bmp = [Drawing.Bitmap]::new($src.Width, $src.Height)
    $g = [Drawing.Graphics]::FromImage($bmp)
    try {
      $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
      $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
      $g.DrawImage($src, [Drawing.Rectangle]::new(0, 0, $src.Width, $src.Height))

      $panelX = [int]($src.Width / 3)
      $panelY = [int]($src.Height / 3)
      $panelW = [int]($src.Width / 3)
      $panelH = [int]($src.Height / 3)
      $radius = [float]([Math]::Max(18, $src.Width * 0.016))

      $panelPath = New-RoundedRectanglePath -X $panelX -Y $panelY -Width $panelW -Height $panelH -Radius $radius
      $panelBrush = [Drawing.SolidBrush]::new($item.Fill)
      $g.FillPath($panelBrush, $panelPath)
      $panelBrush.Dispose()
      $pen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(230, $item.Accent.R, $item.Accent.G, $item.Accent.B), [Math]::Max(3, $src.Width * 0.003))
      $g.DrawPath($pen, $panelPath)
      $pen.Dispose()
      $panelPath.Dispose()

      $darkPanel = ($item.ContainsKey('Dark') -and $item.Dark)
      if ($darkPanel) {
        $titleColor = [Drawing.ColorTranslator]::FromHtml('#fff8ee')
        $subColor = [Drawing.ColorTranslator]::FromHtml('#f4dbe4')
        $accentColor = [Drawing.ColorTranslator]::FromHtml('#f0c7d2')
      } else {
        $titleColor = $ink
        $subColor = $sub
        $accentColor = $item.Accent
      }

      $sf = [Drawing.StringFormat]::new()
      $sf.Alignment = [Drawing.StringAlignment]::Center
      $sf.LineAlignment = [Drawing.StringAlignment]::Center
      $sf.FormatFlags = [Drawing.StringFormatFlags]::NoClip
      $accentBrush = [Drawing.SolidBrush]::new($accentColor)
      $inkBrush = [Drawing.SolidBrush]::new($titleColor)
      $subBrush = [Drawing.SolidBrush]::new($subColor)

      $titleText = $item.Type -replace 'モビー$', "`nモビー"
      $sourceFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.078)) -Style ([Drawing.FontStyle]::Regular)
      $titleFont = Get-FittingFont -Graphics $g -Text $titleText -Families $titleFamilies -StartSize ([float]($panelH * 0.118)) -MinSize ([float]($panelH * 0.072)) -MaxWidth ($panelW - 42) -Style ([Drawing.FontStyle]::Regular)
      $codeFont = Get-Font -Families $accentFamilies -Size ([float]($panelH * 0.070)) -Style ([Drawing.FontStyle]::Regular)

      $g.DrawString($item.Source, $sourceFont, $accentBrush, [Drawing.RectangleF]::new($panelX + 10, $panelY + ($panelH * 0.10), $panelW - 20, $panelH * 0.12), $sf)
      $g.DrawString($titleText, $titleFont, $inkBrush, [Drawing.RectangleF]::new($panelX + 18, $panelY + ($panelH * 0.25), $panelW - 36, $panelH * 0.38), $sf)
      $g.DrawString(('(' + $item.Code + ')'), $codeFont, $subBrush, [Drawing.RectangleF]::new($panelX + 10, $panelY + ($panelH * 0.65), $panelW - 20, $panelH * 0.12), $sf)

      $linePen = [Drawing.Pen]::new([Drawing.Color]::FromArgb(155, $accentColor.R, $accentColor.G, $accentColor.B), [Math]::Max(2, $src.Width * 0.002))
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

Write-Output "Wrote $($items.Count) AI-generated final images to $outputDir"
