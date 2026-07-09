$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/quick-diagnosis'
$CleanDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/code-type-map/8mobby-toka-clean'
$AiBg = Join-Path $OutDir 'quick-diagnosis-ai-bg.png'
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
  $pad = 10
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
  $cm.Matrix00 = 0; $cm.Matrix11 = 0; $cm.Matrix22 = 0; $cm.Matrix33 = 0.20
  $ia = New-Object Drawing.Imaging.ImageAttributes
  $ia.SetColorMatrix($cm)
  $rect = New-Object Drawing.Rectangle 0, 0, ([int]$dw), ([int]$dh)
  $sg.DrawImage($im, $rect, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel, $ia)
  $sg.Dispose()
  $g.DrawImage($shadow, $dx + 10, $dy + 14, $dw, $dh)
  $dest = New-Object Drawing.Rectangle ([int]$dx), ([int]$dy), ([int]$dw), ([int]$dh)
  $g.DrawImage($im, $dest, $src.X, $src.Y, $src.Width, $src.Height, [Drawing.GraphicsUnit]::Pixel)
  $shadow.Dispose(); $ia.Dispose(); $im.Dispose()
}

$sets = @(
  @{ No = 1; Pair = '透明感モデルモビー'; Hero = '今の気分で選んでね'; Q = @(
    @{ A = 'A'; T = '美容は毎日コツコツ？ソウルで刷新？'; L = 'つ'; R = 'わ'; C = '#e95d84' },
    @{ A = 'B'; T = '肌印象は、澄ませる？光らせる？'; L = 'と'; R = 'ぐ'; C = '#57b7d8' },
    @{ A = 'C'; T = '可愛いは自分で決める？一緒に見つける？'; L = 'じ'; R = 'し'; C = '#f2a64f' }) },
  @{ No = 2; Pair = '韓ドラ女優モビー'; Hero = '直感で3つ選ぶだけ'; Q = @(
    @{ A = 'A'; T = '可愛さは毎日育てる？旅先で更新する？'; L = 'つ'; R = 'わ'; C = '#e76698' },
    @{ A = 'B'; T = '肌印象は透け感？ツヤめき？'; L = 'と'; R = 'ぐ'; C = '#4fb7df' },
    @{ A = 'C'; T = '似合うは自分で選ぶ？一緒に見つける？'; L = 'じ'; R = 'し'; C = '#ee9b42' }) },
  @{ No = 3; Pair = '美容エディターモビー'; Hero = '今日のムードをチェック'; Q = @(
    @{ A = 'A'; T = 'きれいは習慣で育てる？韓国感で変える？'; L = 'つ'; R = 'わ'; C = '#d95f8d' },
    @{ A = 'B'; T = '見せたい肌は、清らか？うるツヤ？'; L = 'と'; R = 'ぐ'; C = '#48a9d6' },
    @{ A = 'C'; T = '選ぶ基準は、自分の好き？おすすめ感？'; L = 'じ'; R = 'し'; C = '#ef9b4a' }) },
  @{ No = 4; Pair = '美容研究家モビー'; Hero = '3問で美容タイプへ'; Q = @(
    @{ A = 'A'; T = '可愛さは毎日育てる？旬に着替える？'; L = 'つ'; R = 'わ'; C = '#df5d86' },
    @{ A = 'B'; T = '肌印象はふわ透明？つやグロウ？'; L = 'と'; R = 'ぐ'; C = '#50afd0' },
    @{ A = 'C'; T = '選ぶなら自分らしさ？友達の推し？'; L = 'じ'; R = 'し'; C = '#f0a044' }) },
  @{ No = 5; Pair = '韓国コスメコンシェルジュモビー'; Hero = '迷わず近い方へ'; Q = @(
    @{ A = 'A'; T = '可愛さ、毎日ちょい足し？韓国で一気に更新？'; L = 'つ'; R = 'わ'; C = '#ec638a' },
    @{ A = 'B'; T = '肌印象は、ふわっと透明？つやっと発光？'; L = 'と'; R = 'ぐ'; C = '#4db6d7' },
    @{ A = 'C'; T = '選ぶなら、私らしさ優先？友だち提案も聞く？'; L = 'じ'; R = 'し'; C = '#f1a347' }) },
  @{ No = 6; Pair = '韓国アイドルモビー'; Hero = 'あなたの美容ムードは？'; Q = @(
    @{ A = 'A'; T = 'ケアは積み上げ派？トレンド更新派？'; L = 'つ'; R = 'わ'; C = '#e75686' },
    @{ A = 'B'; T = 'ベースは透明感重視？グロウ重視？'; L = 'と'; R = 'ぐ'; C = '#44abd3' },
    @{ A = 'C'; T = 'メイク選びは私基準？人に届けたい？'; L = 'じ'; R = 'し'; C = '#ed9944' }) },
  @{ No = 7; Pair = '美容インフルエンサーモビー'; Hero = '気分に近い方を選択'; Q = @(
    @{ A = 'A'; T = '可愛さの更新、どっち気分？'; L = 'つ'; R = 'わ'; C = '#e96594' },
    @{ A = 'B'; T = '肌見せムードは、さらり？発光？'; L = 'と'; R = 'ぐ'; C = '#4aaed2' },
    @{ A = 'C'; T = '可愛いの決め方は、私優先？相談派？'; L = 'じ'; R = 'し'; C = '#efa34d' }) },
  @{ No = 8; Pair = 'グルメモビー'; Hero = '明日の可愛さ診断'; Q = @(
    @{ A = 'A'; T = '明日の可愛さ、どっちで足す？'; L = 'つ'; R = 'わ'; C = '#e65c8b' },
    @{ A = 'B'; T = '肌ムードは、透ける清楚？うるっと光る？'; L = 'と'; R = 'ぐ'; C = '#52b7d6' },
    @{ A = 'C'; T = '選ぶ決め手は、ときめき？似合う相談？'; L = 'じ'; R = 'し'; C = '#efa14b' }) },
  @{ No = 9; Pair = '透明感モデルモビー'; Hero = '3文字をつなげてね'; Q = @(
    @{ A = 'A'; T = '可愛さ、どう育てたい？'; L = 'つ'; R = 'わ'; C = '#df5d88' },
    @{ A = 'B'; T = '今日の肌、ふわ透明？つやグロウ？'; L = 'と'; R = 'ぐ'; C = '#4cb0d6' },
    @{ A = 'C'; T = 'メイク選びは、私っぽさ？提案ほしい？'; L = 'じ'; R = 'し'; C = '#eba052' }) },
  @{ No = 10; Pair = '韓ドラ女優モビー'; Hero = 'ぱっと見で選ぶ診断'; Q = @(
    @{ A = 'A'; T = '朝の美容は、定番ルーティン？新作チェック？'; L = 'つ'; R = 'わ'; C = '#e75e8d' },
    @{ A = 'B'; T = 'まといたい質感は、淡い透明感？濡れツヤ？'; L = 'と'; R = 'ぐ'; C = '#4bb2d9' },
    @{ A = 'C'; T = '似合うの基準は、自分の感覚？周りの反応？'; L = 'じ'; R = 'し'; C = '#ee9b49' }) },
  @{ No = 11; Pair = '美容エディターモビー'; Hero = '美容のクセがわかる'; Q = @(
    @{ A = 'A'; T = '変化は少しずつ？トレンドで即更新？'; L = 'つ'; R = 'わ'; C = '#e86693' },
    @{ A = 'B'; T = '目指す肌は、すっぴん透明？ライト艶？'; L = 'と'; R = 'ぐ'; C = '#56b8d6' },
    @{ A = 'C'; T = '買う前は、自分で決定？誰かに相談？'; L = 'じ'; R = 'し'; C = '#eea44b' }) },
  @{ No = 12; Pair = '美容研究家モビー'; Hero = '韓国っぽ美容チェック'; Q = @(
    @{ A = 'A'; T = '美容は、コツコツ派？韓国トレンド派？'; L = 'つ'; R = 'わ'; C = '#e35d89' },
    @{ A = 'B'; T = '仕上がりは、清潔透明？ぷるん艶？'; L = 'と'; R = 'ぐ'; C = '#4cade0' },
    @{ A = 'C'; T = '美容情報は、深掘り派？シェア派？'; L = 'じ'; R = 'し'; C = '#ef9d43' }) },
  @{ No = 13; Pair = '韓国コスメコンシェルジュモビー'; Hero = '今っぽ可愛い診断'; Q = @(
    @{ A = 'A'; T = '大事なのは、毎日のケア？旬の韓国感？'; L = 'つ'; R = 'わ'; C = '#e95f8c' },
    @{ A = 'B'; T = '第一印象は、澄んだ肌？光る肌？'; L = 'と'; R = 'ぐ'; C = '#49afd7' },
    @{ A = 'C'; T = 'コスメは自分で探す？人にも教える？'; L = 'じ'; R = 'し'; C = '#eba14a' }) },
  @{ No = 14; Pair = '韓国アイドルモビー'; Hero = '好きな方だけ選んで'; Q = @(
    @{ A = 'A'; T = '変化は少しずつ？一気に大胆？'; L = 'つ'; R = 'わ'; C = '#e75890' },
    @{ A = 'B'; T = '盛るなら透明感？ツヤ感？'; L = 'と'; R = 'ぐ'; C = '#51b7da' },
    @{ A = 'C'; T = '可愛いは自分のため？誰かと楽しむため？'; L = 'じ'; R = 'し'; C = '#efa045' }) },
  @{ No = 15; Pair = '美容インフルエンサーモビー'; Hero = '最後は直感でOK'; Q = @(
    @{ A = 'A'; T = '美容計画は、計画派？トレンド派？'; L = 'つ'; R = 'わ'; C = '#e66292' },
    @{ A = 'B'; T = '写真映えは、澄んだ印象？ツヤの印象？'; L = 'と'; R = 'ぐ'; C = '#4eb5d8' },
    @{ A = 'C'; T = '選ぶ時間は、ひとりで？誰かと一緒に？'; L = 'じ'; R = 'し'; C = '#ed9e4d' }) }
)

