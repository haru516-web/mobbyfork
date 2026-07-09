$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/code-type-map'
$CleanDir = Join-Path $OutDir '8mobby-toka-clean'
$AiBg = Join-Path $OutDir 'beauty-mood-code-type-map-big-source-lock-ai-bg.png'
$Out = Join-Path $OutDir 'beauty-mood-code-type-map-big-source-lock.png'

function B($hex) {
  New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($hex))
}
function BA($alpha, $hex) {
  $c = [Drawing.ColorTranslator]::FromHtml($hex)
  New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb($alpha, $c.R, $c.G, $c.B))
}
function Pn($hex, $width) {
  $p = New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($hex)), $width
  $p.StartCap = 'Round'
  $p.EndCap = 'Round'
  $p
}
function FontCute($size, $style = 'Regular') {
  $names = @('UD Digi Kyokasho NP-B', 'HGP創英角ﾎﾟｯﾌﾟ体', 'Yu Gothic UI', 'Meiryo')
  foreach ($name in $names) {
    try { return New-Object Drawing.Font($name, $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel) } catch {}
  }
  New-Object Drawing.Font('Yu Gothic UI', $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel)
}
function RR($g, $x, $y, $w, $h, $r, $fill, $stroke = $null) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  if ($fill) { $g.FillPath($fill, $path) }
  if ($stroke) { $g.DrawPath($stroke, $path) }
  $path.Dispose()
}
function TextBox($g, $text, $font, $brush, $x, $y, $w, $h, $align = 'Center') {
  $sf = New-Object Drawing.StringFormat
  $sf.Alignment = [Drawing.StringAlignment]::$align
  $sf.LineAlignment = 'Center'
  $sf.Trimming = 'EllipsisCharacter'
  $g.DrawString($text, $font, $brush, (New-Object Drawing.RectangleF $x, $y, $w, $h), $sf)
  $sf.Dispose()
}
function ImgFit($g, $path, $x, $y, $w, $h) {
  $im = [Drawing.Bitmap]::FromFile($path)
  $left = $im.Width
  $top = $im.Height
  $right = 0
  $bottom = 0
  for ($py = 0; $py -lt $im.Height; $py += 3) {
    for ($px = 0; $px -lt $im.Width; $px += 3) {
      if ($im.GetPixel($px, $py).A -gt 12) {
        if ($px -lt $left) { $left = $px }
        if ($py -lt $top) { $top = $py }
        if ($px -gt $right) { $right = $px }
        if ($py -gt $bottom) { $bottom = $py }
      }
    }
  }
  if ($right -le $left -or $bottom -le $top) {
    $left = 0; $top = 0; $right = $im.Width - 1; $bottom = $im.Height - 1
  }
  $pad = 12
  $left = [Math]::Max(0, $left - $pad)
  $top = [Math]::Max(0, $top - $pad)
  $right = [Math]::Min($im.Width - 1, $right + $pad)
  $bottom = [Math]::Min($im.Height - 1, $bottom + $pad)
  $src = New-Object Drawing.Rectangle $left, $top, ($right - $left + 1), ($bottom - $top + 1)
  $scale = [Math]::Min($w / $src.Width, $h / $src.Height)
  $dw = $src.Width * $scale
  $dh = $src.Height * $scale
  $shadow = New-Object Drawing.Bitmap ([int]$dw), ([int]$dh)
  $sg = [Drawing.Graphics]::FromImage($shadow)
  $sg.Clear([Drawing.Color]::Transparent)
  $cm = New-Object Drawing.Imaging.ColorMatrix
  $cm.Matrix00 = 0; $cm.Matrix11 = 0; $cm.Matrix22 = 0; $cm.Matrix33 = 0.24
  $ia = New-Object Drawing.Imaging.ImageAttributes
  $ia.SetColorMatrix($cm)
  $rect = New-Object Drawing.Rectangle 0, 0, ([int]$dw), ([int]$dh)
  $sg.DrawImage($im, $rect, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel, $ia)
  $sg.Dispose()
  $dx = $x + ($w - $dw) / 2
  $dy = $y + ($h - $dh) / 2
  $g.DrawImage($shadow, $dx + 9, $dy + 13, $dw, $dh)
  $dest = New-Object Drawing.Rectangle ([int]$dx), ([int]$dy), ([int]$dw), ([int]$dh)
  $g.DrawImage($im, $dest, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel)
  $shadow.Dispose()
  $ia.Dispose()
  $im.Dispose()
}

