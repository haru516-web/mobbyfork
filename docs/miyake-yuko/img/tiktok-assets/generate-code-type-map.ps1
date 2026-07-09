$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/code-type-map'
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

$Title=F 'Yu Mincho' 50 'Bold'
$Sub=F 'Yu Gothic UI' 20 'Bold'
$CodeF=F 'Yu Mincho' 31 'Bold'
$NameF=F 'Yu Gothic UI' 20 'Bold'
$AxisF=F 'Yu Gothic UI' 15 'Bold'
$Foot=F 'Yu Gothic UI' 16 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $clean=Join-Path $CleanDir $_.Name; CleanCheckerSimple $_.FullName $clean; $Map[$_.BaseName]=$clean }
$Rows=@(
  @{Code='つとじ'; Name='透明感モデルモビー'; Color='#d8a13d'; Axis='積み重ね / 透明感 / 自分軸'},
  @{Code='つとし'; Name='美容エディターモビー'; Color='#d77a4e'; Axis='積み重ね / 透明感 / シェア'},
  @{Code='つぐじ'; Name='グルメモビー'; Color='#d98d5c'; Axis='積み重ね / グロウ / 自分軸'},
  @{Code='つぐし'; Name='美容インフルエンサーモビー'; Color='#e86f8f'; Axis='積み重ね / グロウ / シェア'},
  @{Code='わとじ'; Name='韓ドラ女優モビー'; Color='#9f9894'; Axis='渡韓 / 透明感 / 自分軸'},
  @{Code='わとし'; Name='韓国コスメコンシェルジュモビー'; Color='#dd7888'; Axis='渡韓 / 透明感 / シェア'},
  @{Code='わぐじ'; Name='美容研究家モビー'; Color='#e78396'; Axis='渡韓 / グロウ / 自分軸'},
  @{Code='わぐし'; Name='韓国アイドルモビー'; Color='#e3637f'; Axis='渡韓 / グロウ / シェア'}
)

function DrawBase($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff3df'))
  $lg=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff9ed'),[Drawing.ColorTranslator]::FromHtml('#ffeadf'),90)
  $g.FillRectangle($lg,0,0,1080,1500); $lg.Dispose()
  T $g '♡' (F 'Yu Gothic UI' 28 'Bold') (BA 130 '#dd7f8d') 128 86 40 40
  T $g '✦' (F 'Yu Gothic UI' 24 'Bold') (BA 145 '#d8a13d') 904 96 40 40
  $p=Pn '#efc9bd' 2; $g.DrawLine($p,100,260,980,260); $g.DrawLine($p,100,1370,980,1370); $p.Dispose()
}
function DrawHeader($g){
  T $g 'ビューティムード診断' $Sub (B '#c75562') 80 42 920 34
  T $g 'ひらがな対応表' $Title (B '#a9344a') 80 86 920 72
  RR $g 284 174 512 44 22 (BA 230 '#fff8ef') (Pn '#edc5b5' 2)
  T $g '3文字をつなげて、8タイプへ' $Sub (B '#b85d64') 284 176 512 40
}
function DrawRow($g,$i,$row,$x,$y){
  $accent=$row.Color
  RR $g $x $y 456 232 26 (BA 238 '#fffdf8') (Pn '#efc9bd' 2)
  RR $g ($x+20) ($y+22) 132 58 22 (BA 230 '#fff0eb') (Pn $accent 2)
  T $g $row.Code $CodeF (B $accent) ($x+20) ($y+20) 132 60
  T $g $row.Name $NameF (B '#d94764') ($x+170) ($y+18) 264 52 'Near'
  T $g $row.Axis $AxisF (B '#7a514f') ($x+170) ($y+68) 264 26 'Near'
  ImgFit $g $Map[$row.Name] ($x+98) ($y+94) 286 126
}
function DrawAll($g,$useAi){
  if(-not $useAi){ DrawBase $g }
  DrawHeader $g
  for($i=0;$i -lt $Rows.Count;$i++){
    $col=$i%2; $r=[Math]::Floor($i/2)
    DrawRow $g $i $Rows[$i] (58+$col*508) (286+$r*254)
  }
  RR $g 210 1378 660 40 20 (BA 228 '#fff8ef') (Pn '#edc5b5' 2)
  T $g 'つ / わ  ×  と / ぐ  ×  じ / し' $Foot (B '#c75562') 210 1380 660 36
}

$bmp=New-Object Drawing.Bitmap 1080,1500
$g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
DrawAll $g $false
$CodeOut=Join-Path $OutDir 'beauty-mood-code-type-map-code.png'
$bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$AiBg=Join-Path $OutDir 'beauty-mood-code-type-map-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg); $g.DrawImage($bg,0,0,1080,1500); $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(52,255,255,255)); $g.FillRectangle($veil,0,0,1080,1500); $veil.Dispose()
  DrawAll $g $true
  $AiOut=Join-Path $OutDir 'beauty-mood-code-type-map-ai-source-lock.png'
  $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
