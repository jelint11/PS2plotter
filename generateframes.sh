#nastaveni promenych pred samotnym plotem
computePlot()
{
  computeTimeSpeedFps;
  computeMINMAX;
  makeSets;

  COLUMNS=$(cat "$DATAFILE" | head -n 1 | awk '{print NF}');
  #RESIDUE=$(($ROWS%$SPEED));
  FRAMES=$(echo "$ROWS/$SPEED" | bc -l | cut -d "." -f 1 )
#  echo $FRAMES
  #[ "$RESIDUE" -eq 0 ] || ((FRAMES++));
  DIGITS=${#FRAMES} ;
  FRAME=0;
  R=0;



}

#pripraveni promenne pro predani hodnot gnuplotu
makeSets()
{

SETS=""; 

if [ "$XMAX" == "auto" -a "$XMIN" != "auto" ];then
  SETS="$SETS"$'\n'"set xrange [\"$XMIN\":]"
fi
if [ "$XMAX" != "auto" -a "$XMIN" == "auto" ];then
  SETS="$SETS"$'\n'"set xrange [:\"$XMAX\"]"
fi
if [ "$XMAX" != "auto" -a "$XMIN" != "auto" ];then
  SETS="$SETS"$'\n'"set xrange [\"$XMIN\":\"$XMAX\"]"
fi

if [ "$YMAX" == "auto" -a "$YMIN" != "auto" ];then
  SETS="$SETS"$'\n'"set yrange [\"$YMIN\":]"
fi
if [ "$YMAX" != "auto" -a "$YMIN" == "auto" ];then
  SETS="$SETS"$'\n'"set yrange [:\"$YMAX\"]"
fi
if [ "$YMAX" != "auto" -a "$YMIN" != "auto" ];then
  SETS="$SETS"$'\n'"set yrange [\"$YMIN\":\"$YMAX\"]"
fi


if [ "$XMAX" != "auto" -a "$XMIN" != "auto" ];then
  for i in "${CRITICALY[@]}"
  do
    SETS="$SETS"$'\n'"set arrow from \"$XMIN\",$i to \"$XMAX\",$i nohead lt 1 lc rgb \"black\""
  done
fi

if [ "$YMAX" != "auto" -a "$YMIN" != "auto" ];then
  for i in "${CRITICALX[@]}"
  do
    SETS="$SETS"$'\n'"set arrow from \"$i\",$YMIN to \"$i\",$YMAX nohead lt 1 lc rgb \"black\""
  done
fi

for i in "${GNUPLOTPARAMS[@]}"
do
  SETS="$SETS"$'\n'"set $i"
done

}


#vytvoreni sady snimku a animace
generateFrames ()
{

if [ "$XMIN" == "auto" ];then 
  t1=$(sed "1q;d" "$DATAFILE" | awk '{$NF="";print}'| awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
  offset1=$(inSeconds "$t1" "$TIMEFORMAT");
else 
  offset1=$(inSeconds "$XMIN" "$TIMEFORMAT");
fi

tmp=1
#vykresleni obrazku
for (( a=0; a<$FRAMES; a++ ));do
tmp=$(awk "BEGIN {print $tmp+$SPEED; exit}");
R=$(echo $tmp | cut -d "." -f 1)
[ $R -eq 0 ] && R=1
((FRAME++))
[ $FRAME -eq $FRAMES ] && R=$ROWS;

if [ "$XMAX" == "auto" ];then 
  t2=$(sed "${R}q;d" "$DATAFILE" | awk '{$NF="";print}'| awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
  offset2=$(inSeconds "$t2" "$TIMEFORMAT");
else
  offset2=$(inSeconds "$XMAX" "$TIMEFORMAT");
fi

OFFSET=$(($offset2-$offset1));
OFFSET=$(($OFFSET/520*2));

[ "$VERBOSE" == "true" ] && echo -ne "Dokonceno "$FRAME"/"$FRAMES" snimku\r";

gnuplot <<- EOF  2>/dev/null || err "Neplatne GnuplotParams, zkontroluj co jsi do gnuplotu zadal."
reset
unset key
set term pngcairo
set cbrange [0:1]
set palette defined ( 0 "${EFECTPARAMS[2]}", 1 "${EFECTPARAMS[1]}" )
unset colorbox
set xdata time
set xtics rotate
set timefmt "$TIMEFORMAT"
set title "$LEGEND"
set output "$TMPDIR/`printf %0${DIGITS}d $FRAME`.png"

`printf  "%s\n" "$SETS"`; 

plot "<(sed -n 1,${R}p $DATAFILE)" using (timecolumn(1)+$OFFSET):$COLUMNS-1 w l lc rgb "black" lw 7 , \
"<(sed -n 1,${R}p $DATAFILE)" using 1:$COLUMNS-1:$COLUMNS w l lc palette z lw 5 
 
EOF
done

ffmpeg -r "$FPS" -y -i "$TMPDIR"/%0${DIGITS}d.png  "$NAME"/animation.mp4 2>/dev/null || err "Generovani videa selhalo."
#convert -layers Optimize "$NAME"/animation.mp4 "$NAME"/animation.gif



}

