$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/variants-10'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

function New-Brush([string]$Hex) { return New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($Hex)) }
function New-Pen([string]$Hex, [float]$Width) {
  $Pen = New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($Hex)), $Width
  $Pen.StartCap = [Drawing.Drawing2D.LineCap]::Round
  $Pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
  return $Pen
}
function Add-RoundRect([Drawing.Graphics]$G, [Drawing.RectangleF]$Rect, [float]$Radius, [Drawing.Brush]$Fill, [Drawing.Pen]$Stroke) {
  $Path = New-Object Drawing.Drawing2D.GraphicsPath
  $D = $Radius * 2
  $Path.AddArc($Rect.X, $Rect.Y, $D, $D, 180, 90)
  $Path.AddArc($Rect.Right - $D, $Rect.Y, $D, $D, 270, 90)
  $Path.AddArc($Rect.Right - $D, $Rect.Bottom - $D, $D, $D, 0, 90)
  $Path.AddArc($Rect.X, $Rect.Bottom - $D, $D, $D, 90, 90)
  $Path.CloseFigure()
  if ($Fill) { $G.FillPath($Fill, $Path) }
  if ($Stroke) { $G.DrawPath($Stroke, $Path) }
  $Path.Dispose()
}
function Draw-CenteredText([Drawing.Graphics]$G, [string]$Text, [Drawing.Font]$Font, [Drawing.Brush]$Brush, [Drawing.RectangleF]$Rect) {
  $Fmt = New-Object Drawing.StringFormat
  $Fmt.Alignment = [Drawing.StringAlignment]::Center
  $Fmt.LineAlignment = [Drawing.StringAlignment]::Center
  $Fmt.Trimming = [Drawing.StringTrimming]::EllipsisCharacter
  $G.DrawString($Text, $Font, $Brush, $Rect, $Fmt)
  $Fmt.Dispose()
}
function Draw-LeftText([Drawing.Graphics]$G, [string]$Text, [Drawing.Font]$Font, [Drawing.Brush]$Brush, [Drawing.RectangleF]$Rect) {
  $Fmt = New-Object Drawing.StringFormat
  $Fmt.Alignment = [Drawing.StringAlignment]::Near
  $Fmt.LineAlignment = [Drawing.StringAlignment]::Center
  $Fmt.Trimming = [Drawing.StringTrimming]::EllipsisCharacter
  $G.DrawString($Text, $Font, $Brush, $Rect, $Fmt)
  $Fmt.Dispose()
}
function Draw-ImageCover([Drawing.Graphics]$G, [string]$Path, [Drawing.RectangleF]$Dest, [float]$Radius) {
  $Img = [Drawing.Image]::FromFile($Path)
  $Scale = [Math]::Max($Dest.Width / $Img.Width, $Dest.Height / $Img.Height)
  $SrcW = $Dest.Width / $Scale
  $SrcH = $Dest.Height / $Scale
  $SrcX = ($Img.Width - $SrcW) / 2
  $SrcY = ($Img.Height - $SrcH) / 2
  $Clip = New-Object Drawing.Drawing2D.GraphicsPath
  $D = $Radius * 2
  $Clip.AddArc($Dest.X, $Dest.Y, $D, $D, 180, 90)
  $Clip.AddArc($Dest.Right - $D, $Dest.Y, $D, $D, 270, 90)
  $Clip.AddArc($Dest.Right - $D, $Dest.Bottom - $D, $D, $D, 0, 90)
  $Clip.AddArc($Dest.X, $Dest.Bottom - $D, $D, $D, 90, 90)
  $Clip.CloseFigure()
  $State = $G.Save()
  $G.SetClip($Clip)
  $G.DrawImage($Img, $Dest, (New-Object Drawing.RectangleF $SrcX, $SrcY, $SrcW, $SrcH), [Drawing.GraphicsUnit]::Pixel)
  $G.Restore($State)
  $Clip.Dispose()
  $Img.Dispose()
}
function Draw-Choice([Drawing.Graphics]$G, [Drawing.RectangleF]$Rect, [string]$Kana, [string]$Name, [string]$Desc, [string]$AccentColor, [string]$FillColor, [bool]$Right) {
  $Fill = New-Brush $FillColor
  $Pen = New-Pen $AccentColor 4
  Add-RoundRect $G $Rect 28 $Fill $Pen
  $KanaBrush = New-Brush $AccentColor
  if ($Right) {
    Draw-CenteredText $G $Kana $KanaFont $KanaBrush (New-Object Drawing.RectangleF ($Rect.X + 24), ($Rect.Y + 24), 94, 94)
    Draw-LeftText $G $Name $LabelFont $KanaBrush (New-Object Drawing.RectangleF ($Rect.X + 126), ($Rect.Y + 26), ($Rect.Width - 150), 38)
    Draw-LeftText $G $Desc $DescFont $Brown (New-Object Drawing.RectangleF ($Rect.X + 126), ($Rect.Y + 66), ($Rect.Width - 150), 60)
  } else {
    Draw-CenteredText $G $Kana $KanaFont $KanaBrush (New-Object Drawing.RectangleF ($Rect.X + 24), ($Rect.Y + 24), 94, 94)
    Draw-LeftText $G $Name $LabelFont $KanaBrush (New-Object Drawing.RectangleF ($Rect.X + 126), ($Rect.Y + 26), ($Rect.Width - 150), 38)
    Draw-LeftText $G $Desc $DescFont $Brown (New-Object Drawing.RectangleF ($Rect.X + 126), ($Rect.Y + 66), ($Rect.Width - 150), 60)
  }
  $Fill.Dispose(); $Pen.Dispose(); $KanaBrush.Dispose()
}
function Draw-QuestionPill([Drawing.Graphics]$G, [Drawing.RectangleF]$Rect, [string]$Axis, [string]$Q, [string]$Color) {
  Add-RoundRect $G $Rect 22 (New-Brush '#FFFFFF') (New-Pen $Color 2.5)
  Draw-CenteredText $G $Axis $AxisFont (New-Brush $Color) (New-Object Drawing.RectangleF $Rect.X, ($Rect.Y + 11), $Rect.Width, 22)
  Draw-CenteredText $G $Q $QuestionFont $Brown (New-Object Drawing.RectangleF ($Rect.X + 4), ($Rect.Y + 37), ($Rect.Width - 8), 46)
  Draw-CenteredText $G '◀ ▶' $ArrowFont (New-Brush $Color) (New-Object Drawing.RectangleF $Rect.X, ($Rect.Y + 84), $Rect.Width, 26)
}

