
#############################
# Vraci cislo+1 posledniho adresare v danem adresari, oddelovacem je _
# $1 - prohledavany adresar
# $2 - jmeno adresare
max_dir () 
{  
  local max=0;
  directory=("$1"*)
  local tmp;
  local ecaped;

  for f in "${directory[@]}";
  do 
      escaped=$(printf "%q" "$2"); #znaky [*] a pod je treba escapovat nebot v regexu maji svuj vyznam
      tmp=$(printf "%s\n" "${f}" | awk -F "/" '{print $NF}'| grep "^${escaped}_[0-9]\{1,\}$"| awk -F "_" '{print $NF}');
      if [ -n "$tmp" ];then #promena neni prazdna
        [ $max -lt $tmp ] && max=$tmp;
      fi 
  done
  max=$(( $max+1 ));
  printf "%s" "$max";
}


#############################
# Odstrani z pole prazdne retezce (beta verze)
# $1 jmeno pole
eraseblankArray ()
{
 local x=$(eval "echo \${#$1[@]}"); #pocet prvku pole
 local tmp;
 local -a arr;
 for ((i=0; i<$x; i++));
 do
   tmp=$(eval "echo \${$1[$i]}");
   if [ "$tmp"  != "" ];then
     arr=("${arr[@]}" "$tmp");
   fi
 done
 eval "$1=("${arr[@]}")" 2>/dev/null # "[%Y/%m/%d %H:%M:%S" vadi ta [ 
}

#reakce na SIGINT a SIGTERM
control_c () 
{
    printf  "SIGINT. Uklizim a koncim.\n";
    cleanAll;
    [ "$CREATED" == "true" ] && rm -rf "$NAME";
    exit 1
}

#smaze docasne soubory
cleanAll ()
{
 [ -d "$TMPDIR" ] && rm -rf "$TMPDIR";
 return $?
}

#############################
# Vypis erroru a ukonceni skriptu
# $@ - chybova hlaska
err ()
{
 printf  "[Error]: %s\n" "$@" >&2;
 cleanAll;
 [ "$CREATED" == "true" ] && rm -rf "$NAME";
 exit 1;
}

#############################
# Vypis warningu
# $@ - chybova hlaska
warn ()
{ 
 [ "$VERBOSE" == "true" ] && printf  "[Warning]: %s\n" "$@" >&2;
}

#############################
# Otestuje zda je vyraz int nebo float
# $1 - vyraz
# vraci 0 jestlize neni int/float jinak 1
isIntFloat ()
 {
    if [[ "$1" =~ ^[-]?([0-9]+|[0-9]+\.[0-9]+)$ ]]
    then
        return 0;
    else
        return 1;
    fi
}

#############################
# Otestuje zda soubor existuje, lze jej cist a neni prazdny
# $1 - cesta k souboru
# vraci 0 jestlize je vse v poradku jinak 1
testFile () {

if [ ! -f "$1" ];then
  err "Zadany soubor '$1' neexistuje.";
  return 1;
fi 
if [ ! -r "$1" ]; then
  err "Ze souboru '$1' neni mozne cist.";
  return 1;
fi
if [ ! -s "$1" ]; then 
  err "Soubor '$1' je prazdny.";
  return 1;
fi
return 0;
}

#############################
# Otestuje zda casovy retezec odpovida TimeStamp
# $1 - casovy retezec
# $2 - Timestamp
# vraci 0 jestlize odpovida jinak 1
TStampMatch ()
{
  local tmp=$(Strptime "$1" "$2");
  #echo "$1 $2"
  if [[ "$tmp" = "" ]];then
   return 1;
  fi
  return 0;      
}


#############################
# Otestuje zda casovy retezec odpovida TimeStamp
# $1 - casovy retezec
# $2 - Timestamp
# vraci casovy retezec jestlize odpovida jinak prazdny retezec
Strptime ()
{
python 2> /dev/null - <<END
from datetime import datetime
dt_obj = datetime.strptime('$1', '$2')
print dt_obj
END

}

#############################
# Porovna dva casove retezce
# $1 - casovy retezec1
# $2 - casovy retezec2
# $3 - TimeStamp
# vraci True jestlize retezec2 > retezec1 jinak False
isbiggerDate ()
{
python 2> /dev/null - <<END
from datetime import datetime
dt_obj1 = datetime.strptime('$1', '$3')
dt_obj2 = datetime.strptime('$2', '$3')
print dt_obj1 < dt_obj2
END

}


#############################
# Prevede casovy retezec na sekundy od pocatku strojoveho casu
# $1 - casovy retezec
# $2 - Timestamp
inSeconds ()
{
python 2> /dev/null - <<END
from datetime import datetime
dt_obj = datetime.strptime('$1', '$2')
print dt_obj.strftime("%s")
END

}






