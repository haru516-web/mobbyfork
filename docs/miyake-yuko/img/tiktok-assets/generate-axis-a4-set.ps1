$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/axis-a4-set'
$CleanDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/code-type-map/8mobby-toka-clean'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

function B($hex) { New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($hex)) }
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
function FontClean($size, $style = 'Regular') {
  $names = @('Yu Gothic UI Semibold', 'Yu Gothic UI', 'Meiryo', 'UD Digi Kyokasho NP-B')
  foreach ($name in $names) {
    try { return New-Object Drawing.Font($name, $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel) } catch {}
  }
  New-Object Drawing.Font('Meiryo', $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel)
}
function FontSerif($size, $style = 'Regular') {
  $names = @('Yu Mincho', 'MS Mincho', 'Yu Gothic UI')
  foreach ($name in $names) {
    try { return New-Object Drawing.Font($name, $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel) } catch {}
  }
  New-Object Drawing.Font('Meiryo', $size, [Drawing.FontStyle]::$style, [Drawing.GraphicsUnit]::Pixel)
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
  $left = $im.Width; $top = $im.Height; $right = 0; $bottom = 0
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
  $pad = 18
  $left = [Math]::Max(0, $left - $pad)
  $top = [Math]::Max(0, $top - $pad)
  $right = [Math]::Min($im.Width - 1, $right + $pad)
  $bottom = [Math]::Min($im.Height - 1, $bottom + $pad)
  $src = New-Object Drawing.Rectangle $left, $top, ($right - $left + 1), ($bottom - $top + 1)
  $scale = [Math]::Min($w / $src.Width, $h / $src.Height)
  $dw = $src.Width * $scale
  $dh = $src.Height * $scale
  $dx = $x + ($w - $dw) / 2
  $dy = $y + ($h - $dh) / 2
  $shadow = New-Object Drawing.Bitmap ([int]$dw), ([int]$dh)
  $sg = [Drawing.Graphics]::FromImage($shadow)
  $sg.Clear([Drawing.Color]::Transparent)
  $cm = New-Object Drawing.Imaging.ColorMatrix
  $cm.Matrix00 = 0; $cm.Matrix11 = 0; $cm.Matrix22 = 0; $cm.Matrix33 = 0.18
  $ia = New-Object Drawing.Imaging.ImageAttributes
  $ia.SetColorMatrix($cm)
  $rect = New-Object Drawing.Rectangle 0, 0, ([int]$dw), ([int]$dh)
  $sg.DrawImage($im, $rect, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel, $ia)
  $sg.Dispose()
  $g.DrawImage($shadow, $dx + 18, $dy + 24, $dw, $dh)
  $dest = New-Object Drawing.Rectangle ([int]$dx), ([int]$dy), ([int]$dw), ([int]$dh)
  $g.DrawImage($im, $dest, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel)
  $shadow.Dispose(); $ia.Dispose(); $im.Dispose()
}
function DrawProgress($g, $activeIndex) {
  $labels = @('A','B','C')
  $startX = 805
  $y = 3235
  for ($i = 0; $i -lt 3; $i++) {
    $cx = $startX + ($i * 430)
    if ($i -gt 0) {
      $pen = if ($i -le $activeIndex) { Pn '#dd7287' 5 } else { Pn '#d7cfc3' 4 }
      $g.DrawLine($pen, $cx - 315, $y, $cx - 118, $y)
      $pen.Dispose()
    }
    $fill = if ($i -eq $activeIndex) { B '#dd7287' } else { BA 0 '#ffffff' }
    $stroke = if ($i -eq $activeIndex) { Pn '#dd7287' 4 } else { Pn '#d7cfc3' 4 }
    $brushText = if ($i -eq $activeIndex) { B '#fffaf1' } else { B '#aaa29a' }
    if ($i -eq $activeIndex) {
      $g.FillEllipse($fill, $cx - 64, $y - 64, 128, 128)
    }
    $g.DrawEllipse($stroke, $cx - 64, $y - 64, 128, 128)
    TextBox $g $labels[$i] (FontClean 52 'Regular') $brushText ($cx - 64) ($y - 68) 128 128
    $fill.Dispose(); $stroke.Dispose(); $brushText.Dispose()
  }
}
function DrawAxis($spec) {
  $w = 2480; $h = 3508
  $bmp = New-Object Drawing.Bitmap $w, $h
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.InterpolationMode = 'HighQualityBicubic'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff5e7'))

  $pink = '#d95f78'
  $navy = '#17345c'
  $brown = '#6d5650'
  $line = '#e3b8b0'
  $blue = '#4baed0'

  TextBox $g 'ビューティムード診断' (FontClean 138 'Bold') (B $pink) 220 330 2040 160
  TextBox $g '3つの美容軸で診断' (FontClean 50 'Regular') (B '#706762') 620 505 1240 70
  $g.DrawLine((Pn $line 4), 410, 760, 2070, 760)
  TextBox $g ($spec.Axis + '軸') (FontClean 96 'Bold') (B $pink) 560 808 330 105
  TextBox $g $spec.Title (FontClean 82 'Bold') (B $navy) 890 810 1030 105 'Near'
  $g.DrawLine((Pn $line 3), 410, 960, 2070, 960)
  TextBox $g $spec.Question (FontClean 45 'Regular') (B $brown) 450 990 1580 70

  $divider = Pn '#e9ded3' 3
  $g.DrawLine($divider, 1240, 1190, 1240, 2855)
  $divider.Dispose()

  foreach ($side in @($spec.Left, $spec.Right)) {
    $x = if ($side.Side -eq 'L') { 170 } else { 1325 }
    $accent = if ($side.Side -eq 'L') { $pink } else { $navy }
    $chip = if ($side.Side -eq 'L') { $pink } else { $navy }
    TextBox $g $side.Code (FontSerif 230 'Regular') (B $accent) ($x + 130) 1195 720 245
    RR $g ($x + 180) 1465 600 95 47 (B $chip) $null
    TextBox $g $side.Name (FontClean 44 'Bold') (B '#fffdf8') ($x + 180) 1475 600 70
    TextBox $g $side.Desc (FontClean 45 'Regular') (B $brown) ($x + 80) 1605 820 140
    $img = Join-Path $CleanDir ($side.Image + '.png')
    if (Test-Path -LiteralPath $img) {
      ImgFit $g $img ($x + 45) 1768 900 820
    }
  }

  DrawProgress $g $spec.Index
  $out = Join-Path $OutDir ('beauty-mood-axis-{0}-code.png' -f $spec.Axis.ToLower())
  $bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
  Write-Output $out
}

