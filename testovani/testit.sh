#!/bin/bash

printf "Test 1 z 26\n" 
printf "test defaultni hodnoty\n"
../PS2plotter default.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 2 z 26\n" 
printf "test opakovani prepinace chyba\n"
../PS2plotter -l Legenda --legend titulek default.data
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 3 z 26\n" 
printf "test opakovani prepinace spravne\n"
../PS2plotter -g "xlabel \"Cas\"" -g "ylabel \"Hodnota\"" default.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 4 z 26\n" 
printf "test neexistujici soubor s daty\n"
../PS2plotter default.data noexist
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 5 z 26\n" 
printf "test soubor s daty bez prava cist\n"
../PS2plotter default.data noread
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 6 z 26\n" 
printf "test soubor je prazdny\n"
../PS2plotter empty
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 7 z 26\n" 
printf "test neexistujici konfiguracni soubor\n"
../PS2plotter -f cofig1 default.data 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 8 z 26\n" 
printf "test neexistujici direktiva v konfiguracnim souboru\n"
../PS2plotter -f config0 default.data 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 9 z 26\n" 
printf "test neexistujici prepinac\n"
../PS2plotter -k config1 default.data 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 10 z 26\n" 
printf "test neplatna hodnota fps\n"
../PS2plotter -F 1,25 default.data 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 11 z 26\n" 
printf "test neplatna hodnota Xmax\n"
../PS2plotter -X "09:06:13"  default.data 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 12 z 26\n" 
printf "test maximalni rozsahy\n"
../PS2plotter -f config1 -n minmax -X max --xmin min -y min -Y max sin_week_real_part.data  
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 13 z 26\n" 
printf "test vse auto a verbose\n"
../PS2plotter -v -f config1 sin_week_real_part.data  
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 14 z 26\n" 
printf "test xmin = hodnota xmax = hodnota \n"
../PS2plotter -f config1 -x "[2009/05/12 06:30:00]" -X "[2009/05/17 12:30:00]" sin_week_real_part.data  
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 15 z 26\n" 
printf "test pouziti hodnoty z conf. souboru pokud hodnota prepinace neni platna a Ignore errors nastaveno\n"
../PS2plotter -E -v -x "[09:02:29 10.05.2011]" -f config1 sin_week_real_part.data  
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 16 z 26\n" 
printf "test chyba v souboru\n"
../PS2plotter chyba 
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 17 z 26\n" 
printf "zadano time,speed,fps\n"
../PS2plotter -v -f config1 -S 7 -F 15 -T 20.5 sin_week_real_part.data
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 18 z 26\n" 
printf "zadano time,speed,fps a Ignore errors\n"
../PS2plotter -E -v -f config1 -S 7 -F 15 -T 20.5 sin_week_real_part.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 19 z 26\n" 
printf "zadano time,fps\n"
../PS2plotter -v -f config1 -F 15 -T 20.4 sin_week_real_part.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 20 z 26\n" 
printf "test vykresleni kriticke hodnoty\n"
../PS2plotter -f config3  -c "y=0.5:x=[2009/05/12 23:30:00]" sin_week_real_part.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 21 z 26\n" 
printf "test razeni souboru\n"
../PS2plotter -n sorted -f config1 data4 data1 data3 data2
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 22 z 26\n" 
printf "test prekryvu souboru\n"
../PS2plotter -n sorted -f config1 data4 data1 data3 data2 data5
printf "Navratova hodnota:%d ocekavam 1\n\n" $?

printf "Test 23 z 26\n" 
printf "test nazvu s podtrzitkama 3x spusteni\n"
../PS2plotter -n neco_s_podtrzenim -f config1 data1 
../PS2plotter -n neco_s_podtrzenim -f config1 data1 
../PS2plotter -n neco_s_podtrzenim -f config1 data1 
printf "Navratova hodnota:%d ocekavam 0\n\n" $?

printf "Test 24 z 26\n" 
printf "test nazvu retezec mezery a specialni znaky 3x spusteni\n"
../PS2plotter -n "e[*] /[*] ds" -f config1 data1 
../PS2plotter -n "e[*] /[*] ds" -f config1 data1 
../PS2plotter -n "e[*] /[*] ds" -f config1 data1 
printf "Navratova hodnota:%d ocekavam 0\n\n" $?



printf "Test 25 z 26\n"
printf "Stazeni dat z webu\n"  
../PS2plotter -f config2 -t "[%H:%M:%S %d.%m.%Y]" http://goo.gl/AsyLD 
printf "Navratova hodnota:%d ocekavam 0\n\n" $?


printf "Test 26 z 26\n"
printf "soubor + Stazeni dat z webu2\n"  
../PS2plotter -v -f config2 -t "%H:%M:%S" http://goo.gl/sqOCK lokal.data
printf "Navratova hodnota:%d ocekavam 0\n\n" $?
