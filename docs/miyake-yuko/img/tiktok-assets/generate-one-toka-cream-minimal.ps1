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

$Title=F 'HGP創英角ﾎﾟｯﾌﾟ体' 56 'Bold'
$Sub=F 'HGP創英角ﾎﾟｯﾌﾟ体' 22 'Bold'
$NameF=F 'HGP創英角ﾎﾟｯﾌﾟ体' 24 'Bold'
$TagF=F 'HGP創英角ﾎﾟｯﾌﾟ体' 18 'Bold'
$RankF=F 'HGP創英角ﾎﾟｯﾌﾟ体' 48 'Bold'
$Foot=F 'HGP創英角ﾎﾟｯﾌﾟ体' 17 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $clean=Join-Path $CleanDir $_.Name; CleanCheckerSimple $_.FullName $clean; $Map[$_.BaseName]=$clean }
$Rows=@(
  @{Name='透明感モデルモビー'; Color='#d49a3a'; Tag='透明感が増す'},
  @{Name='韓ドラ女優モビー'; Color='#9b8f8b'; Tag='上品に映える'},
  @{Name='美容エディターモビー'; Color='#d77748'; Tag='センスで垢抜け'},
  @{Name='美容研究家モビー'; Color='#ea8395'; Tag='知性で磨く'},
  @{Name='韓国コスメコンシェルジュモビー'; Color='#df7c86'; Tag='似合うを更新'},
  @{Name='韓国アイドルモビー'; Color='#e4647f'; Tag='輝きキープ'},
  @{Name='美容インフルエンサーモビー'; Color='#e86f8f'; Tag='自分らしく発信'},
  @{Name='グルメモビー'; Color='#d98d5c'; Tag='余裕が魅力'}
)

function DrawCream($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff4dc'))
  $lg=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff8e8'),[Drawing.ColorTranslator]::FromHtml('#fff0d7'),90)
  $g.FillRectangle($lg,0,0,1080,1500); $lg.Dispose()
  for($i=0;$i -lt 14;$i++){
    $x=56+(($i*151)%960); $y=80+(($i*227)%1310)
    T $g '♡' (F 'Yu Gothic UI' 22 'Bold') (BA 120 '#eaa0a6') $x $y 30 30
  }
}
function DrawHeader($g){
  T $g '大人になって' $Title (B '#a9354b') 70 48 940 68
  T $g '垢抜けるランキング' $Title (B '#a9354b') 70 110 940 72
  RR $g 330 194 420 42 21 (B '#fffaf0') (Pn '#f0c8b6' 2)
  T $g '洗練されていく魅力' $Sub (B '#c75c63') 330 196 420 38
}
function DrawRank($g,$rank,$row,$y){
  $accent=$row.Color
  RR $g 58 $y 964 132 24 (BA 238 '#fffdf7') (Pn '#efc9bd' 2)
  T $g ([string]$rank) $RankF (B $accent) 86 ($y+29) 76 62
  ImgFit $g $Map[$row.Name] 560 ($y-21) 315 174
  T $g $row.Name $NameF (B '#d94764') 190 ($y+24) 360 40 'Near'
  RR $g 190 ($y+76) 240 34 17 (BA 210 '#ffe7e4') $null
  T $g $row.Tag $TagF (B '#93464e') 196 ($y+77) 228 31
}
function DrawAll($g,$useAi){
  if(-not $useAi){ DrawCream $g }
  DrawHeader $g
  for($i=0;$i -lt $Rows.Count;$i++){ DrawRank $g ($i+1) $Rows[$i] (280+$i*134) }
  RR $g 205 1378 670 42 21 (B '#fffaf0') (Pn '#f0c8b6' 2)
  T $g 'ビューティムード診断' $Foot (B '#d94764') 205 1381 670 36
}

$bmp=New-Object Drawing.Bitmap 1080,1500
$g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
DrawAll $g $false
$CodeOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-cream-minimal-code.png'
$bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$AiBg=Join-Path $OutDir 'beauty-mood-grownup-ranking-cream-minimal-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg); $g.DrawImage($bg,0,0,1080,1500); $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(88,255,255,255)); $g.FillRectangle($veil,0,0,1080,1500); $veil.Dispose()
  DrawAll $g $true
  $AiOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-cream-minimal-ai-source-lock.png'
  $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
