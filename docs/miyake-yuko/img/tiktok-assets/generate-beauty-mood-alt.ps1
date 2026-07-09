$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
$CodePath = Join-Path $OutDir 'beauty-mood-diagnosis-alt-code.png'
$PromptPath = Join-Path $OutDir 'beauty-mood-diagnosis-alt-prompt.txt'
if (-not (Test-Path -LiteralPath $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

function New-Brush([string]$Hex) {
  return New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($Hex))
}

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

function Draw-TypeChip([Drawing.Graphics]$G, [hashtable]$Item, [float]$X, [float]$Y, [float]$W, [float]$H, [string]$Color) {
  $Fill = New-Brush '#FFFFFF'
  $Pen = New-Pen $Color 3
  Add-RoundRect $G (New-Object Drawing.RectangleF $X, $Y, $W, $H) 18 $Fill $Pen
  Draw-ImageCover $G $Item.path (New-Object Drawing.RectangleF ($X + 10), ($Y + 10), 74, 74) 14
  Draw-LeftText $G $Item.code $TypeCodeFont (New-Brush $Color) (New-Object Drawing.RectangleF ($X + 94), ($Y + 12), ($W - 106), 24)
  Draw-LeftText $G $Item.name $TypeNameFont $Brown (New-Object Drawing.RectangleF ($X + 94), ($Y + 34), ($W - 106), 42)
  $Fill.Dispose()
  $Pen.Dispose()
}

$W = 1080
$H = 1500
$Bmp = New-Object Drawing.Bitmap $W, $H, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
$G = [Drawing.Graphics]::FromImage($Bmp)
$G.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
$G.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$G.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$G.Clear([Drawing.ColorTranslator]::FromHtml('#FFF4EA'))

$Accent = New-Brush '#D12E68'
$Pink = New-Brush '#EC6A86'
$Brown = New-Brush '#31231F'
$Muted = New-Brush '#7A625C'
$SoftCard = New-Brush '#FFFDF8'
$PinkSoft = New-Brush '#FFF0F5'
$BlueSoft = New-Brush '#EDF8FF'
$OrangeSoft = New-Brush '#FFF7E8'
$Green = New-Brush '#34B27B'
$Purple = New-Brush '#9B6BD3'
$Blue = New-Brush '#2D8FD6'
$Orange = New-Brush '#FF8A18'

$TitleFont = [Drawing.Font]::new('Yu Gothic UI', 76, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$SubFont = [Drawing.Font]::new('Yu Gothic UI', 28, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$TagFont = [Drawing.Font]::new('Yu Gothic UI', 24, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$AxisFont = [Drawing.Font]::new('Yu Gothic UI', 18, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$QuestionFont = [Drawing.Font]::new('Yu Gothic UI', 23, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$KanaFont = [Drawing.Font]::new('Yu Gothic UI', 76, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$LabelFont = [Drawing.Font]::new('Yu Gothic UI', 30, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$DescFont = [Drawing.Font]::new('Yu Gothic UI', 23, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$TypeCodeFont = [Drawing.Font]::new('Yu Gothic UI', 18, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$TypeNameFont = [Drawing.Font]::new('Yu Gothic UI', 13, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$TypeLineFont = [Drawing.Font]::new('Yu Gothic UI', 12, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)

$Images = @{
  clear = Join-Path $TokaDir '透明感モデルモビー.png'
  editor = Join-Path $TokaDir '美容エディターモビー.png'
  gourmet = Join-Path $TokaDir 'グルメモビー.png'
  influencer = Join-Path $TokaDir '美容インフルエンサーモビー.png'
  drama = Join-Path $TokaDir '韓ドラ女優モビー.png'
  concierge = Join-Path $TokaDir '韓国コスメコンシェルジュモビー.png'
  researcher = Join-Path $TokaDir '美容研究家モビー.png'
  idol = Join-Path $TokaDir '韓国アイドルモビー.png'
}

Draw-CenteredText $G 'ビューティムード診断' $TitleFont $Accent (New-Object Drawing.RectangleF 70, 74, 940, 88)
Draw-CenteredText $G '3つの美容軸を、3問で見る簡易診断' $SubFont $Brown (New-Object Drawing.RectangleF 130, 166, 820, 44)

Draw-ImageCover $G $Images.clear (New-Object Drawing.RectangleF 146, 235, 170, 170) 22
Draw-ImageCover $G $Images.concierge (New-Object Drawing.RectangleF 310, 207, 220, 220) 28
Draw-ImageCover $G $Images.drama (New-Object Drawing.RectangleF 500, 235, 170, 170) 22
Draw-ImageCover $G $Images.idol (New-Object Drawing.RectangleF 662, 222, 200, 200) 26
Draw-CenteredText $G '毎日のケア・韓国美容・届け方から、あなたの美容タイプを判定' $TagFont $Brown (New-Object Drawing.RectangleF 110, 450, 860, 56)
Add-RoundRect $G (New-Object Drawing.RectangleF 96, 438, 888, 78) 38 $null (New-Pen '#F4A9BB' 3)

$Rows = @(
  @{axis='AXIS 01'; q="Q1`n入口は？"; left='つ'; leftName='積み重ね'; leftDesc='毎日の定番ケアを育てたい'; right='わ'; rightName='渡韓アップデート'; rightDesc='韓国美容や新作で更新したい'; y=556; color='#E94878'; fill='#FFF0F5'; lBrush=$Green; rBrush=$Purple},
  @{axis='AXIS 02'; q="Q2`n印象は？"; left='と'; leftName='透明感'; leftDesc='清潔感と淡い抜け感が好き'; right='ぐ'; rightName='グロウ'; rightDesc='ツヤと血色感で華やかに'; y=748; color='#2D8FD6'; fill='#EDF8FF'; lBrush=$Green; rBrush=$Purple},
  @{axis='AXIS 03'; q="Q3`n楽しみ方は？"; left='じ'; leftName='自分軸'; leftDesc='自分の感覚でじっくり選ぶ'; right='し'; rightName='シェア提案'; rightDesc='良かったものを人にも届けたい'; y=940; color='#FF8A18'; fill='#FFF7E8'; lBrush=$Green; rBrush=$Purple}
)

foreach ($Row in $Rows) {
  $Color = $Row.color
  $Fill = New-Brush $Row.fill
  $LinePen = New-Pen $Color 4
  Add-RoundRect $G (New-Object Drawing.RectangleF 52, $Row.y, 392, 146) 24 $Fill $LinePen
  Add-RoundRect $G (New-Object Drawing.RectangleF 636, $Row.y, 392, 146) 24 $Fill $LinePen
  Add-RoundRect $G (New-Object Drawing.RectangleF 463, ($Row.y + 17), 154, 112) 20 (New-Brush '#FFFFFF') (New-Pen $Color 2)
  Draw-CenteredText $G $Row.axis $AxisFont (New-Brush $Color) (New-Object Drawing.RectangleF 470, ($Row.y + 24), 140, 24)
  Draw-CenteredText $G $Row.q $QuestionFont $Brown (New-Object Drawing.RectangleF 466, ($Row.y + 48), 148, 50)
  Draw-CenteredText $G '◀ ▶' $QuestionFont (New-Brush $Color) (New-Object Drawing.RectangleF 476, ($Row.y + 86), 128, 34)

  Draw-CenteredText $G $Row.left $KanaFont $Row.lBrush (New-Object Drawing.RectangleF 84, ($Row.y + 28), 82, 84)
  Draw-LeftText $G $Row.leftName $LabelFont $Row.lBrush (New-Object Drawing.RectangleF 178, ($Row.y + 28), 238, 34)
  Draw-LeftText $G $Row.leftDesc $DescFont $Brown (New-Object Drawing.RectangleF 178, ($Row.y + 66), 236, 54)
  Draw-CenteredText $G $Row.right $KanaFont $Row.rBrush (New-Object Drawing.RectangleF 666, ($Row.y + 28), 82, 84)
  Draw-LeftText $G $Row.rightName $LabelFont $Row.rBrush (New-Object Drawing.RectangleF 760, ($Row.y + 28), 238, 34)
  Draw-LeftText $G $Row.rightDesc $DescFont $Brown (New-Object Drawing.RectangleF 760, ($Row.y + 66), 236, 54)
  $Fill.Dispose()
  $LinePen.Dispose()
}

Add-RoundRect $G (New-Object Drawing.RectangleF 54, 1128, 972, 300) 30 (New-Brush '#FFFFFF') (New-Pen '#F3A9BA' 3)
Draw-CenteredText $G '3問の答えをつなげて、8タイプへ' ([Drawing.Font]::new('Yu Gothic UI', 31, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)) $Accent (New-Object Drawing.RectangleF 160, 1146, 760, 42)
Draw-CenteredText $G '例：つ・と・じ → 透明感モデルモビー' ([Drawing.Font]::new('Yu Gothic UI', 18, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)) $Muted (New-Object Drawing.RectangleF 220, 1186, 640, 28)

$Types = @(
  @{code='つとじ'; name='透明感モデルモビー'; line='細部から透明感を育てる'; path=$Images.clear; color='#E94878'},
  @{code='つぐじ'; name='グルメモビー'; line='内側から艶を育てる'; path=$Images.gourmet; color='#FF8A18'},
  @{code='つとし'; name='美容エディターモビー'; line='やさしく信頼感を届ける'; path=$Images.editor; color='#2D8FD6'},
  @{code='つぐし'; name='美容インフルエンサーモビー'; line='実感を明るくシェア'; path=$Images.influencer; color='#34B27B'},
  @{code='わとじ'; name='韓ドラ女優モビー'; line='透明感に韓国美容を更新'; path=$Images.drama; color='#9B6BD3'},
  @{code='わぐじ'; name='美容研究家モビー'; line='新しい美容で艶を研究'; path=$Images.researcher; color='#FF8A18'},
  @{code='わとし'; name='韓国コスメコンシェルジュモビー'; line='発見を使える情報へ'; path=$Images.concierge; color='#11A68A'},
  @{code='わぐし'; name='韓国アイドルモビー'; line='最新のきれいを届ける'; path=$Images.idol; color='#E94878'}
)

$ChipW = 222
$ChipH = 78
$StartX = 78
$StartY = 1232
$GapX = 24
$GapY = 28
for ($I = 0; $I -lt $Types.Count; $I++) {
  $Col = $I % 4
  $Row = [Math]::Floor($I / 4)
  Draw-TypeChip $G $Types[$I] ($StartX + ($ChipW + $GapX) * $Col) ($StartY + ($ChipH + $GapY) * $Row) $ChipW $ChipH $Types[$I].color
}

Draw-CenteredText $G '結果では Beauty Note も表示' ([Drawing.Font]::new('Yu Gothic UI', 17, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)) $Accent (New-Object Drawing.RectangleF 260, 1444, 560, 28)

$Bmp.Save($CodePath, [Drawing.Imaging.ImageFormat]::Png)
$G.Dispose()
$Bmp.Dispose()

$PromptLines = @(
  'Use case: infographic-diagram',
  'Asset type: TikTok / social post, 1080x1500',
  'Primary request: regenerate a polished Japanese Beauty Mood diagnosis infographic based on the deterministic code image.',
  'Title text must be exactly: ビューティムード診断',
  'Use only three axes from docs/miyake-yuko: A 美容設計 つ=積み重ね / わ=渡韓アップデート, B 印象ムード と=透明感 / ぐ=グロウ, C 届け方 じ=自分軸 / し=シェア提案.',
  'Use K-beauty Mobby character imagery inspired by docs/miyake-yuko/img/8mobby-toka.',
  'Keep all text minimal, legible, and exact. Warm cream/pink background, rounded cards, clean social infographic style.',
  'Avoid extra title text, avoid Roman letter axis codes as primary choices, avoid changing hiragana choices.'
)
[IO.File]::WriteAllText($PromptPath, [string]::Join([Environment]::NewLine, $PromptLines) + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))

Write-Output $CodePath
Write-Output $PromptPath
