$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/one-toka-source-lock'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
$CleanDir = Join-Path $OutDir '8mobby-toka-clean'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
New-Item -ItemType Directory -Path $CleanDir -Force | Out-Null

function B($h){ New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($h)) }
function BA($a,$h){ $c=[Drawing.ColorTranslator]::FromHtml($h); New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb($a,$c.R,$c.G,$c.B)) }
function Pn($h,$w){ $p=New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($h)), $w; $p.StartCap='Round'; $p.EndCap='Round'; $p }
function F($n,$s,$st='Regular'){ try { New-Object Drawing.Font($n,$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } catch { New-Object Drawing.Font('Yu Gothic UI',$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } }
function RR($g,$x,$y,$w,$h,$r,$fill,$stroke=$null){ $path=New-Object Drawing.Drawing2D.GraphicsPath; $d=$r*2; $path.AddArc($x,$y,$d,$d,180,90); $path.AddArc($x+$w-$d,$y,$d,$d,270,90); $path.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $path.AddArc($x,$y+$h-$d,$d,$d,90,90); $path.CloseFigure(); if($fill){$g.FillPath($fill,$path)}; if($stroke){$g.DrawPath($stroke,$path)}; $path.Dispose() }
function T($g,$t,$f,$br,$x,$y,$w,$h,$a='Center'){ $sf=New-Object Drawing.StringFormat; $sf.Alignment=[Drawing.StringAlignment]::$a; $sf.LineAlignment='Center'; $sf.Trimming='EllipsisCharacter'; $g.DrawString($t,$f,$br,(New-Object Drawing.RectangleF $x,$y,$w,$h),$sf); $sf.Dispose() }
function ImgFit($g,$path,$x,$y,$w,$h){ $im=[Drawing.Image]::FromFile($path); $sc=[Math]::Min($w/$im.Width,$h/$im.Height); $dw=$im.Width*$sc; $dh=$im.Height*$sc; $g.DrawImage($im,$x+($w-$dw)/2,$y+($h-$dh)/2,$dw,$dh); $im.Dispose() }
function CleanCheckerSimple($src,$dst){
  if(Test-Path -LiteralPath $dst){ return }
  $orig=[Drawing.Bitmap]::FromFile($src)
  $bmp=New-Object Drawing.Bitmap -ArgumentList $orig.Width,$orig.Height,([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $gg=[Drawing.Graphics]::FromImage($bmp); $gg.DrawImage($orig,0,0,$orig.Width,$orig.Height); $gg.Dispose(); $orig.Dispose()
  for($y=0;$y -lt $bmp.Height;$y++){ for($x=0;$x -lt $bmp.Width;$x++){ $c=$bmp.GetPixel($x,$y); $max=[Math]::Max($c.R,[Math]::Max($c.G,$c.B)); $min=[Math]::Min($c.R,[Math]::Min($c.G,$c.B)); if($min -ge 220 -and ($max-$min) -le 10){ $bmp.SetPixel($x,$y,[Drawing.Color]::FromArgb(0,255,255,255)) } } }
  $bmp.Save($dst,[Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

$Title=F 'HGP創英角ﾎﾟｯﾌﾟ体' 58 'Bold'
$Sub=F 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'
$NameF=F 'HG丸ｺﾞｼｯｸM-PRO' 23 'Bold'
$BodyF=F 'Yu Gothic UI' 17 'Bold'
$NoteF=F 'Yu Gothic UI' 15 'Bold'
$RankF=F 'Georgia' 52 'Bold'
$Foot=F 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $clean=Join-Path $CleanDir $_.Name; CleanCheckerSimple $_.FullName $clean; $Map[$_.BaseName]=$clean }
$Rows=@(
  @{Name='透明感モデルモビー'; Color='#d79b35'; Body="年齢を重ねるほどに透明感が増して、`nどこにいても洗練された美しさに。"; Note="ふとした瞬間の`n透明感が、`n最高の武器に"},
  @{Name='韓ドラ女優モビー'; Color='#9b9692'; Body="上品さと余裕がにじみ出て、`nヒロインのようなオーラが宿る存在に。"; Note="落ち着きと品が`nあなたの魅力を`nさらに引き立てる"},
  @{Name='美容エディターモビー'; Color='#d67b48'; Body="センスと経験が磨かれて、`n自分らしい美しさを知る大人の余裕が魅力に。"; Note="知的な美しさが`n年齢とともに`nもっと映える"},
  @{Name='美容研究家モビー'; Color='#ef8b9b'; Body="知識と探求心が深まって、`n芯のある美しさと信頼感を身につける人に。"; Note="内側からの美が`nあなたの魅力を`n底上げしていく"},
  @{Name='韓国コスメコンシェルジュモビー'; Color='#df7c86'; Body="トレンドを上手に取り入れて、`n自分に似合うものを知る賢い可愛さに。"; Note="賢くアップデート`nする姿が、`nずっと魅力的"},
  @{Name='韓国アイドルモビー'; Color='#e4647f'; Body="年齢を重ねても輝きをキープして、`n努力と笑顔で愛され続けるアイドル感に。"; Note="輝きを楽しむ心が`nいつまでも`nあなたの強さに"},
  @{Name='美容インフルエンサーモビー'; Color='#e86f8f'; Body="発信を通して自分らしさが確立され、`n共感される存在としてもっと魅力的に輝く人に。"; Note="自分らしく輝く姿が`nみんなの憧れに`nなっていく"},
  @{Name='グルメモビー'; Color='#d98d5c'; Body="美味しいものを楽しむ余裕が、`n心の豊かさとハッピーオーラにつながっていく人に。"; Note="幸せを楽しむ人は`n年齢を重ねても`n素敵でいられる"}
)

function DrawDecor($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff7ef'))
  $lg=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff9f2'),[Drawing.ColorTranslator]::FromHtml('#ffe9e4'),90)
  $g.FillRectangle($lg,0,0,1080,1500); $lg.Dispose()
  $pen=Pn '#efb7aa' 3
  $g.DrawLine($pen,88,178,992,178); $g.DrawLine($pen,92,1376,988,1376)
  $pen.Dispose()
  T $g '♡' (F 'Yu Gothic UI' 34 'Bold') (B '#e88fa0') 88 222 36 36
  T $g '✦' (F 'Yu Gothic UI' 30 'Bold') (B '#e7aa65') 900 68 40 40
  T $g '♡' (F 'Yu Gothic UI' 26 'Bold') (B '#e88fa0') 955 116 40 40
}
function DrawHeader($g){
  T $g '大人になって' $Title (B '#a9354b') 70 46 940 72
  T $g '垢抜けるランキング' $Title (B '#a9354b') 70 112 940 76
  RR $g 330 196 420 44 22 (B '#fff8f1') (Pn '#efb7aa' 2)
  T $g '♡ 洗練されていく魅力 ♡' $Sub (B '#c75c63') 330 198 420 40
}
function DrawRank($g,$rank,$row,$y){
  $accent=$row.Color
  RR $g 58 $y 964 141 26 (BA 232 '#fffdf9') (Pn '#f0c2b8' 2)
  T $g ([string]$rank) $RankF (B $accent) 82 ($y+24) 90 78
  T $g '♛' (F 'Yu Gothic UI' 29 'Bold') (B $accent) 104 ($y+8) 48 28
  T $g '⌒ ⌒' (F 'Yu Gothic UI' 28 'Regular') (B $accent) 82 ($y+88) 90 30
  T $g $row.Name $NameF (B '#d94764') 205 ($y+15) 345 38 'Near'
  T $g $row.Body $BodyF (B '#5b3835') 205 ($y+54) 340 68 'Near'
  ImgFit $g $Map[$row.Name] 548 ($y-24) 292 188
  RR $g 826 ($y+24) 160 88 44 (BA 145 '#f7d7d3') $null
  T $g $row.Note $NoteF (B '#a6565c') 842 ($y+30) 128 72
}
function DrawAll($g,$useAi){
  if(-not $useAi){ DrawDecor $g }
  DrawHeader $g
  for($i=0;$i -lt $Rows.Count;$i++){ DrawRank $g ($i+1) $Rows[$i] (282+$i*134) }
  RR $g 178 1378 724 42 21 (BA 225 '#fff4ee') $null
  T $g '♡ あなたらしく、自分のペースで。未来のあなたが、もっと楽しみになるよ ♡' $Foot (B '#a94d51') 190 1380 700 38
}

$bmp=New-Object Drawing.Bitmap 1080,1500
$g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
DrawAll $g $false
$CodeOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-reference-code.png'
$bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$AiBg=Join-Path $OutDir 'beauty-mood-grownup-ranking-reference-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg); $g.DrawImage($bg,0,0,1080,1500); $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(55,255,255,255)); $g.FillRectangle($veil,0,0,1080,1500); $veil.Dispose()
  DrawAll $g $true
  $AiOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-reference-ai-source-lock.png'
  $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
