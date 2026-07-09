$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/one-toka-source-lock'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
$CleanDir = Join-Path $OutDir '8mobby-toka-clean'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
New-Item -ItemType Directory -Path $CleanDir -Force | Out-Null

function B($h){ New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($h)) }
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
  for($y=0;$y -lt $bmp.Height;$y++){
    for($x=0;$x -lt $bmp.Width;$x++){
      $c=$bmp.GetPixel($x,$y)
      $max=[Math]::Max($c.R,[Math]::Max($c.G,$c.B)); $min=[Math]::Min($c.R,[Math]::Min($c.G,$c.B))
      if($min -ge 220 -and ($max-$min) -le 10){ $bmp.SetPixel($x,$y,[Drawing.Color]::FromArgb(0,255,255,255)) }
    }
  }
  $bmp.Save($dst,[Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
function DrawCodeBg($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff7df'))
  $lg=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff9e9'),[Drawing.ColorTranslator]::FromHtml('#ffe6ef'),90)
  $g.FillRectangle($lg,0,0,1080,1500); $lg.Dispose()
  for($i=0;$i -lt 14;$i++){ $pen=Pn '#ef9ab5' 3; $x=50+(($i*193)%960); $y=80+(($i*157)%1300); $g.DrawEllipse($pen,$x,$y,18,18); $pen.Dispose() }
}
function Hero($g,$name,$file){
  RR $g 62 214 956 520 42 (B '#fffefa') (Pn '#e94d7a' 5)
  RR $g 100 252 108 76 28 (B '#e94d7a') $null
  T $g '1位' $Rank (B '#ffffff') 100 252 108 76
  ImgFit $g $file 92 308 520 370
  T $g $name $LabelBig (B '#d7195b') 612 330 348 72 'Near'
  T $g '華やかさと透明感で主役感' $Text (B '#3b2a2a') 612 410 348 48 'Near'
  T $g '韓国アイドル風メイクに合う' $Text (B '#3b2a2a') 612 462 348 48 'Near'
}
function Mini($g,$rank,$name,$file,$x,$y,$accent){
  RR $g $x $y 450 250 34 (B '#fffefa') (Pn $accent 4)
  RR $g ($x+22) ($y+22) 74 58 22 (B $accent) $null
  T $g ($rank.ToString()+'位') $RankSmall (B '#ffffff') ($x+22) ($y+22) 74 58
  ImgFit $g $file ($x+26) ($y+86) 210 128
  T $g $name $Label (B $accent) ($x+238) ($y+78) 186 68 'Near'
}

$Title=F 'HGP創英角ﾎﾟｯﾌﾟ体' 48 'Bold'
$Sub=F 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'
$LabelBig=F 'HG丸ｺﾞｼｯｸM-PRO' 33 'Bold'
$Label=F 'HG丸ｺﾞｼｯｸM-PRO' 21 'Bold'
$Text=F 'HG丸ｺﾞｼｯｸM-PRO' 21 'Bold'
$Rank=F 'HG丸ｺﾞｼｯｸM-PRO' 30 'Bold'
$RankSmall=F 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'
$Foot=F 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $clean=Join-Path $CleanDir $_.Name; CleanCheckerSimple $_.FullName $clean; $Map[$_.BaseName]=$clean }
$Rows=@(
  @{Name='韓国アイドルモビー'; Color='#e94d7a'},
  @{Name='韓国コスメコンシェルジュモビー'; Color='#ff8a25'},
  @{Name='透明感モデルモビー'; Color='#27a879'},
  @{Name='美容インフルエンサーモビー'; Color='#219fb0'},
  @{Name='韓ドラ女優モビー'; Color='#6e63d8'}
)

function DrawAll($g,$useAi){
  if(-not $useAi){ DrawCodeBg $g }
  T $g 'ビューティムード診断' $Sub (B '#e94d7a') 70 36 940 34
  T $g '韓国アイドル風メイクに合うランキング' $Title (B '#c01852') 70 82 940 62
  T $g '大きめキャラで見る TOP5' $Sub (B '#3b2a2a') 70 150 940 34
  Hero $g $Rows[0].Name $Map[$Rows[0].Name]
  Mini $g 2 $Rows[1].Name $Map[$Rows[1].Name] 62 772 $Rows[1].Color
  Mini $g 3 $Rows[2].Name $Map[$Rows[2].Name] 568 772 $Rows[2].Color
  Mini $g 4 $Rows[3].Name $Map[$Rows[3].Name] 62 1054 $Rows[3].Color
  Mini $g 5 $Rows[4].Name $Map[$Rows[4].Name] 568 1054 $Rows[4].Color
  RR $g 190 1418 700 42 21 (B '#fffdf8') (Pn '#f0a5b9' 2)
  T $g '三宅裕子コラボ' $Foot (B '#e94d7a') 190 1421 700 35
}

$bmp=New-Object Drawing.Bitmap 1080,1500; $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'; DrawAll $g $false
$CodeOut=Join-Path $OutDir 'beauty-mood-kidol-ranking-large-code.png'; $bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()

$AiBg=Join-Path $OutDir 'beauty-mood-kidol-ranking-large-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500; $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg); $g.DrawImage($bg,0,0,1080,1500); $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(70,255,255,255)); $g.FillRectangle($veil,0,0,1080,1500); $veil.Dispose()
  DrawAll $g $true
  $AiOut=Join-Path $OutDir 'beauty-mood-kidol-ranking-large-ai-source-lock.png'; $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
