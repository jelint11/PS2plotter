
#############################
# Do promennych ulozi obsah direktiv z configuracniho souboru
# $1 - jmeno konfiguracniho souboru
parseconfig ()
{
data=$(sed 's/#/\n#/g' "$1" | grep -v '^#' | awk NF) ; #odstraneni komentaru a prazdnych radku
while read i
do
  d=$(echo "$i"| awk '{print tolower($1)}'); #nacteni direktivy (prvni sloupec malymi pismeny) 
  v=$(echo "$i"| awk '{$1 = "";print}'| sed 's/^[ \t]*//;s/[ \t]*$//';); #nacteni hodnoty (odebrani prniho sloupce a osekani bilych znaku) 
  if [ "$v" = "" ] ;then
    err "Pro direktivu "\"$d\"" neni v konfiguracnim souboru nastavena hodnota.";
  fi 
  case "$d" in
    timeformat )
       [ "$c_TIMEFORMAT" != "" ] && warn "Direktivu TimeFormat jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_TIMEFORMAT="$v";;
    xmax )    
       [ "$c_XMAX" != "" ] && warn "Direktivu Xmax jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_XMAX="$v";;
    xmin ) 
       [ "$c_XMIN" != "" ] && warn "Direktivu Xmin jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota."; 
       c_XMIN="$v";;
    ymax ) 
       [ "$c_YMAX" != "" ] && warn "Direktivu Ymax jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_YMAX="$v";;
    ymin )
       [ "$c_YMIN" != "" ] && warn "Direktivu Ymin jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_YMIN="$v";;
    speed )  
       [ "$c_SPEED" != "" ] && warn "Direktivu Speed jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_SPEED="$v";;
    time )
       [ "$c_TIME" != "" ] && warn "Direktivu Time jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_TIME="$v";;
    fps ) 
       [ "$c_FPS" != "" ] && warn "Direktivu FPS jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_FPS="$v";;
    legend ) 
       [ "$c_LEGEND" != "" ] && warn "Direktivu Legend jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_LEGEND="$v";;
    effectparams )  
       [ "${#c_EFECTPARAMS[@]}" -gt 0 ] && warn "Zbytecne pouzivas direktivu EffectParams vicekrat. Pouziji posledni zadanou hodnotu.";
        c_EFECTPARAMS=("$v" "${c_EFECTPARAMS[@]}");;
    name ) 
       [ "$c_NAME" != "" ] && warn "Direktivu Name jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       c_NAME="$v";;
    ignoreerrors )
       [ "$c_IE" != "" ] && warn "Direktivu IgnoreErrors jsi v konfiguracnim souboru nastavil vicekrat. Bude pouzita posledni hodnota.";
       [ "$v" != "true" -a "$v" != "false" ] && err "Neplatna hodnota direktivy IgnoreErrors - "\"$v\"".";
       c_IE="$v";;     
    criticalvalue )
       c_CRITICALVALUE=("$v" "${c_CRITICALVALUE[@]}");;    
    gnuplotparams )
       c_GNUPLOTPARAMS=("$v" "${c_GNUPLOTPARAMS[@]}");;         
    * ) err "Neznama direktiva "\"$d\"", oprav konfiguracni soubor!";;
  esac
done < <(echo "$data")
}



#############################
# Do promenych zpracuje pouzite prepinace z prikazove radky

