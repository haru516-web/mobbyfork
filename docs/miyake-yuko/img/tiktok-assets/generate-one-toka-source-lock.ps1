$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies 'System.Drawing' -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;

public static class TokaCleaner {
  static bool IsBg(Color c) {
    if (c.A == 0) return true;
    int max = Math.Max(c.R, Math.Max(c.G, c.B));
    int min = Math.Min(c.R, Math.Min(c.G, c.B));
    return min >= 220 && (max - min) <= 10;
  }

  public static void Clean(string src, string dst) {
    using (var source = new Bitmap(src))
    using (var bmp = new Bitmap(source.Width, source.Height, PixelFormat.Format32bppArgb)) {
      using (var g = Graphics.FromImage(bmp)) g.DrawImage(source, 0, 0, source.Width, source.Height);
      int w = bmp.Width, h = bmp.Height;
      bool[] seen = new bool[w * h];
      Queue<Point> q = new Queue<Point>();
      Action<int,int> enqueue = (x,y) => {
        int idx = y * w + x;
        if (seen[idx]) return;
        seen[idx] = true;
        if (IsBg(bmp.GetPixel(x,y))) {
          bmp.SetPixel(x,y,Color.FromArgb(0,255,255,255));
          q.Enqueue(new Point(x,y));
        }
      };
      for (int x = 0; x < w; x++) { enqueue(x,0); enqueue(x,h-1); }
      for (int y = 0; y < h; y++) { enqueue(0,y); enqueue(w-1,y); }
      while (q.Count > 0) {
        var p = q.Dequeue();
        if (p.X > 0) enqueue(p.X - 1, p.Y);
        if (p.X < w - 1) enqueue(p.X + 1, p.Y);
        if (p.Y > 0) enqueue(p.X, p.Y - 1);
        if (p.Y < h - 1) enqueue(p.X, p.Y + 1);
      }
      bmp.Save(dst, ImageFormat.Png);
    }
  }
}
"@

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
function ImgFit($g,$path,$x,$y,$w,$h){
  $im=[Drawing.Image]::FromFile($path)
  $sc=[Math]::Min($w/$im.Width,$h/$im.Height)
  $dw=$im.Width*$sc; $dh=$im.Height*$sc
  $g.DrawImage($im,$x+($w-$dw)/2,$y+($h-$dh)/2,$dw,$dh)
  $im.Dispose()
}
function CleanChecker($src,$dst){
  if(Test-Path -LiteralPath $dst){ return }
  [TokaCleaner]::Clean($src,$dst)
}
function DrawBg($g){
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff6df'))
  $wash=New-Object Drawing.Drawing2D.LinearGradientBrush((New-Object Drawing.Rectangle 0,0,1080,1500),[Drawing.ColorTranslator]::FromHtml('#fff9e8'),[Drawing.ColorTranslator]::FromHtml('#ffeaf1'),90)
  $g.FillRectangle($wash,0,0,1080,1500); $wash.Dispose()
  for($i=0;$i -lt 18;$i++){
    $x=40+(($i*137)%1000); $y=70+(($i*211)%1320); $s=10+(($i*7)%18)
    $pen=Pn '#f2a7bc' 3
    $g.DrawLine($pen,$x,$y+$s/2,$x+$s,$y+$s/2)
    $g.DrawLine($pen,$x+$s/2,$y,$x+$s/2,$y+$s)
    $pen.Dispose()
  }
}
function RankCard($g,$rank,$name,$file,$y,$accent,$scale='normal'){
  $x=76; $w=928; $h=210
  RR $g ($x+8) ($y+8) $w $h 32 (New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(45,80,50,30))) $null
  RR $g $x $y $w $h 32 (B '#fffdf8') (Pn $accent 4)
  RR $g ($x+24) ($y+26) 82 82 24 (B $accent) $null
  T $g ($rank.ToString()+'位') $RankF (B '#ffffff') ($x+24) ($y+26) 82 82
  $imgW=280; $imgH=174
  if($rank -eq 1){ $imgW=320; $imgH=196 }
  ImgFit $g $file ($x+130) ($y+12) $imgW $imgH
  T $g $name $Label (B $accent) ($x+440) ($y+46) 440 54 'Near'
  T $g '韓国アイドル風メイクに合う' $Small (B '#4a3535') ($x+440) ($y+104) 440 38 'Near'
}

