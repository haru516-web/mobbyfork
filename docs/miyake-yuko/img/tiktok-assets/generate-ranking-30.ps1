$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/variants-30-rankings'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
function B($h){ New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($h)) }
function PX($h,$w){ $p=New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($h)), $w; $p.StartCap='Round'; $p.EndCap='Round'; $p }
function FX($n,$s,$st='Regular'){ try { New-Object Drawing.Font($n,$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } catch { New-Object Drawing.Font('Yu Gothic UI',$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } }
function RR($g,$x,$y,$w,$h,$r,$fill,$stroke=$null){ $path=New-Object Drawing.Drawing2D.GraphicsPath; $d=$r*2; $path.AddArc($x,$y,$d,$d,180,90); $path.AddArc($x+$w-$d,$y,$d,$d,270,90); $path.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $path.AddArc($x,$y+$h-$d,$d,$d,90,90); $path.CloseFigure(); if($fill){$g.FillPath($fill,$path)}; if($stroke){$g.DrawPath($stroke,$path)}; $path.Dispose() }
function TXT($g,$t,$f,$br,$x,$y,$w,$h,$a='Center'){ $sf=New-Object Drawing.StringFormat; $sf.Alignment=[Drawing.StringAlignment]::$a; $sf.LineAlignment='Center'; $sf.Trimming='EllipsisCharacter'; $g.DrawString($t,$f,$br,(New-Object Drawing.RectangleF $x,$y,$w,$h),$sf); $sf.Dispose() }
function IMG($g,$path,$x,$y,$w,$h,$rot=0){ $im=[Drawing.Image]::FromFile($path); $sc=[Math]::Min($w/$im.Width,$h/$im.Height); $dw=$im.Width*$sc; $dh=$im.Height*$sc; $s=$g.Save(); $g.TranslateTransform($x+$w/2,$y+$h/2); if($rot -ne 0){$g.RotateTransform($rot)}; $g.DrawImage($im,-$dw/2,-$dh/2,$dw,$dh); $g.Restore($s); $im.Dispose() }
function Header($g,$title,$sub,$accent){ TXT $g $title $Title (B $accent) 46 28 988 86; TXT $g $sub $Sub (B '#352525') 80 112 920 34 }
function PairRow($g,$rank,$name,$path,$x,$y,$w,$h,$accent,$fill,$big=$false){ RR $g $x $y $w $h 28 (B $fill) (PX $accent 4); $rankW=72; RR $g ($x+14) ($y+18) $rankW ($h-36) 22 (B $accent) $null; TXT $g ([string]$rank) $RankF (B '#ffffff') ($x+14) ($y+18) $rankW ($h-36); $iw= if($big){160}else{126}; IMG $g $path ($x+100) ($y+8) $iw ($h-16); TXT $g $name $Label (B $accent) ($x+100+$iw+12) ($y+18) ($w-$iw-132) 42 'Near'; TXT $g 'モビー + パートナー' $Small (B '#4b3636') ($x+100+$iw+12) ($y+64) ($w-$iw-132) 34 'Near' }
function DrawStandard($g,$spec,$map,$idx){ Header $g $spec.Title $spec.Sub $spec.Accent; $y=172; for($i=0;$i -lt 8;$i++){ $name=$spec.Order[$i]; $h= if($i -lt 3){134}else{112}; PairRow $g ($i+1) $name $map[$name] 64 $y 952 $h $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' ($i -lt 3); $y += $h + 14 } }
function DrawPyramid($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; $rows=@(@(0),@(1,2),@(3,4,5),@(6,7)); $ys=@(190,435,690,965); for($r=0;$r -lt $rows.Count;$r++){ $count=$rows[$r].Count; $cardW=[int]((920-($count-1)*22)/$count); $start=80; for($j=0;$j -lt $count;$j++){ $i=$rows[$r][$j]; $name=$spec.Order[$i]; PairRow $g ($i+1) $name $map[$name] ($start+$j*($cardW+22)) $ys[$r] $cardW 210 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' $true } } }
function DrawZigzag($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; for($i=0;$i -lt 8;$i++){ $x= if($i%2 -eq 0){70}else{180}; $w=830; $y=170+$i*145; PairRow $g ($i+1) $spec.Order[$i] $map[$spec.Order[$i]] $x $y $w 126 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' ($i -lt 2) } }
function DrawShelf($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; for($r=0;$r -lt 4;$r++){ RR $g 56 (205+$r*280) 968 190 28 (B '#fffdfb') (PX '#d6b77b' 4) }; for($i=0;$i -lt 8;$i++){ $x=80+($i%4)*235; $y=180+[math]::Floor($i/4)*560; $name=$spec.Order[$i]; IMG $g $map[$name] $x $y 190 170 0; RR $g ($x-2) ($y+174) 205 70 20 (B '#ffffff') (PX $spec.Colors[$i%$spec.Colors.Count] 3); TXT $g (($i+1).ToString()+'位 '+$name) $Mini (B $spec.Colors[$i%$spec.Colors.Count]) ($x+5) ($y+180) 190 58 } }
function DrawPhone($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; RR $g 166 168 748 1120 48 (B '#ffffff') (PX '#f5a9bf' 5); RR $g 216 208 648 78 39 (B '#ffe8f0') $null; TXT $g 'Beauty Mood Ranking' $Comic (B $spec.Accent) 235 218 610 58; for($i=0;$i -lt 8;$i++){ PairRow $g ($i+1) $spec.Order[$i] $map[$spec.Order[$i]] 215 (320+$i*112) 650 94 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' $false } }
function DrawMap($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; RR $g 150 265 780 780 390 (B '#fffdfb') (PX '#f3adc1' 5); TXT $g 'RANKING MAP' $Comic (B $spec.Accent) 365 605 350 58; for($i=0;$i -lt 8;$i++){ $a=(-90+$i*45)*[Math]::PI/180; $cx=540+[Math]::Cos($a)*350; $cy=650+[Math]::Sin($a)*350; RR $g ($cx-124) ($cy-76) 248 152 35 (B '#ffffff') (PX $spec.Colors[$i%$spec.Colors.Count] 3); IMG $g $map[$spec.Order[$i]] ($cx-113) ($cy-60) 105 88 0; TXT $g (($i+1).ToString()+'位') $Small (B $spec.Colors[$i%$spec.Colors.Count]) ($cx-5) ($cy-58) 110 24 'Near'; TXT $g $spec.Order[$i] $Tiny (B $spec.Colors[$i%$spec.Colors.Count]) ($cx-5) ($cy-30) 110 78 'Near' } }
function Footer($g){ RR $g 145 1422 790 40 20 (B '#fffdfb') (PX '#f39bb5' 2); TXT $g 'ビューティムード診断 ランキング' $Foot (B '#e94d7a') 158 1423 764 36 }
$Title=FX 'HGP創英角ﾎﾟｯﾌﾟ体' 48 'Bold'; $Sub=FX 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'; $Label=FX 'HG丸ｺﾞｼｯｸM-PRO' 23 'Bold'; $Small=FX 'HG丸ｺﾞｼｯｸM-PRO' 17 'Bold'; $Tiny=FX 'HG丸ｺﾞｼｯｸM-PRO' 15 'Bold'; $RankF=FX 'Comic Sans MS' 40 'Bold'; $Mini=FX 'HG丸ｺﾞｼｯｸM-PRO' 17 'Bold'; $Comic=FX 'Comic Sans MS' 28 'Bold'; $Foot=FX 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'
$Files=Get-ChildItem -LiteralPath $TokaDir -Filter '*.png'
$Map=@{}; foreach($f in $Files){ $Map[$f.BaseName]=$f.FullName }
$C=@('#e94d7a','#ff8a25','#27a879','#219fb0','#6e63d8','#9b66de','#d29a39','#ef6f91')
$D=@('韓国アイドルモビー','韓国コスメコンシェルジュモビー','透明感モデルモビー','美容インフルエンサーモビー','韓ドラ女優モビー','美容エディターモビー','美容研究家モビー','グルメモビー')
$Specs=@(
[pscustomobject]@{Title='韓国アイドル風メイクに合うランキング';Sub='華やかさ・透明感・トレンド感で選ぶ';Order=@('韓国アイドルモビー','韓国コスメコンシェルジュモビー','透明感モデルモビー','美容インフルエンサーモビー','韓ドラ女優モビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='pyramid';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='大人になって垢抜けるランキング';Sub='年齢を重ねるほど魅力が増す洗練ムード';Order=@('透明感モデルモビー','韓ドラ女優モビー','美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','韓国アイドルモビー','美容インフルエンサーモビー','グルメモビー');Layout='zigzag';Accent='#d86b8a';Colors=$C},
[pscustomobject]@{Title='韓国でモテるランキング';Sub='雰囲気・清潔感・一緒にいる楽しさで選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容研究家モビー','美容エディターモビー','グルメモビー');Layout='phone';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='すっぴん風でも盛れるランキング';Sub='ナチュラルなのに目を引く抜け感';Order=@('透明感モデルモビー','韓国アイドルモビー','美容研究家モビー','韓ドラ女優モビー','美容エディターモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','グルメモビー');Layout='standard';Accent='#f0a0b7';Colors=$C},
[pscustomobject]@{Title='韓国カフェで声をかけられそうランキング';Sub='おしゃれ空間で視線を集めるカフェ映え';Order=@('韓国アイドルモビー','透明感モデルモビー','韓ドラ女優モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='shelf';Accent='#c58a52';Colors=$C},
[pscustomobject]@{Title='写真映えする透明感ランキング';Sub='光を味方につけるフォトジェニック';Order=@('透明感モデルモビー','韓ドラ女優モビー','韓国アイドルモビー','美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','グルメモビー');Layout='map';Accent='#74aee8';Colors=$C},
[pscustomobject]@{Title='デート前に真似したいメイクランキング';Sub='好印象も自分らしさも叶える';Order=@('韓ドラ女優モビー','韓国アイドルモビー','透明感モデルモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='standard';Accent='#e78391';Colors=$C},
[pscustomobject]@{Title='美容感度が高そうランキング';Sub='新作も定番も上手に選びそう';Order=@('美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','韓国アイドルモビー','透明感モデルモビー','韓ドラ女優モビー','グルメモビー');Layout='phone';Accent='#8b6f8f';Colors=$C},
[pscustomobject]@{Title='第一印象で憧れられるランキング';Sub='会った瞬間に素敵と思われる憧れムード';Order=@('韓ドラ女優モビー','透明感モデルモビー','韓国アイドルモビー','美容エディターモビー','美容研究家モビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','グルメモビー');Layout='pyramid';Accent='#d6a04f';Colors=$C},
[pscustomobject]@{Title='韓ドラヒロイン感ランキング';Sub='物語が始まりそうな透明感と余韻';Order=@('韓ドラ女優モビー','透明感モデルモビー','韓国アイドルモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','美容インフルエンサーモビー','グルメモビー');Layout='zigzag';Accent='#86a8dd';Colors=$C},
[pscustomobject]@{Title='垢抜け前後で化けるランキング';Sub='磨くほど魅力が開くポテンシャル';Order=@('美容研究家モビー','グルメモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','透明感モデルモビー','韓ドラ女優モビー','韓国アイドルモビー');Layout='standard';Accent='#f39d61';Colors=$C},
[pscustomobject]@{Title='清楚なのに印象に残るランキング';Sub='控えめでも忘れられない上品な存在感';Order=@('透明感モデルモビー','韓ドラ女優モビー','美容エディターモビー','韓国アイドルモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','グルメモビー');Layout='map';Accent='#8db69a';Colors=$C},
[pscustomobject]@{Title='友達におすすめしたくなるランキング';Sub='一緒に試したくなる信頼感と親しみ';Order=@('韓国コスメコンシェルジュモビー','美容研究家モビー','美容インフルエンサーモビー','美容エディターモビー','グルメモビー','韓国アイドルモビー','透明感モデルモビー','韓ドラ女優モビー');Layout='phone';Accent='#ef7f73';Colors=$C},
[pscustomobject]@{Title='韓国旅行で一緒に歩きたいランキング';Sub='一緒にいるだけで旅がもっと楽しくなりそう';Order=@('韓国コスメコンシェルジュモビー','韓ドラ女優モビー','韓国アイドルモビー','透明感モデルモビー','美容インフルエンサーモビー','グルメモビー','美容エディターモビー','美容研究家モビー');Layout='zigzag';Accent='#f07f8f';Colors=$C},
[pscustomobject]@{Title='美容垢でバズりそうランキング';Sub='投稿した瞬間に保存されそうなかわいさ';Order=@('美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','透明感モデルモビー','韓国アイドルモビー','美容研究家モビー','韓ドラ女優モビー','グルメモビー');Layout='phone';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='肌がきれいそうランキング';Sub='近くで見ても透明感がありそう';Order=@('透明感モデルモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','韓国アイドルモビー','美容エディターモビー','韓ドラ女優モビー','美容インフルエンサーモビー','グルメモビー');Layout='standard';Accent='#8fc6e8';Colors=$C},
[pscustomobject]@{Title='香水が似合いそうランキング';Sub='すれ違ったあとに印象が残りそう';Order=@('韓ドラ女優モビー','透明感モデルモビー','美容エディターモビー','韓国アイドルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容研究家モビー','グルメモビー');Layout='pyramid';Accent='#9d708f';Colors=$C},
[pscustomobject]@{Title='先輩女子に憧れられそうランキング';Sub='かわいいだけじゃなくちゃんと素敵';Order=@('美容エディターモビー','美容研究家モビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','韓国アイドルモビー','グルメモビー');Layout='standard';Accent='#8b5f78';Colors=$C},
[pscustomobject]@{Title='彼女感が強いランキング';Sub='隣にいたら毎日がやさしくなりそう';Order=@('グルメモビー','韓ドラ女優モビー','透明感モデルモビー','韓国アイドルモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー');Layout='shelf';Accent='#e89173';Colors=$C},
[pscustomobject]@{Title='韓国制服アレンジが似合うランキング';Sub='制服コーデまで自分らしく着こなしそう';Order=@('韓国アイドルモビー','透明感モデルモビー','韓ドラ女優モビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','グルメモビー','美容研究家モビー');Layout='zigzag';Accent='#638bd0';Colors=$C},
[pscustomobject]@{Title='ナチュラルメイクで勝てるランキング';Sub='盛らなくても魅力がちゃんと伝わりそう';Order=@('透明感モデルモビー','韓ドラ女優モビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容エディターモビー','韓国アイドルモビー','美容インフルエンサーモビー','グルメモビー');Layout='standard';Accent='#b9987c';Colors=$C},
[pscustomobject]@{Title='美容室でオーダーされそうランキング';Sub='この雰囲気にしてくださいって言われそう';Order=@('透明感モデルモビー','韓国アイドルモビー','韓ドラ女優モビー','美容インフルエンサーモビー','美容エディターモビー','韓国コスメコンシェルジュモビー','美容研究家モビー','グルメモビー');Layout='phone';Accent='#b48a7f';Colors=$C},
[pscustomobject]@{Title='休日のソウル散歩が似合うランキング';Sub='カフェ帰りの横顔まで絵になりそう';Order=@('グルメモビー','韓国コスメコンシェルジュモビー','透明感モデルモビー','韓ドラ女優モビー','美容インフルエンサーモビー','韓国アイドルモビー','美容エディターモビー','美容研究家モビー');Layout='map';Accent='#7cae87';Colors=$C},
[pscustomobject]@{Title='韓国メイク初心者が真似しやすいランキング';Sub='まずはここから 失敗しにくい韓国メイク';Order=@('透明感モデルモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','美容インフルエンサーモビー','韓ドラ女優モビー','グルメモビー','韓国アイドルモビー');Layout='standard';Accent='#f6a7b8';Colors=$C},
[pscustomobject]@{Title='韓国コスメ売り場で目を引くランキング';Sub='店頭映え重視のビューティムード';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='shelf';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='リップが似合いそうランキング';Sub='唇メイク映えNo.1決定戦';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='standard';Accent='#c73c5c';Colors=$C},
[pscustomobject]@{Title='涙袋メイクが映えるランキング';Sub='ぷっくり感・透明感・韓国っぽさで選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容研究家モビー','美容エディターモビー','美容インフルエンサーモビー','グルメモビー');Layout='phone';Accent='#f6a8c8';Colors=$C},
[pscustomobject]@{Title='韓国オンニ感ランキング';Sub='透明感・上品さ・トレンド感で選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='pyramid';Accent='#d88aa0';Colors=$C},
[pscustomobject]@{Title='韓国前髪アレンジが似合うランキング';Sub='シースルーバングも顔まわりも映える';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='zigzag';Accent='#f6a8c9';Colors=$C},
[pscustomobject]@{Title='一緒に美容課金したいランキング';Sub='一緒に投資したらもっと楽しくなりそう';Order=@('美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容研究家モビー','美容エディターモビー','透明感モデルモビー','韓国アイドルモビー','韓ドラ女優モビー','グルメモビー');Layout='shelf';Accent='#d9a33e';Colors=$C}
)
$Manifest=@()
for($i=0;$i -lt $Specs.Count;$i++){
  $spec=$Specs[$i]
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $bg= if($spec.Layout -eq 'phone'){'#fff1f6'} elseif($spec.Layout -eq 'map'){'#f7fbff'} elseif($spec.Layout -eq 'shelf'){'#fff5df'} else {'#fff4df'}
  $g.Clear([Drawing.ColorTranslator]::FromHtml($bg))
  switch($spec.Layout){ 'pyramid' { DrawPyramid $g $spec $Map } 'zigzag' { DrawZigzag $g $spec $Map } 'shelf' { DrawShelf $g $spec $Map } 'phone' { DrawPhone $g $spec $Map } 'map' { DrawMap $g $spec $Map } default { DrawStandard $g $spec $Map $i } }
  Footer $g
  $file=Join-Path $OutDir ('beauty-ranking-{0:D2}-code.png' -f ($i+1))
  $bmp.Save($file,[Drawing.Imaging.ImageFormat]::Png)
  $prompt="Use case: infographic-diagram. Asset type: TikTok vertical post. Create a Miyake Yuko Beauty Mood ranking image. Title exactly: $($spec.Title). Subtitle: $($spec.Sub). Korean cute K-beauty ranking style. Use all eight pair images; every entry must show Mobby and the adjacent human partner together as one inseparable pair. Ranking order: $(($spec.Order | ForEach-Object { $_ }) -join ' / '). No diagnostic questions, no axes, no watermark. Use rounded cute Japanese typography."
  Set-Content -LiteralPath (Join-Path $OutDir ('beauty-ranking-{0:D2}-prompt.txt' -f ($i+1))) -Value $prompt -Encoding UTF8
  $Manifest += [pscustomobject]@{index=$i+1; title=$spec.Title; layout=$spec.Layout; code=(Split-Path $file -Leaf); prompt=('beauty-ranking-{0:D2}-prompt.txt' -f ($i+1))}
  $g.Dispose(); $bmp.Dispose()
}
$Manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir 'manifest.json') -Encoding UTF8
Write-Output $OutDir