parseParameters ()
{
local error;

ARGS=$(getopt -q -n "$0" -o "hvt:X:x:Y:y:S:T:F:l:e:f:n:Ec:g:" --long "help,verbose,timeformat:,xmax:,xmin:,ymax:,ymin:,speed:,time:,fps:,legend:,effectparams:,configfile:,name:,ignoreerrors,criticalvalue:gnuplotparams:" -- "$@");
if [ $? != 0 ] ; then
 err "Pouzit neplatny prepinac. Skuste "$0" -h ";
fi
eval set -- "$ARGS";

while true; do
  case "$1" in
    -h | --help )  usage; exit ;;
    -v | --verbose ) 
       [ "$a_VERBOSE" != "" ] && err "Zbytecne pouzivas parametr -v | --verbose vicekrat.";
       a_VERBOSE="true";
       VERBOSE="true"; shift ;;
    -t | --timeformat ) 
       [ "$a_TIMEFORMAT" != "" ] && err "Zbytecne pouzivas parametr -t | --timeformat vicekrat."; 
       a_TIMEFORMAT="$2"; shift 2;;
    -X | --xmax ) 
       [ "$a_XMAX" != "" ] && err "Zbytecne pouzivas parametr -X | --xmax vicekrat.";       
       a_XMAX="$2"; shift 2;;
    -x | --xmin )
       [ "$a_XMIN" != "" ] && err "Zbytecne pouzivas parametr -x | --xmin vicekrat.";     
       a_XMIN="$2"; shift 2;;
    -Y | --ymax )
       [ "$a_YMAX" != "" ] && err "Zbytecne pouzivas parametr -Y | --ymax vicekrat.";
       a_YMAX="$2"; shift 2;;
    -y | --ymin )
       [ "$a_YMIN" != "" ] && err "Zbytecne pouzivas parametr -y | --ymin vicekrat.";
       a_YMIN="$2"; shift 2;;
    -S | --speed )
       [ "$a_SPEED" != "" ] && err "Zbytecne pouzivas parametr -S | --speed vicekrat.";
       a_SPEED="$2"; shift 2;;
    -T | --time )
       [ "$a_TIME" != "" ] && err "Zbytecne pouzivas parametr -T | --time vicekrat.";
       a_TIME="$2"; shift 2;;
    -F | --fps )
       [ "$a_FPS" != "" ] && err "Zbytecne pouzivas parametr -F | --fps vicekrat.";
       a_FPS="$2"; shift 2;;
    -l | --legend ) 
       [ "$a_LEGEND" != "" ] && err "Zbytecne pouzivas parametr -l | --legend vicekrat.";
       a_LEGEND="$2"; shift 2;;
    -e | --effectparams )
       [ "${#a_EFECTPARAMS[@]}" -gt 0 ] && warn "Zbytecne pouzivas parametr -e | --effectparams vicekrat. Pouziji posledni zadanou hodnotu.";
        a_EFECTPARAMS=("$2" "${a_EFECTPARAMS[@]}"); shift 2;;
    -g | --gnuplotparams )
        a_GNUPLOTPARAMS=("$2" "${a_GNUPLOTPARAMS[@]}"); shift 2;;
    -f | --configfile )  
       [ "$CONFIG" != "" ] && err "Opetovne zadani parametru -f | --configfile, je pozadovan maximalne jeden konfiguracni soubor.";
       CONFIG="$2"; shift 2;;
    -n | --name )
       [ "$a_NAME" != "" ] && err "Zbytecne pouzivas parametr -n | --name vicekrat.";
       a_NAME="$2"; shift 2;;
    -E | --ignoreerrors )
       [ "$a_IE" != "" ] && err "Zbytecne pouzivas parametr -E | --ignoreerrors vicekrat.";
       a_IE="true"; shift ;;
    -c | --criticalvalue )
       a_CRITICALVALUE=("$2" "${a_CRITICALVALUE[@]}"); shift 2;;
    -- ) shift; break ;;
    * ) echo "zbylo $1"; break ;;
  esac
done
shift $((OPTIND - 1));
DATA=("${@}");
}

