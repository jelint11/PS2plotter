# otestuje zda zadane nazvy jsou soubory nebo URL
# kdyz jsou url stahne do docasneho souboru jejich obsah  

examineData ()
{
  for item in "${DATA[@]}";do
    
    if [ ! -f "$item" ];then
      TEMPFILE=$(mktemp -p "$TMPDIR") || err "Nepodarilo se vytvorit docasny soubor.";
      wget -O "$TEMPFILE" "$item" &>/dev/null ;
      if [ $? -eq 0 ];then 
        tmpArray=("${tmpArray[@]}" "$TEMPFILE");
      else 
        rm "$TEMPFILE";
        err "'$item' neni soubor ani platna URL";
      fi
    else
      testFile "$item";
      tmpArray=("${tmpArray[@]}" "$item");
    fi 

  done
  DATA=("${tmpArray[@]}");
}


# otestuje zda vsechny datove soubory obsahuji validni data
testDataValidity ()
{
  local tmp;
  local numline=0;
  for item in "${DATA[@]}";do
    while read line; do 
        ((numline++))
        tmp=$(echo "$line" | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
        TStampMatch "$tmp" "$TIMEFORMAT"
        [ "$?" -eq 0 ] || err "Cas v souboru "$item" radek $numline neodpovida  timeformatu '$TIMEFORMAT'." 
        tmp=$(echo "$line"| awk '{print $NF}');
        isIntFloat "$tmp"
        [ "$?" -eq 0 ] || err "Hodnota v souboru "$item" radek $numline neni typu int/float."
    done < "$item" 
    numline=0;  
  done
}

sortFiles ()
{
  #setrideni souboru podle casu, pouzit bubblesort nepredpoklada se velky pocet souboru
  

  irange=$((${#DATA[@]} - 1))
  for (( i=0; i<$irange; i++ ));do
    jrange=$((${#DATA[@]} - $i - 1))
    for (( j=0; j<$jrange; j++ ));do
       begin=$(cat "${DATA[$j+1]}" | head -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
       end=$(cat "${DATA[$j]}" | tail -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
       tmp=$(isbiggerDate "$begin" "$end" "$TIMEFORMAT");
       if [ "$tmp" = "True" ];then
         tmp="${DATA[$j]}"; 
         DATA[$j]="${DATA[$j+1]}"; 
         DATA[$j+1]="$tmp" 
       fi
    done
  done
   
  #test jestli se setridene soubory neprekryvaji
  for (( i=0; i<$irange; i++ ));do
     begin=$(cat "${DATA[$i+1]}" | head -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
     end=$(cat "${DATA[$i]}" | tail -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
     tmp=$(isbiggerDate "$begin" "$end" "$TIMEFORMAT");
     if [ "$tmp" = "True" ];then
       err "Data v souborech "\"${DATA[$i]}"\" a "\"${DATA[$i+1]}"\" se prekryvaji." 
     fi
  done


}

#vytvori soubor s daty pro plot (prida sloupec s hodnotou barvy)
prepareData()
{
local lastvalue=0;
local tmp;
local ret;

DATAFILE=$(mktemp -p "$TMPDIR") || err "Nepodarilo se vytvorit docasny soubor."
for item in "${DATA[@]}"; do
  
  while read line; do 
    tmp=$(echo "$line"|awk '{print $NF}');
    if (( $(echo "$tmp $lastvalue" | awk '{print ($1 > $2)}') )); then
      echo "$line"" 1" >> "$DATAFILE";
    else
      echo "$line"" 0" >> "$DATAFILE";
    fi
    lastvalue=$tmp;
  done < "$item"
done

#test jestli neni minimum vetsi nez maximum
if [ "$XMIN" != "auto" -a "$XMIN" != "min" -a "$XMAX" != "auto" -a "$XMAX" != "max" ];then
  tmp=$(isbiggerDate "$XMIN" "$XMAX" "$TIMEFORMAT");
  [ "$tmp" = "True" ] || err "Xmin '$XMIN' je vetsi nez Xmax '$XMAX'";
fi

#vybrani pouze dat ktrera jsou mezi Xmin a Xmax

if [ "$XMIN" != "auto" -a "$XMIN" != "min" ];then
   tmpfile=$(mktemp -p "$TMPDIR") || err "Nepodarilo se vytvorit docasny soubor."
   while read line; do 
      tmp=$(echo "$line" | awk '{$NF="";print}'| awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
      ret=$(isbiggerDate "$XMIN" "$tmp" "$TIMEFORMAT");
      if [ "$ret" = "True" ];then
        if [ "$XMAX" != "auto" -a "$XMAX" != "max" ];then
          ret=$(isbiggerDate "$tmp" "$XMAX" "$TIMEFORMAT");
          [ "$ret" = "True" ] && echo "$line" >> "$tmpfile";
        else echo "$line" >> "$tmpfile";
        fi
      fi
   done < "$DATAFILE"

   rm "$DATAFILE";
   DATAFILE="$tmpfile";

elif [ "$XMAX" != "auto" -a "$XMAX" != "max" ];then
   tmpfile=$(mktemp -p "$TMPDIR") || err "Nepodarilo se vytvorit docasny soubor."
   while read line; do 
      tmp=$(echo "$line" | awk '{$NF="";print}'| awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//');
      ret=$(isbiggerDate "$tmp" "$XMAX" "$TIMEFORMAT");
      [ "$ret" = "True" ] && echo "$line" >> "$tmpfile";
   done < "$DATAFILE"

   rm "$DATAFILE";
   DATAFILE="$tmpfile";
fi


}

#dopocte time,speed,fps pokud je potreba
computeTimeSpeedFps ()
{
 local tmp;    
 
 #vypocet poctu radku s daty
 ROWS=$(wc -l "$DATAFILE" | awk '{print $1}' )
  

if [ "$SPEED" = "" -a "$TIME" = "" -a "$FPS" = "" ]; then
  FPS=25;
  SPEED=1;
  TIME=$(awk "BEGIN {print $ROWS/$SPEED/$FPS; exit}");
elif [ "$SPEED" != "" -a "$TIME" = "" -a "$FPS" = "" ]; then
  FPS=25;
  TIME=$(awk "BEGIN {print $ROWS/$SPEED/$FPS; exit}");
elif [ "$SPEED" = "" -a "$TIME" != "" -a "$FPS" = "" ]; then
  SPEED=1;
  FPS=$(awk "BEGIN {print $ROWS/$TIME/$SPEED; exit}");
elif [ "$SPEED" = "" -a "$TIME" = "" -a "$FPS" != "" ]; then
  SPEED=1;
  TIME=$(awk "BEGIN {print $ROWS/$FPS/$SPEED; exit}");
elif [ "$SPEED" != "" -a "$TIME" != "" -a "$FPS" = "" ]; then
  FPS=$(awk "BEGIN {print $ROWS/$TIME/$SPEED; exit}");
elif [ "$SPEED" != "" -a "$TIME" = "" -a "$FPS" != "" ]; then
  TIME=$(awk "BEGIN {print $ROWS/$FPS/$SPEED; exit}");
elif [ "$SPEED" = "" -a "$TIME" != "" -a "$FPS" != "" ]; then
  SPEED=$(awk "BEGIN {print $ROWS/$FPS/$TIME; exit}");
else
  tmp=$(awk "BEGIN {print $ROWS/$FPS/$SPEED; exit}");
  if [ "$tmp" != "$TIME" ];then
    if [ "$IE" = "false" ]; then
       err "Zadana nesmyslna kombinace TIME,SPEED,FPS."
    else 
       warn "Zadana nesmyslna kombinace Time,Speed,FPS. Hodnota Time bude vypoctena."
       TIME="$tmp";
    fi 
  fi 
fi


}


#dopocte xmax,xmin,ymax,ymin
computeMINMAX()
{
 local tmp;
 local tmp1;
 local ymin;
 local ymax;

 #vypocet YMIN
 if [ "$YMIN" == "min" ]; then
   tmp=$( cat "$DATAFILE" | tail -n 1 | awk '{print $(NF-1)}')
   YMIN=$(awk -v min="$tmp" '{if($(NF-1)<min){min=$(NF-1)}}END{print min}' "$DATAFILE");  
 fi 

 #Pokud je Ymax auto pak Ymin musi byt nizsi nez Ymax z dat
 if [ "$YMIN" != "auto" -a "$YMIN" != "min" -a "$YMAX" == "auto"  ]; then
   tmp=$( cat "$DATAFILE" | tail -n 1 | awk '{print $(NF-1)}')
   ymax=$(awk -v max="$tmp" '{if($(NF-1)>max){max=$(NF-1)}}END{print max}' "$DATAFILE");  #hodnota maxima v souboru
   if (( $(echo "$YMIN > $ymax" |bc -l) )); then 
     err "Pokud je Ymax auto pak Ymin musi byt nizsi nez Ymax z dat.";
   fi
fi 
 

 #vypocet YMAX
 if [ "$YMAX" == "max" ]; then
   tmp=$( cat "$DATAFILE" | tail -n 1 | awk '{print $(NF-1)}')
   YMAX=$(awk -v max="$tmp" '{if($(NF-1)>max){max=$(NF-1)}}END{print max}' "$DATAFILE");  
 fi

 #Pokud je Ymin auto pak Ymax musi byt vyssi nez hodnota prvniho radku
 if [ "$YMAX" != "auto" -a "$YMAX" != "max" -a "$YMIN" == "auto"  ]; then  
   ymin=$( cat "$DATAFILE" | head -n 1 | awk '{print $(NF-1)}') #hodnota prvniho radku v souboru
   if (( $(echo "$ymin > $YMAX" |bc -l) )); then 
      err "Pokud je Ymin je auto pak Ymax musi byt vyssi nez hodnota prvniho radku.";
   fi
 fi 

 #vypocet XMIN
 if [ "$XMIN" == "min" ]; then
   XMIN=$( cat "$DATAFILE" | head -n 1 | awk '{$NF="";print}'| awk '{$NF="";print}' | sed 's/^[ \t]*//;s/[ \t]*$//')  
 fi  
 
 #vypocet XMAX
 if [ "$XMAX" == "max" ]; then
   XMAX=$( cat "$DATAFILE" | tail -n 1 | awk '{$NF="";print}'| awk '{$NF="";print}' | sed 's/^[ \t]*//;s/[ \t]*$//')  
 fi  
}







