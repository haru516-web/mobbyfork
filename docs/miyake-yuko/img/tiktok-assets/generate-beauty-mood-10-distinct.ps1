$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/variants-10-distinct'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

function Brush($hex){ New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($hex)) }
function PenX($hex,$w){ $p=New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($hex)), $w; $p.StartCap='Round'; $p.EndCap='Round'; $p }
function FontX($name,$size,$style='Regular'){ try { New-Object Drawing.Font($name,$size,[Drawing.FontStyle]::$style,[Drawing.GraphicsUnit]::Pixel) } catch { New-Object Drawing.Font('Yu Gothic UI',$size,[Drawing.FontStyle]::$style,[Drawing.GraphicsUnit]::Pixel) } }
function RRect($g,$x,$y,$w,$h,$r,$fill,$stroke=$null){ $path=New-Object Drawing.Drawing2D.GraphicsPath; $d=$r*2; $path.AddArc($x,$y,$d,$d,180,90); $path.AddArc($x+$w-$d,$y,$d,$d,270,90); $path.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $path.AddArc($x,$y+$h-$d,$d,$d,90,90); $path.CloseFigure(); if($fill){$g.FillPath($fill,$path)}; if($stroke){$g.DrawPath($stroke,$path)}; $path.Dispose() }
function Txt($g,$text,$font,$brush,$x,$y,$w,$h,$align='Center'){ $sf=New-Object Drawing.StringFormat; $sf.Alignment=[Drawing.StringAlignment]::$align; $sf.LineAlignment=[Drawing.StringAlignment]::Center; $sf.Trimming=[Drawing.StringTrimming]::EllipsisCharacter; $sf.FormatFlags = 0; $g.DrawString($text,$font,$brush,(New-Object Drawing.RectangleF $x,$y,$w,$h),$sf); $sf.Dispose() }
function Img($g,$path,$x,$y,$w,$h,$rot=0){ $im=[Drawing.Image]::FromFile($path); $scale=[Math]::Min($w/$im.Width,$h/$im.Height); $dw=$im.Width*$scale; $dh=$im.Height*$scale; $state=$g.Save(); $g.TranslateTransform($x+$w/2,$y+$h/2); if($rot -ne 0){$g.RotateTransform($rot)}; $g.DrawImage($im,-$dw/2,-$dh/2,$dw,$dh); $g.Restore($state); $im.Dispose() }
function Dot($g,$x,$y,$s,$c){ $b=Brush $c; $g.FillEllipse($b,$x,$y,$s,$s); $b.Dispose() }
function Choice($g,$x,$y,$w,$h,$kana,$label,$desc,$c,$fill){ $fb=Brush $fill; $p=PenX $c 4; RRect $g $x $y $w $h 26 $fb $p; $kb=Brush $c; $bb=Brush '#3b2a2a'; Txt $g $kana $Kana $kb ($x+18) ($y+16) 78 78; Txt $g $label $Label $kb ($x+108) ($y+16) ($w-124) 38 'Near'; Txt $g $desc $Small $bb ($x+108) ($y+54) ($w-124) 54 'Near'; $fb.Dispose(); $p.Dispose(); $kb.Dispose(); $bb.Dispose() }
function MiniChoice($g,$x,$y,$w,$h,$kana,$label,$c,$fill){ $fb=Brush $fill; $p=PenX $c 3; RRect $g $x $y $w $h 24 $fb $p; $kb=Brush $c; Txt $g $kana $Kana2 $kb ($x+8) ($y+7) 58 58; Txt $g $label $Label2 $kb ($x+70) ($y+6) ($w-78) 58 'Near'; $fb.Dispose(); $p.Dispose(); $kb.Dispose() }
function Q($g,$x,$y,$w,$h,$num,$text,$c){ $fb=Brush '#ffffff'; $p=PenX $c 3; RRect $g $x $y $w $h 22 $fb $p; $tb=Brush '#342525'; Txt $g $num $QFont (Brush $c) $x ($y+4) $w 34; Txt $g $text $Small $tb ($x+10) ($y+35) ($w-20) ($h-42); $fb.Dispose(); $p.Dispose(); $tb.Dispose() }
function Header($g,$variant){ $pink=Brush '#e94d7a'; $brown=Brush '#362424'; Txt $g 'ビューティムード診断' $Title $pink 80 34 920 72; Txt $g '3つの美容軸を、3問で見る簡易診断' $Sub $brown 120 104 840 34; $pink.Dispose(); $brown.Dispose() }
function Footer($g){ $p=PenX '#ef7fa0' 2; RRect $g 120 1418 840 42 21 (Brush '#fffafa') $p; Txt $g '答えをつなげて、あなたのビューティムードへ' $Foot (Brush '#e94d7a') 130 1420 820 38; $p.Dispose() }
function Scatter($g,$imgs,$count,$top,$bottom){ for($i=0;$i -lt $count;$i++){ $path=$imgs[$i % $imgs.Count].FullName; $x=40+(($i*137)%880); $y=$top+(($i*83)%($bottom-$top)); Img $g $path $x $y 120 120 ((($i%5)-2)*7) } }