$axes = @(
  @{
    Axis = 'A'; Index = 0; Title = '美容の育て方'; Question = 'あなたの美容は、どちらに近い？'
    Left = @{ Side = 'L'; Code = 'つ'; Name = '積み重ね派'; Desc = "毎日のケアで`n透明感を育てたい"; Image = '透明感モデルモビー' }
    Right = @{ Side = 'R'; Code = 'わ'; Name = '渡韓アップデート派'; Desc = "韓国美容や新しい流行を`n試したい"; Image = '韓国コスメコンシェルジュモビー' }
  },
  @{
    Axis = 'B'; Index = 1; Title = '肌印象の見せ方'; Question = 'なりたい肌印象はどっち？'
    Left = @{ Side = 'L'; Code = 'と'; Name = '透明感派'; Desc = "澄んだ清潔感を`n大切にしたい"; Image = '透明感モデルモビー' }
    Right = @{ Side = 'R'; Code = 'ぐ'; Name = 'グロウ派'; Desc = "うるっと光るツヤ感を`n楽しみたい"; Image = 'グルメモビー' }
  },
  @{
    Axis = 'C'; Index = 2; Title = '美容の届け方'; Question = '美容を選ぶとき、心地いいのは？'
    Left = @{ Side = 'L'; Code = 'じ'; Name = '自分軸派'; Desc = "自分らしい好きで`n選びたい"; Image = '美容研究家モビー' }
    Right = @{ Side = 'R'; Code = 'し'; Name = 'シェア提案派'; Desc = "良かったものを`n人にも届けたい"; Image = '美容インフルエンサーモビー' }
  }
)

foreach ($axis in $axes) {
  DrawAxis $axis
}