#############################
# Vypise navod na pouziti skriptu
usage ()
{

printf "Usage:\n semestralka.sh [options] <files>\n";
printf "\nOptions:
 -h, --help            Zobrazeni napovedy k uziti skriptu.
 -v, --verbose         Zapne vyrecny rezim.
 -t, --timeformat      Časové značky mohou být ve formátu: [YY]YY[-mm[-dd[(T| )HH:[MM:[SS]]]]]
                       Místo znaků - a : lze použít i jiné znaky.
 -X, --xmax            Maximum na ose x. Povolene hodnoty: ""\"auto"\"",""\"max\""",hodnota
 -x, --xmin            Minimum na ose x. Povolene hodnoty: ""\"auto"\"",""\"min\""",hodnota
 -Y, --ymax            Maximum na ose y. Povolene hodnoty: ""\"auto"\"",""\"max\""",hodnota
 -y, --ymin            Minimum na ose y. Povolene hodnoty: ""\"auto"\"",""\"min\""",hodnota
 -S, --speed           Pocet zaznamu na snimek. Typ hodnoty: int/float
 -T, --time            Delka vysledne animace.Typ hodnoty: int/float
 -F, --fps             Pocet snimku za sekundu.Typ hodnoty: int/float
 -l, --legend          Popisek legendy grafu.
 -e, --effectparams    Nastaveni vzhledu efektu. 
 -f, --configfile      Cesta ke konfiguracnimu souboru.
 -n, --name            Jmeno adresare s vyslednou animaci.
 -c, --criticalvalue   Vyznaceni kritickych hodnot.
 -g, --gnuplotparams   Volitelne parametry Gnuplotu.
 -E, --ignoreerrors    Rezim ignoruje nekriticke chyby. \n";
printf "\nExample:\n semestralka.sh -t %%y/%%m/%%d -X 09/12/30 -x 09/01/01 -Y 1000 -y -1000 -S 5 -F 15 -c x=09/04/01 -c x=09/09/01 -c y=500:y=590:y=600:x=09/07/01 -l ""\"Example animation - Simple effect\""" -g ""\"grid xtics ytics\""" -g ""\"pointsize 10\""" -g ""\"tics textcolor rgbcolor \"blue\"\""" -e grow=green:fall=red -n test_animation -E input_file_1 input_file_2 input_file_3\n"
}

#############################
# Vypise pouzitou konfiguraci programu
printVariables ()
{
 printf  "\n"
 printf  "POUZITA KONFIGURACE SKRIPTU\n"
 printf  "\n"
 printf  "Soubory s daty:......"
 printf '%s;' "${DATA[@]}"; echo
 printf  "Config. soubor:......%s\n" "$CONFIG"
 printf  "TimeFormat:..........%s\n" "$TIMEFORMAT"
 printf  "Xmax:................%s\n" "$XMAX"
 printf  "Xmin:................%s\n" "$XMIN"
 printf  "Ymax:................%s\n" "$YMAX"
 printf  "Ymin:................%s\n" "$YMIN"
 printf  "Speed:...............%s\n" "$SPEED"
 printf  "Time:................%s\n" "$TIME"
 printf  "FPS:.................%s\n" "$FPS"
 printf  "Legend:..............%s\n" "$LEGEND"
 printf  "Name:................%s\n" "$NAME"
 printf  "IgnoreErrors:........%s\n" "$IE"
 printf  "EffectParams:........%s\n" "${EFECTPARAMS[0]}"
 printf  "CriticalValue:......."
 printf '%s:' "${CRITICALVALUE[@]}"; echo
 printf  "GnuplotParams:......."
 printf '%s;' "${GNUPLOTPARAMS[@]}"; echo
 printf  "\n"
 printf  "\n"
}

#############################
# Nastavi promenne na defaultni hodnoty
setVariables ()
{
declare -a DATA;
declare -a EFECTPARAMS;
declare -a a_EFECTPARAMS;
declare -a c_EFECTPARAMS;
declare -a a_CRITICALVALUE;
declare -a c_CRITICALVALUE;
declare -a CRITICALVALUE;
declare -a a_GNUPLOTPARAMS;
declare -a c_GNUPLOTPARAMS;
declare -a GNUPLOTPARAMS;
VERBOSE="false";
a_VERBOSE="";
TIMEFORMAT="";
a_TIMEFORMAT="";
c_TIMEFORMAT="";
XMAX="";
a_XMAX="";
c_XMAX="";
XMIN="";
a_XMIN="";
c_XMIN="";
YMAX="";
a_YMAX="";
c_YMAX="";
YMIN="";
a_YMIN="";
c_YMIN="";
SPEED="";
a_SPEED="";
c_SPEED="";
TIME="";
a_TIME="";
c_TIME="";
FPS="";
a_FPS="";
c_FPS="";
LEGEND="";
a_LEGEND="";
c_LEGEND="";
NAME="$0";
a_NAME="";
c_NAME="";
a_IE="";
c_IE="";
IE="false";
TMPDIR=$(mktemp -d) || err "Nepodarilo se vytvorit docasny adresar";
}