$Images = @(
  (Join-Path $TokaDir '透明感モデルモビー.png'),
  (Join-Path $TokaDir '韓国コスメコンシェルジュモビー.png'),
  (Join-Path $TokaDir '韓ドラ女優モビー.png'),
  (Join-Path $TokaDir '韓国アイドルモビー.png'),
  (Join-Path $TokaDir '美容研究家モビー.png'),
  (Join-Path $TokaDir 'グルメモビー.png'),
  (Join-Path $TokaDir '美容エディターモビー.png'),
  (Join-Path $TokaDir '美容インフルエンサーモビー.png')
)

$W = 1080; $H = 1500
$TitleFont = [Drawing.Font]::new('Yu Gothic UI', 72, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$SubFont = [Drawing.Font]::new('Yu Gothic UI', 28, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$TagFont = [Drawing.Font]::new('Yu Gothic UI', 23, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$AxisFont = [Drawing.Font]::new('Yu Gothic UI', 17, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$QuestionFont = [Drawing.Font]::new('Yu Gothic UI', 22, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$ArrowFont = [Drawing.Font]::new('Yu Gothic UI', 22, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$KanaFont = [Drawing.Font]::new('Yu Gothic UI', 78, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$LabelFont = [Drawing.Font]::new('Yu Gothic UI', 29, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$DescFont = [Drawing.Font]::new('Yu Gothic UI', 22, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$SmallFont = [Drawing.Font]::new('Yu Gothic UI', 20, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)

$Variants = @(
  @{bg='#FFF4EA'; title='#D12E68'; left='#34B27B'; right='#9B6BD3'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='stack'; hero='arc'; name='cream-arc'},
  @{bg='#FFF8D9'; title='#C83A67'; left='#2CA86F'; right='#8D68D8'; a='#F35F91'; b='#3B93D9'; c='#F7A32B'; layout='stack'; hero='strip'; name='yellow-strip'},
  @{bg='#FDF1F4'; title='#B91E5A'; left='#22A67A'; right='#8B5FD1'; a='#E94878'; b='#2088CC'; c='#F27B20'; layout='poster'; hero='circle'; name='pink-poster'},
  @{bg='#F6FBF6'; title='#C73462'; left='#2FAE6E'; right='#9B6BD3'; a='#E85E7F'; b='#2C91D2'; c='#F28A22'; layout='bands'; hero='right'; name='green-bands'},
  @{bg='#FFF6EF'; title='#CC3366'; left='#159E8B'; right='#9B62CF'; a='#F04B77'; b='#2793D1'; c='#FF8A18'; layout='split'; hero='left'; name='split-hero'},
  @{bg='#F9F4FF'; title='#B23A7B'; left='#2AAE79'; right='#845EC2'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='tiles'; hero='topgrid'; name='lavender-tiles'},
  @{bg='#FFF3E1'; title='#CF3468'; left='#33A36E'; right='#A05CCB'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='wide'; hero='center'; name='warm-wide'},
  @{bg='#EEF9FF'; title='#C62C68'; left='#2FAE76'; right='#865BD3'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='compact'; hero='stamps'; name='blue-compact'},
  @{bg='#FFF5F0'; title='#D12E68'; left='#2EA76D'; right='#9A63D9'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='diagonal'; hero='diagonal'; name='diagonal'},
  @{bg='#FCF8EE'; title='#BA2E62'; left='#24A970'; right='#8A63D2'; a='#E94878'; b='#2D8FD6'; c='#FF8A18'; layout='minimal'; hero='solo'; name='minimal-solo'}
)

$RowsBase = @(
  @{axis='AXIS 01'; q="Q1`n入口は？"; left='つ'; leftName='積み重ね'; leftDesc='毎日の定番ケアを育てたい'; right='わ'; rightName='渡韓アップデート'; rightDesc='韓国美容や新作で更新したい'; row='a'},
  @{axis='AXIS 02'; q="Q2`n印象は？"; left='と'; leftName='透明感'; leftDesc='清潔感と淡い抜け感が好き'; right='ぐ'; rightName='グロウ'; rightDesc='ツヤと血色感で華やかに'; row='b'},
  @{axis='AXIS 03'; q="Q3`n楽しみ方は？"; left='じ'; leftName='自分軸'; leftDesc='自分の感覚でじっくり選ぶ'; right='し'; rightName='シェア提案'; rightDesc='良かったものを人にも届けたい'; row='c'}
)

$Manifest = @()
for ($N = 0; $N -lt $Variants.Count; $N++) {
  $V = $Variants[$N]
  $Bmp = New-Object Drawing.Bitmap $W, $H, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $G = [Drawing.Graphics]::FromImage($Bmp)
  $G.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $G.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $G.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $G.Clear([Drawing.ColorTranslator]::FromHtml($V.bg))
  $Brown = New-Brush '#31231F'; $Muted = New-Brush '#7A625C'
  Draw-CenteredText $G 'ビューティムード診断' $TitleFont (New-Brush $V.title) (New-Object Drawing.RectangleF 70, 62, 940, 86)
  Draw-CenteredText $G '3つの美容軸を、3問で見る簡易診断' $SubFont $Brown (New-Object Drawing.RectangleF 120, 152, 840, 42)

  if ($V.hero -eq 'arc') {
    Draw-ImageCover $G $Images[0] (New-Object Drawing.RectangleF 138, 224, 176, 176) 24
    Draw-ImageCover $G $Images[1] (New-Object Drawing.RectangleF 302, 202, 224, 224) 30
    Draw-ImageCover $G $Images[2] (New-Object Drawing.RectangleF 518, 224, 176, 176) 24
    Draw-ImageCover $G $Images[3] (New-Object Drawing.RectangleF 684, 212, 204, 204) 28
  } elseif ($V.hero -eq 'strip') {
    for ($I = 0; $I -lt 5; $I++) { Draw-ImageCover $G $Images[$I] (New-Object Drawing.RectangleF (92 + $I*178), 214, 170, 170) 28 }
  } elseif ($V.hero -eq 'circle') {
    Draw-ImageCover $G $Images[1] (New-Object Drawing.RectangleF 392, 198, 296, 296) 148
    Draw-ImageCover $G $Images[4] (New-Object Drawing.RectangleF 172, 248, 154, 154) 77
    Draw-ImageCover $G $Images[3] (New-Object Drawing.RectangleF 754, 248, 154, 154) 77
  } elseif ($V.hero -eq 'right') {
    Draw-ImageCover $G $Images[6] (New-Object Drawing.RectangleF 600, 204, 250, 250) 34
    Draw-ImageCover $G $Images[0] (New-Object Drawing.RectangleF 192, 226, 170, 170) 24
    Draw-ImageCover $G $Images[5] (New-Object Drawing.RectangleF 362, 226, 170, 170) 24
  } elseif ($V.hero -eq 'left') {
    Draw-ImageCover $G $Images[2] (New-Object Drawing.RectangleF 158, 206, 260, 260) 34
    Draw-ImageCover $G $Images[1] (New-Object Drawing.RectangleF 474, 236, 170, 170) 24
    Draw-ImageCover $G $Images[3] (New-Object Drawing.RectangleF 650, 236, 170, 170) 24
  } elseif ($V.hero -eq 'topgrid') {
    for ($I = 0; $I -lt 4; $I++) { Draw-ImageCover $G $Images[$I] (New-Object Drawing.RectangleF (170 + $I*186), 224, 150, 150) 26 }
  } elseif ($V.hero -eq 'center') {
    Draw-ImageCover $G $Images[7] (New-Object Drawing.RectangleF 336, 206, 408, 218) 34
  } elseif ($V.hero -eq 'stamps') {
    for ($I = 0; $I -lt 6; $I++) { Draw-ImageCover $G $Images[$I] (New-Object Drawing.RectangleF (82 + $I*154), (214 + (($I % 2) * 32)), 142, 142) 22 }
  } elseif ($V.hero -eq 'diagonal') {
    Draw-ImageCover $G $Images[1] (New-Object Drawing.RectangleF 210, 214, 210, 210) 30
    Draw-ImageCover $G $Images[4] (New-Object Drawing.RectangleF 438, 244, 180, 180) 28
    Draw-ImageCover $G $Images[3] (New-Object Drawing.RectangleF 636, 214, 210, 210) 30
  } else {
    Draw-ImageCover $G $Images[1] (New-Object Drawing.RectangleF 390, 206, 300, 220) 34
  }

  Add-RoundRect $G (New-Object Drawing.RectangleF 96, 458, 888, 68) 34 (New-Brush '#FFFFFF') (New-Pen '#F4A9BB' 2.5)
  Draw-CenteredText $G '毎日のケア・韓国美容・届け方から、美容タイプを判定' $TagFont $Brown (New-Object Drawing.RectangleF 124, 470, 832, 42)

  $TopY = 574
  for ($R = 0; $R -lt 3; $R++) {
    $Row = $RowsBase[$R]
    $Y = $TopY + $R * 236
    $AccentColor = if ($Row.row -eq 'a') { $V.a } elseif ($Row.row -eq 'b') { $V.b } else { $V.c }
    $FillColor = if ($Row.row -eq 'a') { '#FFF0F5' } elseif ($Row.row -eq 'b') { '#EDF8FF' } else { '#FFF7E8' }
    if ($V.layout -eq 'poster' -or $V.layout -eq 'minimal') { $Y = $TopY + $R * 218 }
    if ($V.layout -eq 'split') { $Y = $TopY + $R * 226 }
    Draw-Choice $G (New-Object Drawing.RectangleF 54, $Y, 400, 150) $Row.left $Row.leftName $Row.leftDesc $V.left $FillColor $false
    Draw-QuestionPill $G (New-Object Drawing.RectangleF 468, ($Y + 16), 144, 118) $Row.axis $Row.q $AccentColor
    Draw-Choice $G (New-Object Drawing.RectangleF 626, $Y, 400, 150) $Row.right $Row.rightName $Row.rightDesc $V.right $FillColor $true
  }

  Add-RoundRect $G (New-Object Drawing.RectangleF 90, 1314, 900, 82) 36 (New-Brush '#FFFFFF') (New-Pen '#F3A9BA' 2.5)
  Draw-CenteredText $G '答えをつなげて、あなたのビューティムードへ' ([Drawing.Font]::new('Yu Gothic UI', 26, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)) (New-Brush $V.title) (New-Object Drawing.RectangleF 130, 1328, 820, 34)
  Draw-CenteredText $G '例：つ・と・じ → 透明感モデルモビー' $SmallFont $Muted (New-Object Drawing.RectangleF 160, 1364, 760, 26)
  Draw-CenteredText $G '結果では Beauty Note も表示' $SmallFont (New-Brush $V.title) (New-Object Drawing.RectangleF 260, 1438, 560, 28)

  $IndexText = '{0:D2}' -f ($N + 1)
  $CodePath = Join-Path $OutDir "beauty-mood-design-$IndexText-code.png"
  $Bmp.Save($CodePath, [Drawing.Imaging.ImageFormat]::Png)
  $G.Dispose(); $Bmp.Dispose()
  $PromptPath = Join-Path $OutDir "beauty-mood-design-$IndexText-prompt.txt"
  $Prompt = @(
    'Use case: infographic-diagram',
    'Asset type: TikTok/social post, 1080x1500',
    "Design variant: $($V.name)",
    'Create a polished alternate Japanese Beauty Mood diagnosis infographic. Top title must be exactly 「ビューティムード診断」 only.',
    'Use three axes only: つ=積み重ね / わ=渡韓アップデート, と=透明感 / ぐ=グロウ, じ=自分軸 / し=シェア提案.',
    'No bottom 8-type list. Show only the three axis choices and a small closing note.',
    'Use K-beauty Mobby character imagery inspired by docs/miyake-yuko/img/8mobby-toka.',
    'Do not use Roman letters as choice codes. Do not add a fourth axis. No watermark.'
  ) -join [Environment]::NewLine
  [IO.File]::WriteAllText($PromptPath, $Prompt + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
  $Manifest += [pscustomobject]@{ index=$IndexText; name=$V.name; code=$CodePath; prompt=$PromptPath }
}
$ManifestPath = Join-Path $OutDir 'manifest.json'
$Manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
$Manifest | ForEach-Object { "{0} {1}" -f $_.index, $_.code }