$titleFont = FontCute 62 'Bold'
$subFont = FontCute 24 'Bold'
$codeFont = FontCute 40 'Bold'
$nameFont = FontCute 22 'Bold'
$axisFont = FontCute 15 'Bold'
$noteFont = FontCute 18 'Bold'

$rows = @(
  @{ Code = 'つとじ'; Name = '透明感モデルモビー'; Color = '#d7a443'; Axis = '積み重ね / 透明感 / 自分軸' },
  @{ Code = 'つとし'; Name = '美容エディターモビー'; Color = '#df7b5c'; Axis = '積み重ね / 透明感 / シェア' },
  @{ Code = 'つぐじ'; Name = 'グルメモビー'; Color = '#db9056'; Axis = '積み重ね / グロウ / 自分軸' },
  @{ Code = 'つぐし'; Name = '美容インフルエンサーモビー'; Color = '#e86e91'; Axis = '積み重ね / グロウ / シェア' },
  @{ Code = 'わとじ'; Name = '韓ドラ女優モビー'; Color = '#9c8e90'; Axis = '渡韓 / 透明感 / 自分軸' },
  @{ Code = 'わとし'; Name = '韓国コスメコンシェルジュモビー'; Color = '#dd7888'; Axis = '渡韓 / 透明感 / シェア' },
  @{ Code = 'わぐじ'; Name = '美容研究家モビー'; Color = '#d9869a'; Axis = '渡韓 / グロウ / 自分軸' },
  @{ Code = 'わぐし'; Name = '韓国アイドルモビー'; Color = '#e55f81'; Axis = '渡韓 / グロウ / シェア' }
)

$bmp = New-Object Drawing.Bitmap 1080, 1500
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.InterpolationMode = 'HighQualityBicubic'
$g.TextRenderingHint = 'AntiAliasGridFit'

if (Test-Path -LiteralPath $AiBg) {
  $bg = [Drawing.Image]::FromFile($AiBg)
  $g.DrawImage($bg, 0, 0, 1080, 1500)
  $bg.Dispose()
} else {
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff3e4'))
}
$veil = BA 76 '#fff7ed'
$g.FillRectangle($veil, 0, 0, 1080, 1500)
$veil.Dispose()

RR $g 58 52 964 152 40 (BA 210 '#fffaf4') (Pn '#f1bdc6' 2)
TextBox $g 'ビューティムード診断' $titleFont (B '#c74161') 120 70 840 76
TextBox $g 'ひらがな対応表' $subFont (B '#d96982') 120 142 840 36

for ($i = 0; $i -lt $rows.Count; $i++) {
  $row = $rows[$i]
  $col = $i % 2
  $r = [Math]::Floor($i / 2)
  $x = 52 + ($col * 506)
  $y = 244 + ($r * 285)
  $accent = $row.Color
  $imgPath = Join-Path $CleanDir ($row.Name + '.png')

  RR $g ($x + 10) ($y + 12) 470 254 34 (BA 34 '#6f4f45') $null
  RR $g $x $y 470 254 34 (BA 248 '#fffdf9') (Pn $accent 3)
  RR $g ($x + 20) ($y + 18) 118 60 24 (BA 230 '#fff0f3') (Pn $accent 2)
  TextBox $g $row.Code $codeFont (B $accent) ($x + 20) ($y + 18) 118 58
  TextBox $g $row.Name $nameFont (B '#c74161') ($x + 148) ($y + 18) 296 42 'Near'
  TextBox $g $row.Axis $axisFont (B '#7d514f') ($x + 148) ($y + 56) 296 26 'Near'

  if (Test-Path -LiteralPath $imgPath) {
    ImgFit $g $imgPath ($x + 16) ($y + 78) 438 170
  }
}

RR $g 154 1394 772 44 22 (BA 230 '#fffaf4') (Pn '#f1bdc6' 2)
TextBox $g '3文字をつなげて、あなたの8タイプへ' $noteFont (B '#c74161') 154 1397 772 38

$bmp.Save($Out, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output $Out
