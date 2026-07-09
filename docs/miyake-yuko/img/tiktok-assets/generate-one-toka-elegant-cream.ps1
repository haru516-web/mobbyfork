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

$Title=F 'Yu Mincho' 54 'Bold'
$Sub=F 'Yu Gothic UI' 21 'Bold'
$NameF=F 'Yu Gothic UI' 25 'Bold'
$TagF=F 'Yu Gothic UI' 17 'Bold'
$RankF=F 'Georgia' 54 'Bold'
$CrownF=F 'Yu Gothic UI' 28 'Bold'
$Foot=F 'Yu Gothic UI' 17 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $clean=Join-Path $CleanDir $_.Name; CleanCheckerSimple $_.FullName $clean; $Map[$_.BaseName]=$clean }
$Rows=@(
  @{Name='透明感モデルモビー'; Color='#d8a13d'; Tag='透明感が増す'},
  @{Name='韓ドラ女優モビー'; Color='#9f9894'; Tag='上品に映える'},
  @{Name='美容エディターモビー'; Color='#d77a4e'; Tag='センスで垢抜け'},
  @{Name='美容研究家モビー'; Color='#e78396'; Tag='知性で磨く'},
  @{Name='韓国コスメコンシェルジュモビー'; Color='#dd7888'; Tag='似合うを更新'},
  @{Name='韓国アイドルモビー'; Color='#e3637f'; Tag='輝きキープ'},
  @{Name='美容インフルエンサーモビー'; Color='#e86f8f'; Tag='自分らしく発信'},
  @{Name='グルメモビー'; Color='#d98d5c'; Tag='余裕が魅力'}
)

function DrawBase($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff3df'))
  $lg=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff8ec'),[Drawing.ColorTranslator]::FromHtml('#ffeadf'),90)
  $g.FillRectangle($lg,0,0,1080,1500); $lg.Dispose()
  T $g '♡' (F 'Yu Gothic UI' 28 'Bold') (BA 135 '#dd7f8d') 120 92 40 40
  T $g '✦' (F 'Yu Gothic UI' 26 'Bold') (BA 145 '#d8a13d') 884 88 40 40
  $p=Pn '#efc9bd' 2; $g.DrawLine($p,94,244,986,244); $g.DrawLine($p,94,1370,986,1370); $p.Dispose()
}
function DrawHeader($g){
  T $g '大人になって' $Title (B '#a9344a') 70 48 940 66
  T $g '垢抜けるランキング' $Title (B '#a9344a') 70 112 940 74
  RR $g 340 196 400 42 21 (BA 230 '#fff8ef') (Pn '#edc5b5' 2)
  T $g '♡ 洗練されていく魅力 ♡' $Sub (B '#b85d64') 340 198 400 38
}
function DrawRank($g,$rank,$row,$y){
  $accent=$row.Color
  RR $g 58 $y 964 132 24 (BA 236 '#fffdf8') (Pn '#efc9bd' 2)
  T $g '♛' $CrownF (B $accent) 94 ($y+14) 64 26
  T $g ([string]$rank) $RankF (B $accent) 82 ($y+42) 88 62
  T $g $row.Name $NameF (B '#d94764') 204 ($y+28) 338 38 'Near'
  RR $g 204 ($y+78) 220 32 16 (BA 210 '#ffe8e4') $null
  T $g $row.Tag $TagF (B '#914951') 210 ($y+80) 208 28
  ImgFit $g $Map[$row.Name] 548 ($y-26) 292 188
  RR $g 842 ($y+34) 132 64 32 (BA 145 '#f6d8d2') $null
  T $g '♡' (F 'Yu Gothic UI' 22 'Bold') (B '#d94764') 888 ($y+47) 40 36
}
function DrawAll($g,$useAi){
  if(-not $useAi){ DrawBase $g }
  DrawHeader $g
  for($i=0;$i -lt $Rows.Count;$i++){ DrawRank $g ($i+1) $Rows[$i] (282+$i*134) }
  RR $g 210 1380 660 38 19 (BA 228 '#fff8ef') (Pn '#edc5b5' 2)
  T $g 'ビューティムード診断' $Foot (B '#c75562') 210 1381 660 35
}

$bmp=New-Object Drawing.Bitmap 1080,1500
$g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
DrawAll $g $false
$CodeOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-elegant-cream-code.png'
$bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$AiBg=Join-Path $OutDir 'beauty-mood-grownup-ranking-elegant-cream-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg); $g.DrawImage($bg,0,0,1080,1500); $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(48,255,255,255)); $g.FillRectangle($veil,0,0,1080,1500); $veil.Dispose()
  DrawAll $g $true
  $AiOut=Join-Path $OutDir 'beauty-mood-grownup-ranking-elegant-cream-ai-source-lock.png'
  $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
