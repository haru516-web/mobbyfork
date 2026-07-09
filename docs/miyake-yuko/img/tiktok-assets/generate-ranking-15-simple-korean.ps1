$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$Root = (Get-Location).Path
$OutDir = Join-Path $Root 'docs/miyake-yuko/img/tiktok-assets/variants-15-simple-korean'
$TokaDir = Join-Path $Root 'docs/miyake-yuko/img/8mobby-toka'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
function B($h){ New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($h)) }
function Pn($h,$w){ $p=New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml($h)), $w; $p.StartCap='Round'; $p.EndCap='Round'; $p }
function F($n,$s,$st='Regular'){ try { New-Object Drawing.Font($n,$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } catch { New-Object Drawing.Font('Yu Gothic UI',$s,[Drawing.FontStyle]::$st,[Drawing.GraphicsUnit]::Pixel) } }
function RR($g,$x,$y,$w,$h,$r,$fill,$stroke=$null){ $path=New-Object Drawing.Drawing2D.GraphicsPath; $d=$r*2; $path.AddArc($x,$y,$d,$d,180,90); $path.AddArc($x+$w-$d,$y,$d,$d,270,90); $path.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $path.AddArc($x,$y+$h-$d,$d,$d,90,90); $path.CloseFigure(); if($fill){$g.FillPath($fill,$path)}; if($stroke){$g.DrawPath($stroke,$path)}; $path.Dispose() }
function T($g,$t,$f,$br,$x,$y,$w,$h,$a='Center'){ $sf=New-Object Drawing.StringFormat; $sf.Alignment=[Drawing.StringAlignment]::$a; $sf.LineAlignment='Center'; $sf.Trimming='EllipsisCharacter'; $g.DrawString($t,$f,$br,(New-Object Drawing.RectangleF $x,$y,$w,$h),$sf); $sf.Dispose() }
function I($g,$path,$x,$y,$w,$h){ $im=[Drawing.Image]::FromFile($path); $sc=[Math]::Min($w/$im.Width,$h/$im.Height); $dw=$im.Width*$sc; $dh=$im.Height*$sc; $g.DrawImage($im,$x+($w-$dw)/2,$y+($h-$dh)/2,$dw,$dh); $im.Dispose() }
function Header($g,$title,$sub,$accent){ T $g $title $Title (B $accent) 46 30 988 76; T $g $sub $Sub (B '#3a2a2a') 96 102 888 34; RR $g 165 1418 750 42 21 (B '#fffdfb') (Pn '#f0a5b9' 2); T $g 'ビューティムード診断' $Foot (B $accent) 180 1421 720 35 }
function Row($g,$rank,$name,$path,$x,$y,$w,$h,$accent,$fill){ RR $g $x $y $w $h 24 (B $fill) (Pn $accent 3); RR $g ($x+14) ($y+18) 62 ($h-36) 20 (B $accent) $null; T $g ([string]$rank) $RankF (B '#ffffff') ($x+14) ($y+18) 62 ($h-36); I $g $path ($x+92) ($y+8) 140 ($h-16); T $g $name $Label (B $accent) ($x+250) ($y+23) ($w-270) 44 'Near'; T $g 'モビー + パートナー' $Small (B '#4a3636') ($x+250) ($y+69) ($w-270) 30 'Near' }
function DrawSimple($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; for($i=0;$i -lt 8;$i++){ Row $g ($i+1) $spec.Order[$i] $map[$spec.Order[$i]] 72 (175+$i*147) 936 124 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' } }
function DrawTop3($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; $tops=@(0,1,2); for($i=0;$i -lt 3;$i++){ $x=72+$i*312; RR $g $x 170 286 310 30 (B '#fffdfb') (Pn $spec.Colors[$i] 4); T $g (($i+1).ToString()+'位') $RankF (B $spec.Colors[$i]) ($x+18) 182 80 45 'Near'; I $g $map[$spec.Order[$i]] ($x+38) 230 210 145; T $g $spec.Order[$i] $Mini (B $spec.Colors[$i]) ($x+18) 382 250 62 }
  for($i=3;$i -lt 8;$i++){ Row $g ($i+1) $spec.Order[$i] $map[$spec.Order[$i]] 90 (510+($i-3)*158) 900 130 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' }
}
function DrawSplit($g,$spec,$map){ Header $g $spec.Title $spec.Sub $spec.Accent; for($i=0;$i -lt 8;$i++){ $col=$i%2; $row=[math]::Floor($i/2); Row $g ($i+1) $spec.Order[$i] $map[$spec.Order[$i]] (58+$col*512) (185+$row*285) 454 238 $spec.Colors[$i%$spec.Colors.Count] '#fffdfb' } }
$Title=F 'HGP創英角ﾎﾟｯﾌﾟ体' 48 'Bold'; $Sub=F 'HG丸ｺﾞｼｯｸM-PRO' 22 'Bold'; $Label=F 'HG丸ｺﾞｼｯｸM-PRO' 25 'Bold'; $Small=F 'HG丸ｺﾞｼｯｸM-PRO' 17 'Bold'; $Mini=F 'HG丸ｺﾞｼｯｸM-PRO' 20 'Bold'; $RankF=F 'Comic Sans MS' 38 'Bold'; $Foot=F 'HG丸ｺﾞｼｯｸM-PRO' 18 'Bold'
$Map=@{}; Get-ChildItem -LiteralPath $TokaDir -Filter '*.png' | ForEach-Object { $Map[$_.BaseName]=$_.FullName }
$C=@('#e94d7a','#ff8a25','#27a879','#219fb0','#6e63d8','#9b66de','#d29a39','#ef6f91')
$Specs=@(
[pscustomobject]@{Title='韓国アイドル風メイクに合うランキング';Sub='華やかさと透明感で選ぶ';Order=@('韓国アイドルモビー','韓国コスメコンシェルジュモビー','透明感モデルモビー','美容インフルエンサーモビー','韓ドラ女優モビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='top3';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='大人になって垢抜けるランキング';Sub='洗練されていく魅力';Order=@('透明感モデルモビー','韓ドラ女優モビー','美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','韓国アイドルモビー','美容インフルエンサーモビー','グルメモビー');Layout='simple';Accent='#d86b8a';Colors=$C},
[pscustomobject]@{Title='韓国でモテるランキング';Sub='清潔感と雰囲気で選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容研究家モビー','美容エディターモビー','グルメモビー');Layout='split';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='写真映えする透明感ランキング';Sub='光を味方につけるムード';Order=@('透明感モデルモビー','韓ドラ女優モビー','韓国アイドルモビー','美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','グルメモビー');Layout='top3';Accent='#74aee8';Colors=$C},
[pscustomobject]@{Title='デート前に真似したいメイクランキング';Sub='好印象も自分らしさも';Order=@('韓ドラ女優モビー','韓国アイドルモビー','透明感モデルモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='simple';Accent='#e78391';Colors=$C},
[pscustomobject]@{Title='美容感度が高そうランキング';Sub='新作も定番も上手に選びそう';Order=@('美容エディターモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','韓国アイドルモビー','透明感モデルモビー','韓ドラ女優モビー','グルメモビー');Layout='split';Accent='#8b6f8f';Colors=$C},
[pscustomobject]@{Title='韓ドラヒロイン感ランキング';Sub='物語が始まりそうな余韻';Order=@('韓ドラ女優モビー','透明感モデルモビー','韓国アイドルモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','美容インフルエンサーモビー','グルメモビー');Layout='top3';Accent='#86a8dd';Colors=$C},
[pscustomobject]@{Title='清楚なのに印象に残るランキング';Sub='控えめでも忘れられない';Order=@('透明感モデルモビー','韓ドラ女優モビー','美容エディターモビー','韓国アイドルモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','グルメモビー');Layout='simple';Accent='#8db69a';Colors=$C},
[pscustomobject]@{Title='韓国旅行で一緒に歩きたいランキング';Sub='旅がもっと楽しくなりそう';Order=@('韓国コスメコンシェルジュモビー','韓ドラ女優モビー','韓国アイドルモビー','透明感モデルモビー','美容インフルエンサーモビー','グルメモビー','美容エディターモビー','美容研究家モビー');Layout='split';Accent='#f07f8f';Colors=$C},
[pscustomobject]@{Title='美容垢でバズりそうランキング';Sub='保存したくなるかわいさ';Order=@('美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','透明感モデルモビー','韓国アイドルモビー','美容研究家モビー','韓ドラ女優モビー','グルメモビー');Layout='top3';Accent='#e94d7a';Colors=$C},
[pscustomobject]@{Title='肌がきれいそうランキング';Sub='近くで見ても透明感';Order=@('透明感モデルモビー','美容研究家モビー','韓国コスメコンシェルジュモビー','韓国アイドルモビー','美容エディターモビー','韓ドラ女優モビー','美容インフルエンサーモビー','グルメモビー');Layout='simple';Accent='#8fc6e8';Colors=$C},
[pscustomobject]@{Title='リップが似合いそうランキング';Sub='唇メイク映えで選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容インフルエンサーモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='split';Accent='#c73c5c';Colors=$C},
[pscustomobject]@{Title='涙袋メイクが映えるランキング';Sub='ぷっくり感と韓国っぽさ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','韓国コスメコンシェルジュモビー','美容研究家モビー','美容エディターモビー','美容インフルエンサーモビー','グルメモビー');Layout='top3';Accent='#f6a8c8';Colors=$C},
[pscustomobject]@{Title='韓国オンニ感ランキング';Sub='上品さとトレンド感で選ぶ';Order=@('韓国アイドルモビー','韓ドラ女優モビー','透明感モデルモビー','美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容エディターモビー','美容研究家モビー','グルメモビー');Layout='simple';Accent='#d88aa0';Colors=$C},
[pscustomobject]@{Title='一緒に美容課金したいランキング';Sub='美意識もテンションも上がる';Order=@('美容インフルエンサーモビー','韓国コスメコンシェルジュモビー','美容研究家モビー','美容エディターモビー','透明感モデルモビー','韓国アイドルモビー','韓ドラ女優モビー','グルメモビー');Layout='split';Accent='#d9a33e';Colors=$C}
)
$Manifest=@()
for($idx=0;$idx -lt $Specs.Count;$idx++){
  $s=$Specs[$idx]
  $bmp=New-Object Drawing.Bitmap 1080,1500
  $g=[Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'
  $g.Clear([Drawing.ColorTranslator]::FromHtml('#fff5e8'))
  switch($s.Layout){ 'top3' { DrawTop3 $g $s $Map } 'split' { DrawSplit $g $s $Map } default { DrawSimple $g $s $Map } }
  $file=Join-Path $OutDir ('simple-korean-ranking-{0:D2}-code.png' -f ($idx+1))
  $bmp.Save($file,[Drawing.Imaging.ImageFormat]::Png)
  $prompt="Create a simple Korean K-beauty TikTok ranking poster. Title exactly: $($s.Title). Subtitle: $($s.Sub). Ranking order: $(($s.Order) -join ' / '). Every entry must show the Mobby mascot and adjacent human partner together as one inseparable pair. Minimal clean cream background, rounded cute Japanese typography, no diagnostic questions, no axes, no watermark."
  Set-Content -LiteralPath (Join-Path $OutDir ('simple-korean-ranking-{0:D2}-prompt.txt' -f ($idx+1))) -Value $prompt -Encoding UTF8
  $Manifest += [pscustomobject]@{index=$idx+1; title=$s.Title; layout=$s.Layout; code=(Split-Path $file -Leaf); prompt=('simple-korean-ranking-{0:D2}-prompt.txt' -f ($idx+1))}
  $g.Dispose(); $bmp.Dispose()
}
$Manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir 'manifest.json') -Encoding UTF8
Write-Output $OutDir