$Title=FontX 'HGP創英角ﾎﾟｯﾌﾟ体' 55 'Bold'
$Sub=FontX 'HG丸ｺﾞｼｯｸM-PRO' 24 'Bold'
$Kana=FontX 'HGP創英角ﾎﾟｯﾌﾟ体' 72 'Bold'
$Kana2=FontX 'HGP創英角ﾎﾟｯﾌﾟ体' 52 'Bold'
$Label=FontX 'HG丸ｺﾞｼｯｸM-PRO' 27 'Bold'
$Label2=FontX 'HG丸ｺﾞｼｯｸM-PRO' 26 'Bold'
$Small=FontX 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'
$QFont=FontX 'Comic Sans MS' 27 'Bold'
$Foot=FontX 'HG丸ｺﾞｼｯｸM-PRO' 19 'Bold'
$Imgs=Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | Sort-Object Name
$Manifest=@()
$names=@('sticker-party','scrapbook-polaroid','chat-bubbles','cosme-shelf','game-board','magazine-cover','ticket-strips','orbit-map','compact-cards','character-stage')

for($v=1;$v -le 10;$v++){
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff5df'))
  $cream=Brush '#fff5df'; $white=Brush '#fffdfa'; $pink=Brush '#ef5f86'; $mint=Brush '#2bb894'; $blue=Brush '#2e9add'; $orange=Brush '#ff8a25'; $purple=Brush '#9c70e8'; $brown=Brush '#382626'
  Header $g $v
  switch($v){
    1 { Scatter $g $Imgs 14 135 430; RRect $g 70 452 940 820 36 (Brush '#fffdf7') (PenX '#f48cac' 4); Choice $g 105 490 395 125 'つ' '積み重ね' '毎日の美容ケアで育てたい' '#22a96d' '#eefcf4'; Choice $g 580 490 395 125 'わ' '渡韓アップデート' '韓国美容や新しい流行を試したい' '#e95588' '#fff0f6'; Q $g 430 638 220 84 'Q1' '美容の入口は？' '#e95588'; Choice $g 105 748 395 125 'と' '透明感' '清潔感と抜け感で整える' '#1b9f9f' '#effcff'; Choice $g 580 748 395 125 'ぐ' 'グロウ' 'ツヤと血色感を味方に' '#6c65d8' '#f4f2ff'; Q $g 430 896 220 84 'Q2' 'きれいの届け方は？' '#2e9add'; Choice $g 105 1006 395 125 'じ' '自分軸' '自分の感覚でじっくり選ぶ' '#ff8a25' '#fff6e9'; Choice $g 580 1006 395 125 'し' 'シェア提案' '良かったものを人にも届けたい' '#9b66de' '#f9f1ff'; Q $g 430 1154 220 84 'Q3' '求める気分は？' '#ff8a25' }
    2 { for($i=0;$i -lt 6;$i++){ Img $g $Imgs[$i].FullName (70+$i*155) 162 135 135 (($i%3-1)*8) }; RRect $g 80 330 390 300 24 (Brush '#fff') (PenX '#f6a6bd' 4); RRect $g 610 305 360 245 24 (Brush '#fff8fb') (PenX '#f6a6bd' 4); Img $g $Imgs[6].FullName 365 230 340 320 -4; MiniChoice $g 105 665 380 86 'つ' '積み重ね' '#22a96d' '#eefcf4'; MiniChoice $g 595 665 380 86 'わ' '渡韓アップデート' '#e95588' '#fff0f6'; Q $g 420 765 240 76 'Q1' '美容の入口は？' '#e95588'; MiniChoice $g 105 860 380 86 'と' '透明感' '#1b9f9f' '#effcff'; MiniChoice $g 595 860 380 86 'ぐ' 'グロウ' '#6c65d8' '#f4f2ff'; Q $g 420 960 240 76 'Q2' 'きれいの届け方は？' '#2e9add'; MiniChoice $g 105 1055 380 86 'じ' '自分軸' '#ff8a25' '#fff6e9'; MiniChoice $g 595 1055 380 86 'し' 'シェア提案' '#9b66de' '#f9f1ff'; Q $g 420 1155 240 76 'Q3' '求める気分は？' '#ff8a25' }
    3 { Img $g $Imgs[1].FullName 50 145 230 230 -7; Img $g $Imgs[7].FullName 800 140 220 220 6; $ys=@(360,650,940); $qs=@('Q1 美容の入口は？','Q2 きれいの届け方は？','Q3 求める気分は？'); $left=@(('つ','積み重ね','#22a96d'),('と','透明感','#1b9f9f'),('じ','自分軸','#ff8a25')); $right=@(('わ','渡韓アップデート','#e95588'),('ぐ','グロウ','#6c65d8'),('し','シェア提案','#9b66de')); for($i=0;$i -lt 3;$i++){ RRect $g 210 $ys[$i] 330 130 60 (Brush '#ffffff') (PenX $left[$i][2] 4); Txt $g ($left[$i][0]+'  '+$left[$i][1]) $Label (Brush $left[$i][2]) 235 ($ys[$i]+24) 280 42; RRect $g 540 ($ys[$i]+86) 330 130 60 (Brush '#fff7fb') (PenX $right[$i][2] 4); Txt $g ($right[$i][0]+'  '+$right[$i][1]) $Label (Brush $right[$i][2]) 565 ($ys[$i]+110) 280 42; RRect $g 345 ($ys[$i]+145) 390 60 30 (Brush '#fff9e8') (PenX '#f3b8c7' 2); Txt $g $qs[$i] $Small $brown 360 ($ys[$i]+150) 360 48 } }
    4 { RRect $g 45 160 990 210 34 (Brush '#fff9ee') (PenX '#ffcf72' 4); for($i=0;$i -lt 8;$i++){ Img $g $Imgs[$i].FullName (60+$i*120) 180 125 155 0 }; $x1=76; $x2=570; $y=430; Choice $g $x1 $y 430 118 'つ' '積み重ね' '毎日の美容ケアで育てたい' '#22a96d' '#f2fff7'; Choice $g $x2 $y 430 118 'わ' '渡韓アップデート' '韓国美容や新しい流行を試したい' '#e95588' '#fff2f7'; Q $g 355 570 370 72 'Q1' '美容の入口は？' '#e95588'; Choice $g $x1 675 430 118 'と' '透明感' '清潔感と抜け感で整える' '#1b9f9f' '#f0fdff'; Choice $g $x2 675 430 118 'ぐ' 'グロウ' 'ツヤと血色感を味方に' '#6c65d8' '#f4f2ff'; Q $g 355 815 370 72 'Q2' 'きれいの届け方は？' '#2e9add'; Choice $g $x1 920 430 118 'じ' '自分軸' '自分の感覚でじっくり選ぶ' '#ff8a25' '#fff6e9'; Choice $g $x2 920 430 118 'し' 'シェア提案' '良かったものを人にも届けたい' '#9b66de' '#fbf2ff'; Q $g 355 1060 370 72 'Q3' '求める気分は？' '#ff8a25' }
    5 { Img $g $Imgs[2].FullName 395 145 300 280 0; for($i=0;$i -lt 10;$i++){ Dot $g (70+$i*95) (430+($i%2)*36) 22 '#ffd1dc' }; RRect $g 80 520 920 720 40 (Brush '#fffefa') (PenX '#f3b8c7' 3); Q $g 410 560 260 80 'Q1' '美容の入口は？' '#e95588'; MiniChoice $g 130 660 350 90 'つ' '積み重ね' '#22a96d' '#eefcf4'; MiniChoice $g 600 660 350 90 'わ' '渡韓アップデート' '#e95588' '#fff0f6'; Q $g 410 795 260 80 'Q2' 'きれいの届け方は？' '#2e9add'; MiniChoice $g 130 895 350 90 'と' '透明感' '#1b9f9f' '#effcff'; MiniChoice $g 600 895 350 90 'ぐ' 'グロウ' '#6c65d8' '#f4f2ff'; Q $g 410 1030 260 80 'Q3' '求める気分は？' '#ff8a25'; MiniChoice $g 130 1130 350 90 'じ' '自分軸' '#ff8a25' '#fff6e9'; MiniChoice $g 600 1130 350 90 'し' 'シェア提案' '#9b66de' '#f9f1ff' }
    default { $idx=$v-6; $pal=@('#ffe6f0','#eaf8ff','#fff2d6','#eefbf0','#f6efff')[$idx]; RRect $g 54 155 972 1060 34 (Brush $pal) (PenX '#ffffff' 8); for($i=0;$i -lt 5;$i++){ Img $g $Imgs[(($i+$v)%8)].FullName (90+$i*180) (170+($i%2)*45) 150 150 (($i-2)*5) }; $base=380; $gap=245; $colors=@('#22a96d','#1b9f9f','#ff8a25'); $pairs=@(@('つ','積み重ね','わ','渡韓アップデート','Q1','美容の入口は？'),@('と','透明感','ぐ','グロウ','Q2','きれいの届け方は？'),@('じ','自分軸','し','シェア提案','Q3','求める気分は？')); for($i=0;$i -lt 3;$i++){ $yy=$base+$i*$gap; if($idx%2 -eq 0){ Q $g 84 $yy 190 88 $pairs[$i][4] $pairs[$i][5] $colors[$i]; MiniChoice $g 310 ($yy-12) 280 92 $pairs[$i][0] $pairs[$i][1] $colors[$i] '#ffffff'; MiniChoice $g 625 ($yy-12) 350 92 $pairs[$i][2] $pairs[$i][3] '#e95588' '#fff7fb' } else { MiniChoice $g 88 ($yy-8) 340 92 $pairs[$i][0] $pairs[$i][1] $colors[$i] '#ffffff'; Q $g 455 ($yy-6) 170 88 $pairs[$i][4] $pairs[$i][5] '#e95588'; MiniChoice $g 652 ($yy-8) 340 92 $pairs[$i][2] $pairs[$i][3] '#9b66de' '#fff7fb' } } }
  }
  Footer $g
  $file = Join-Path $OutDir ('beauty-mood-distinct-{0:D2}-code.png' -f $v)
  $bmp.Save($file,[Drawing.Imaging.ImageFormat]::Png)
  $prompt = "Use case: infographic-diagram. Asset type: TikTok vertical post. Create a completely distinct cute Japanese K-beauty diagnostic design version $v ($($names[$v-1])). Title exactly: ビューティムード診断. Use rounded kawaii Japanese typography and many Mobby Toka style beauty mascot characters. Show only three axes with hiragana choices: つ 積み重ね / わ 渡韓アップデート, と 透明感 / ぐ グロウ, じ 自分軸 / し シェア提案. No bottom 8-type result display, no Roman choice letters, no fourth axis, no watermark. Yellow-cream background."
  Set-Content -LiteralPath (Join-Path $OutDir ('beauty-mood-distinct-{0:D2}-prompt.txt' -f $v)) -Value $prompt -Encoding utf8
  $Manifest += [pscustomobject]@{ index=$v; name=$names[$v-1]; code=(Split-Path $file -Leaf); prompt=('beauty-mood-distinct-{0:D2}-prompt.txt' -f $v) }
  $g.Dispose(); $bmp.Dispose(); $cream.Dispose(); $white.Dispose(); $pink.Dispose(); $mint.Dispose(); $blue.Dispose(); $orange.Dispose(); $purple.Dispose(); $brown.Dispose()
}
$Manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir 'manifest.json') -Encoding utf8
Write-Output $OutDir