$titleFont = FontCute 58 'Bold'
$heroFont = FontCute 30 'Bold'
$axisFont = FontCute 22 'Bold'
$questionFont = FontCute 30 'Bold'
$codeFont = FontCute 50 'Bold'
$smallFont = FontCute 18 'Bold'

foreach ($set in $sets) {
  foreach ($mode in @('code', 'ai')) {
    $bmp = New-Object Drawing.Bitmap 1080, 1500
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.TextRenderingHint = 'AntiAliasGridFit'

    if ($mode -eq 'ai' -and (Test-Path -LiteralPath $AiBg)) {
      $bg = [Drawing.Image]::FromFile($AiBg)
      $g.DrawImage($bg, 0, 0, 1080, 1500)
      $bg.Dispose()
      $veil = BA 92 '#fff5e8'
      $g.FillRectangle($veil, 0, 0, 1080, 1500)
      $veil.Dispose()
    } else {
      $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff2df'))
    }

    RR $g 58 54 964 130 38 (BA 238 '#fffaf2') (Pn '#f3b7c7' 2)
    TextBox $g 'ビューティムード診断' $titleFont (B '#ca3d61') 105 70 870 68
    TextBox $g $set.Hero $heroFont (B '#e66b8f') 150 134 780 38

    $imgPath = Join-Path $CleanDir ($set.Pair + '.png')
    if (Test-Path -LiteralPath $imgPath) {
      ImgFit $g $imgPath 128 196 824 390
    }

    $baseY = 600
    for ($i = 0; $i -lt $set.Q.Count; $i++) {
      $q = $set.Q[$i]
      $y = $baseY + ($i * 230)
      $accent = $q.C
      RR $g 64 ($y + 10) 952 198 34 (BA 34 '#6f4f45') $null
      RR $g 52 $y 976 198 34 (BA 248 '#fffdf9') (Pn $accent 3)
      RR $g 82 ($y + 28) 96 46 22 (BA 230 '#fff1f4') (Pn $accent 2)
      TextBox $g ('Q' + ($i + 1)) $axisFont (B $accent) 82 ($y + 30) 96 40
      TextBox $g $q.T $questionFont (B '#6a4342') 196 ($y + 26) 744 48

      RR $g 130 ($y + 100) 350 62 26 (BA 238 '#fff5f8') (Pn $accent 2)
      RR $g 600 ($y + 100) 350 62 26 (BA 238 '#effaff') (Pn '#55b8db' 2)
      TextBox $g $q.L $codeFont (B $accent) 142 ($y + 101) 78 58
      TextBox $g $q.R $codeFont (B '#45acd3') 612 ($y + 101) 78 58
      TextBox $g '左' $smallFont (B '#9d6263') 220 ($y + 112) 80 36
      TextBox $g '右' $smallFont (B '#5a8294') 690 ($y + 112) 80 36
      $arrowFont = FontCute 28 'Bold'
      TextBox $g 'or' $arrowFont (B '#d99aa7') 500 ($y + 108) 80 40
    }

    RR $g 146 1324 788 54 27 (BA 230 '#fffaf4') (Pn '#f3b7c7' 2)
    TextBox $g '選んだひらがなを つなげて診断' $heroFont (B '#ca3d61') 146 1331 788 40

    $suffix = if ($mode -eq 'ai') { 'ai' } else { 'code' }
    $out = Join-Path $OutDir ('quick-diagnosis-{0:D2}-{1}.png' -f [int]$set.No, $suffix)
    $bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output $out
  }
}