$Title=F 'HGP創英角ﾎﾟｯﾌﾟ体' 50 'Bold'
$Sub=F 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'
$Label=F 'HG丸ｺﾞｼｯｸM-PRO' 28 'Bold'
$Small=F 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'
$RankF=F 'HG丸ｺﾞｼｯｸM-PRO' 28 'Bold'
$Foot=F 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'

$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object {
  $clean=Join-Path $CleanDir $_.Name
  CleanChecker $_.FullName $clean
  $Map[$_.BaseName]=$clean
}
$Rows=@(
  @{Name='韓国アイドルモビー'; Color='#e94d7a'},
  @{Name='韓国コスメコンシェルジュモビー'; Color='#ff8a25'},
  @{Name='透明感モデルモビー'; Color='#27a879'},
  @{Name='美容インフルエンサーモビー'; Color='#219fb0'},
  @{Name='韓ドラ女優モビー'; Color='#6e63d8'}
)

$bmp=New-Object Drawing.Bitmap 1080,1500
$g=[Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode='AntiAlias'
$g.TextRenderingHint='AntiAliasGridFit'
DrawBg $g
T $g 'ビューティムード診断' $Sub (B '#e94d7a') 70 34 940 30
T $g '韓国アイドル風メイクに合うランキング' $Title (B '#c01852') 70 76 940 72
T $g '華やかさと透明感で選ぶ' $Sub (B '#3b2a2a') 70 150 940 34
for($i=0;$i -lt $Rows.Count;$i++){
  $row=$Rows[$i]
  RankCard $g ($i+1) $row.Name $Map[$row.Name] (224+$i*226) $row.Color
}
RR $g 190 1416 700 42 21 (B '#fffdf8') (Pn '#f0a5b9' 2)
T $g '三宅裕子コラボ' $Foot (B '#e94d7a') 190 1419 700 35
$CodeOut=Join-Path $OutDir 'beauty-mood-kidol-ranking-code.png'
$bmp.Save($CodeOut,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$AiBg = Join-Path $OutDir 'beauty-mood-kidol-ranking-ai-bg.png'
if(Test-Path -LiteralPath $AiBg){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode='AntiAlias'
  $g.TextRenderingHint='AntiAliasGridFit'
  $bg=[Drawing.Image]::FromFile($AiBg)
  $g.DrawImage($bg,0,0,1080,1500)
  $bg.Dispose()
  $veil=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(75,255,255,255))
  $g.FillRectangle($veil,0,0,1080,1500)
  $veil.Dispose()
  T $g 'ビューティムード診断' $Sub (B '#e94d7a') 70 34 940 30
  T $g '韓国アイドル風メイクに合うランキング' $Title (B '#c01852') 70 76 940 72
  T $g '華やかさと透明感で選ぶ' $Sub (B '#3b2a2a') 70 150 940 34
  for($i=0;$i -lt $Rows.Count;$i++){
    $row=$Rows[$i]
    RankCard $g ($i+1) $row.Name $Map[$row.Name] (224+$i*226) $row.Color
  }
  RR $g 190 1416 700 42 21 (B '#fffdf8') (Pn '#f0a5b9' 2)
  T $g '三宅裕子コラボ' $Foot (B '#e94d7a') 190 1419 700 35
  $AiOut=Join-Path $OutDir 'beauty-mood-kidol-ranking-ai-source-lock.png'
  $bmp.Save($AiOut,[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output $AiOut
}
Write-Output $CodeOut