#############################
# Z promennych zadanych parametry nebo konfiguracnim souborem vytvori finalni platnou hodnotu.
mergeVariables ()
{

local tmp;
local left;
local right;

if [ "${#DATA[@]}" -eq 0 ]; then err "Nezadal jsi zadny zdroj dat.";fi
if [ "$a_IE" != "" ] ;then IE="$a_IE";
elif [ "$c_IE" != "" ] ;then IE="$c_IE";
fi


# striktni rezim bez chyb
if [ "$IE" = "false" ]; then

  #nastaveni TIMEFORMAT
  tmp=$(cat "${DATA[0]}" | head -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//'); # cas v souboru na prvnim radku
  if [ "$a_TIMEFORMAT" != "" ] ;then
    TStampMatch "$tmp" "$a_TIMEFORMAT"
    [ "$?" -eq 0 ] || err "Data v souboru '${DATA[0]}' neodpovidaji parametrem zadane timestamp '$a_TIMEFORMAT'" 
    TIMEFORMAT="$a_TIMEFORMAT";
  elif [ "$c_TIMEFORMAT" != "" ] ;then
    TStampMatch "$tmp" "$c_TIMEFORMAT"
    [ "$?" -eq 0 ] || err "Data v souboru '${DATA[0]}' neodpovidaji configuracnim souborem zadane direktive Timeformat '$c_TIMEFORMAT'"
    TIMEFORMAT="$c_TIMEFORMAT";
  else 
    TStampMatch "$tmp" "[%Y-%m-%d %H:%M:%S]"
    [ "$?" -eq 0 ] || err "Data v souboru '${DATA[0]}' neodpovidaji vychozi hodnote timestamp [%Y-%m-%d %H:%M:%S]."
    TIMEFORMAT="[%Y-%m-%d %H:%M:%S]";
  fi



  #nastaveni XMAX  
  if [ "$a_XMAX" != "" ] ;then
    TStampMatch "$a_XMAX" "$TIMEFORMAT"
    [ "$?" -eq 0 -o "$a_XMAX" = "auto" -o "$a_XMAX" = "max" ] || err "Zadana hodnota parametru -X | --xmax '$a_XMAX' neni platna." 
    XMAX="$a_XMAX";
  elif [ "$c_XMAX" != "" ] ;then
    TStampMatch "$c_XMAX" "$TIMEFORMAT"
    [ "$?" -eq 0 -o "$c_XMAX" = "auto" -o "$c_XMAX" = "max" ] || err "Zadana hodnota direktivy Xmax '$c_XMAX' neni platna."
    XMAX="$c_XMAX";
  else XMAX="max"
  fi
 
  #nastaveni XMIN
  if [ "$a_XMIN" != "" ] ;then
    TStampMatch "$a_XMIN" "$TIMEFORMAT"
    [ "$?" -eq 0 -o "$a_XMIN" = "auto" -o "$a_XMIN" = "min" ] || err "Zadana hodnota parametru -x | --xmin '$a_XMIN' neni platna." 
    XMIN="$a_XMIN";
  elif [ "$c_XMIN" != "" ] ;then
    TStampMatch "$c_XMIN" "$TIMEFORMAT"
    [ "$?" -eq 0 -o "$c_XMIN" = "auto" -o "$c_XMIN" = "min" ] || err "Zadana hodnota direktivy Xmin '$c_XMIN' neni platna."
    XMIN="$c_XMIN";
  else XMIN="min"
  fi


  #nastaveni YMAX
  if [ "$a_YMAX" != "" ] ;then
    isIntFloat "$a_YMAX"
    [ "$?" -eq 0 -o "$a_YMAX" = "auto" -o "$a_YMAX" = "max" ] || err "Zadana hodnota parametru -Y | --ymax '$a_YMAX' neni platna." 
    YMAX="$a_YMAX";
  elif [ "$c_YMAX" != "" ] ;then
    isIntFloat "$c_YMAX"
    [ "$?" -eq 0 -o "$c_YMAX" = "auto" -o "$c_YMAX" = "max" ] || err "Zadana hodnota direktivy Ymax '$c_YMAX' neni platna."
    YMAX="$c_YMAX";
  else YMAX="auto"
  fi


  #nastaveni YMIN
  if [ "$a_YMIN" != "" ] ;then
    isIntFloat "$a_YMIN"
    [ "$?" -eq 0 -o "$a_YMIN" = "auto" -o "$a_YMIN" = "min" ] || err "Zadana hodnota parametru -y | --ymin '$a_YMIN' neni platna." 
    YMIN="$a_YMIN";
  elif [ "$c_YMAX" != "" ] ;then
    isIntFloat "$c_YMIN"
    [ "$?" -eq 0 -o "$c_YMIN" = "auto" -o "$c_YMIN" = "min" ] || err "Zadana hodnota direktivy Ymin '$c_YMIN' neni platna."
    YMIN="$c_YMIN";
  else YMIN="auto"
  fi


  #nastaveni SPEED
  if [ "$a_SPEED" != "" ] ;then
    isIntFloat "$a_SPEED"
    [ "$?" -eq 0 ] || err "Zadana hodnota parametru -S | --speed \""$a_SPEED"\" neni platna." 
    [[ "$a_SPEED" =~ ^-[.]* ]] && err "Zadana hodnota parametru -S | --speed \""$a_SPEED"\" nesmi byt zaporne cislo." 
    SPEED="$a_SPEED";
  elif [ "$c_SPEED" != "" ] ;then
    isIntFloat "$c_SPEED"
    [ "$?" -eq 0 ] || err "Zadana hodnota direktivy Speed \""$c_SPEED"\" neni platna."
    [[ "$c_SPEED" =~ ^-[.]* ]] && err "Zadana hodnota direktivy Speed \""$c_SPEED"\" nesmi byt zaporne cislo."
    [ "$a_TIME" != "" -a "$a_FPS" != "" ] || SPEED="$c_SPEED";
  fi


  #nastaveni TIME
  if [ "$a_TIME" != "" ] ;then
    isIntFloat "$a_TIME"
    [ "$?" -eq 0 ] || err "Zadana hodnota parametru -T | --time \""$a_TIME"\" neni platna."
    [[ "$a_TIME" =~ ^-[.]* ]] && err "Zadana hodnota parametru -T | --time \""$a_TIME"\" nesmi byt zaporne cislo."
    TIME="$a_TIME"; 
  elif [ "$c_TIME" != "" ] ;then
    isIntFloat "$c_TIME"
    [ "$?" -eq 0 ] || err "Zadana hodnota direktivy Time \""$c_TIME"\" neni platna."
    [[ "$c_TIME" =~ ^-[.]* ]] && err "Zadana hodnota direktivy Time \""$c_TIME"\" nesmi byt zaporne cislo."
    [ "$a_SPEED" != "" -a "$a_FPS" != "" ] || TIME="$c_TIME"; 
  fi


  #nastaveni FPS
  if [ "$a_FPS" != "" ] ;then
    isIntFloat "$a_FPS"
    [ "$?" -eq 0 ] || err "Zadana hodnota parametru -F | --fps \""$a_FPS"\" neni platna." 
    [[ "$a_FPS" =~ ^-[.]* ]] && err "Zadana hodnota parametru -F | --fps \""$a_FPS"\" nesmi byt zaporne cislo." 
    FPS="$a_FPS"; 
  elif [ "$c_FPS" != "" ] ;then
    isIntFloat "$c_FPS"
    [ "$?" -eq 0 ] || err "Zadana hodnota direktivy FPS \""$c_FPS"\" neni platna."
     [[ "$c_FPS" =~ ^-[.]* ]] && err "Zadana hodnota direktivy FPS \""$c_FPS"\" nesmi byt zaporne cislo."
    [ "$a_SPEED" != "" -a "$a_TIME" != "" ] || FPS="$c_FPS"; 
  fi


else
  ####################################################################################
  #pokud ignorujeme nekriticke chyby##################################################

  #nastaveni TIMEFORMAT
  tmp=$(cat "${DATA[0]}" | head -n 1 | awk '{$NF="";print}'| sed 's/^[ \t]*//;s/[ \t]*$//'); # cas v souboru na prvnim radku
  if [ "$a_TIMEFORMAT" != "" ] ;then
    TStampMatch "$tmp" "$a_TIMEFORMAT"
    if [ "$?" -eq 0 ];then
      TIMEFORMAT="$a_TIMEFORMAT";
    else warn "Data v souboru '${DATA[0]}' neodpovidaji parametrem zadane timestamp '$a_TIMEFORMAT'"
    fi
  fi 
  if [ "$c_TIMEFORMAT" != "" -a "$TIMEFORMAT" == "" ] ;then
    TStampMatch "$tmp" "$c_TIMEFORMAT"
    if [ "$?" -eq 0 ] ;then
      TIMEFORMAT="$c_TIMEFORMAT";
    else warn "Data v souboru '${DATA[0]}' neodpovidaji configuracnim souborem zadane direktive Timeformat '$c_TIMEFORMAT'"   
    fi 
  fi
  if [ "$TIMEFORMAT" == "" ] ;then
    TStampMatch "$tmp" "[%Y-%m-%d %H:%M:%S]"
    [ "$?" -eq 0 ] || err "Data v souboru '${DATA[0]}' neodpovidaji vychozi hodnote timestamp [%Y-%m-%d %H:%M:%S]."
    TIMEFORMAT="[%Y-%m-%d %H:%M:%S]";
  fi

  
  #nastaveni XMAX  
  if [ "$a_XMAX" != "" ] ;then
    TStampMatch "$a_XMAX" "$TIMEFORMAT"
    if [ "$?" -eq 0 -o "$a_XMAX" = "auto" -o "$a_XMAX" = "max" ];then
      XMAX="$a_XMAX";
    else warn "Zadana hodnota parametru -X | --xmax '$a_XMAX' neni platna." 
    fi
  fi
  if [ "$c_XMAX" != "" -a "$XMAX" == "" ] ;then
    TStampMatch "$c_XMAX" "$TIMEFORMAT"
    if [ "$?" -eq 0 -o "$c_XMAX" = "auto" -o "$c_XMAX" = "max" ];then
      XMAX="$c_XMAX";
    else warn "Zadana hodnota direktivy Xmax '$c_XMAX' neni platna."
    fi
  fi
  [ "$XMAX" == "" ] && XMAX="max";

  
  #nastaveni XMIN
  if [ "$a_XMIN" != "" ] ;then
    TStampMatch "$a_XMIN" "$TIMEFORMAT"
    if [ "$?" -eq 0 -o "$a_XMIN" = "auto" -o "$a_XMIN" = "min" ];then
      XMIN="$a_XMIN";
    else warn "Zadana hodnota parametru -x | --xmin '$a_XMIN' neni platna."  
    fi
  fi
  if [ "$c_XMIN" != "" -a "$XMIN" == "" ] ;then
    TStampMatch "$c_XMIN" "$TIMEFORMAT"
    if [ "$?" -eq 0 -o "$c_XMIN" = "auto" -o "$c_XMIN" = "min" ] ;then
      XMIN="$c_XMIN";
    else warn "Zadana hodnota direktivy Xmin '$c_XMIN' neni platna."
    fi
  fi
  [ "$XMIN" == "" ] && XMIN="min";


  #nastaveni YMAX
  if [ "$a_YMAX" != "" ] ;then
    isIntFloat "$a_YMAX"
    if [ "$?" -eq 0 -o "$a_YMAX" = "auto" -o "$a_YMAX" = "max" ] ;then
      YMAX="$a_YMAX";
    else warn "Zadana hodnota parametru -Y | --ymax '$a_YMAX' neni platna." 
    fi
  fi
  if [ "$c_YMAX" != "" -a "$YMAX" == "" ] ;then
    isIntFloat "$c_YMAX"
    if [ "$?" -eq 0 -o "$c_YMAX" = "auto" -o "$c_YMAX" = "max" ];then
      YMAX="$c_YMAX";
    else warn "Zadana hodnota direktivy Ymax '$c_YMAX' neni platna."
    fi 
  fi
  [ "$YMAX" == "" ] && YMAX="auto";
  

  #nastaveni YMIN
  if [ "$a_YMIN" != "" ] ;then
    isIntFloat "$a_YMIN"
    if [ "$?" -eq 0 -o "$a_YMIN" = "auto" -o "$a_YMIN" = "min" ];then
      YMIN="$a_YMIN";
    else warn "Zadana hodnota parametru -y | --ymin '$a_YMIN' neni platna." 
    fi 
  fi
  if [ "$c_YMAX" != "" -a "$YMIN" == "" ] ;then
    isIntFloat "$c_YMIN"
    if [ "$?" -eq 0 -o "$c_YMIN" = "auto" -o "$c_YMIN" = "min" ] ;then
      YMIN="$c_YMIN";
    else warn "Zadana hodnota direktivy Ymin '$c_YMIN' neni platna."
    fi
  fi
  [ "$YMIN" == "" ] && YMIN="auto";
  

  #nastaveni SPEED
  if [ "$a_SPEED" != "" ] ;then
    isIntFloat "$a_SPEED"
    if [ "$?" -eq 0 ];then
     [[ "$a_SPEED" =~ ^-[.]* ]] && warn "Zadana hodnota parametru -S | --speed \""$a_SPEED"\" nesmi byt zaporne cislo." || SPEED="$a_SPEED";
    else warn "Zadana hodnota parametru -S | --speed \""$a_SPEED"\" neni platna." 
    fi
  fi    
  if [ "$c_SPEED" != "" -a "$SPEED" == "" ] ;then
    isIntFloat "$c_SPEED"
    if [ "$?" -eq 0 ] ;then 
      if [[ "$c_SPEED" =~ ^-[.]* ]];then
         warn "Zadana hodnota direktivy Speed \""$c_SPEED"\" nesmi byt zaporne cislo."
      else
        [ "$a_TIME" != "" -a "$a_FPS" != "" ] || SPEED="$c_SPEED";
      fi
    else warn "Zadana hodnota direktivy Speed \""$c_SPEED"\" neni platna."
    fi
  fi

  #nastaveni TIME
  if [ "$a_TIME" != "" ] ;then
    isIntFloat "$a_TIME"
    if [ "$?" -eq 0 ] ;then 
      [[ "$a_TIME" =~ ^-[.]* ]] && warn "Zadana hodnota parametru -T | --time \""$a_TIME"\" nesmi byt zaporne cislo." || TIME="$a_TIME"; 
    else warn "Zadana hodnota parametru -T | --time \""$a_TIME"\" neni platna."
    fi  
  fi
  if [ "$c_TIME" != "" -a "$TIME" == "" ] ;then
    isIntFloat "$c_TIME"
    if [ "$?" -eq 0 ] ;then 
      if [[ "$c_TIME" =~ ^-[.]* ]];then
         warn "Zadana hodnota direktivy Time \""$c_TIME"\" nesmi byt zaporne cislo." 
      else
        [ "$a_SPEED" != "" -a "$a_FPS" != "" ] || TIME="$c_TIME"; 
      fi
    else warn "Zadana hodnota direktivy Time \""$c_TIME"\" neni platna."
    fi
  fi


  #nastaveni FPS
  if [ "$a_FPS" != "" ] ;then
    isIntFloat "$a_FPS"
    if [ "$?" -eq 0 ] ;then
      [[ "$a_FPS" =~ ^-[.]* ]] && warn "Zadana hodnota parametru -F | --fps \""$a_FPS"\" nesmi byt zaporne cislo." || FPS="$a_FPS"; 
    else warn "Zadana hodnota parametru -F | --fps \""$a_FPS"\" neni platna." 
    fi 
  fi
  if [ "$c_FPS" != ""  -a "$FPS" == "" ] ;then
    isIntFloat "$c_FPS"
    if [ "$?" -eq 0 ] ;then
       if [[ "$c_FPS" =~ ^-[.]* ]];then
          warn "Zadana hodnota direktivy FPS \""$c_FPS"\" nesmi byt zaporne cislo."
       else
         [ "$a_SPEED" != "" -a "$a_TIME" != "" ] || FPS="$c_FPS";
       fi  
    else warn "Zadana hodnota direktivy FPS \""$c_FPS"\" neni platna."
    fi
  fi


fi

  #nastaveni NAME
  if [ "$a_NAME" != "" ] ;then NAME="$a_NAME"; 
  elif [ "$c_NAME" != "" ] ;then NAME="$c_NAME"; 
  fi
   
  left=$(echo "$NAME" | awk -F  "/" 'BEGIN { OFS = FS }{$NF="";print}')
  right="$(basename "$NAME")";
  tmp=$(max_dir "$left" "$right");
  if [ "$tmp" != "1" ];then
    NAME="$NAME""_""$tmp";  
  elif [ -e "$NAME" ];then
    NAME="$NAME""_1"
  fi
  mkdir -p "$NAME" 2>/dev/null || err "Nemuzu vytvorit adresar '$NAME'."
  CREATED="true";

  #nastaveni LEGEND
  if [ "$a_LEGEND" != "" ] ;then
    LEGEND="$a_LEGEND";
  elif [ "$c_LEGEND" != "" ] ;then
    LEGEND="$c_LEGEND";
  fi
  
  #nastaveni GNUPLOTPARAMS
  if [ "${#a_GNUPLOTPARAMS[@]}" -gt 0 ];then
    GNUPLOTPARAMS=("${a_GNUPLOTPARAMS[@]}");
  elif [ "${#c_GNUPLOTPARAMS[@]}" -gt 0 ];then
    GNUPLOTPARAMS=("${c_GNUPLOTPARAMS[@]}");
  fi

 #nastaveni EFECTPARAMS
  if [ "${#a_EFECTPARAMS[@]}" -gt 0 ];then
    [[ "${a_EFECTPARAMS[0]}" =~ ^grow=.*\:fall=.*$ ]] || err "Zadana hodnota parametru -e | --effectparrams \""${a_EFECTPARAMS[0]}"\" neni platna."
    EFECTPARAMS[0]=${a_EFECTPARAMS[0]};
  elif [ "${#c_EFECTPARAMS[@]}" -gt 0 ];then
     [[ "${c_EFECTPARAMS[0]}" =~ ^grow=.*\:fall=.*$ ]] || err "Zadana hodnota direktivy EffectParams \""${c_EFECTPARAMS[0]}"\" neni platna."
    EFECTPARAMS[0]=${c_EFECTPARAMS[0]};
  else 
    EFECTPARAMS[0]="grow=green:fall=red";
  fi   
  EFECTPARAMS[1]=$(echo "${EFECTPARAMS[0]}" | cut -d ":" -f 1 | cut -d "=" -f 2 ) 
  EFECTPARAMS[2]=$(echo "${EFECTPARAMS[0]}" | cut -d ":" -f 2 | cut -d "=" -f 2 )  

  #nastaveni CRITICALVALUE
  if [ "${#a_CRITICALVALUE[@]}" -gt 0 ];then
    CRITICALVALUE=("${a_CRITICALVALUE[@]}");
  elif [ "${#c_CRITICALVALUE[@]}" -gt 0 ];then
    CRITICALVALUE=("${c_CRITICALVALUE[@]}");
  fi

  #odeberu posledni : a nahradim :[xy] za :\n[xy] 
  if [ "${#CRITICALVALUE[@]}" -gt 0 ];then
    tmp=$(printf '%s:' "${CRITICALVALUE[@]}" | sed 's/\:$//'| sed ';s/\:x/'\\\n'x/g' | sed ';s/\:y/'\\\n'y/g' ); 
    while read -r line; do
      left=$(echo "$line" | cut -d "=" -f 1);
      right=$(echo "$line" | cut -d "=" -f 2);
      if [ "$left" == "x" ];then
        TStampMatch "$right" "$TIMEFORMAT"
        [ "$?" -eq 0 ] || err "Zadana hodnota CriticalValue \""${left}"="${right}"\" neni platna."
        CRITICALX[${#CRITICALX[@]}]="$right";  #promena obsahuje hodnoty critical x
      elif [ "$left" == "y" ];then
        isIntFloat "$right"
        [ "$?" -eq 0 ] || err "Zadana hodnota CriticalValue \""${left}"="${right}"\" neni platna."
        CRITICALY[${#CRITICALY[@]}]="$right";   #promena obsahuje hodnoty critical y
      else err "Zadana hodnota CriticalValue \""${left}"="${right}"\" neni platna."
      fi
    done <<< "$tmp"
  fi




}



