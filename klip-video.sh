#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && set -x

delimiter="--"

IFS=$'\n'
if [[ ${1:-} == "" ]]; then 
	echo "Venligst angiv input video som første parameter.."
	read -r input_file
else
	input_file=${1}
fi
[[ -f $input_file ]] || {
	echo "Den indtastede fil eksistere ikke: $input_file"
	exit 1
}  
input_file=$(realpath "$input_file")

path_to_file="$(dirname "$input_file")"
echo "Alt ser fint ud .. "
echo 
echo "Alle tider indtastes som følgende eksempler:"
echo " - 1 sekund: 1"
echo " - 1 minut: 1:00"
echo " - 1 time: 1:00:00"
echo
echo "Det endelige klip:"
echo " - filnavn: '<katagori>${delimiter}<type>${delimiter}<kommentar>.mp4' "
echo " - Alle mellemrum bliver lavet om til '-' ; dvs 'bla bla' bliver lavet om til 'bla-bla'"
echo " - Programmet sætter selv '.mp4' på den endelige fil; 'bla-bla.mp4'"
echo " "
echo "Aflutning:"
echo " - Afvent sidste konvertering er færdig"
echo " - '<ctrl> + c' vil til enhver tid stoppe programmet"
echo " "
echo "Lad os komme i gang .."
printf "Tryk <enter>\n"
read -r next
echo "$next"
clear

## declare an array variable
declare -a catagorys=("forsvar" "angreb" "retur" "kontra" "andet")
declare -a types=("7mod6" "franskX" "centerX" "fløjX" "rundgang" "special")

while true ; do
	echo "Katagorier:"
	loop=0
	for i in "${catagorys[@]}";	do
		loop=$(( loop + 1 ))
		echo "${loop}) $i"
	done
	printf "Vælg kategori: ( 1 - %s ): " "${#catagorys[@]}"
	while true ; do
		read -r catagory
		if [[ $catagory -gt ${#catagorys[@]} || $catagory -lt 1 ]]; then
			echo "ERROR!! forkert input - $catagory - prøv igen.."
			printf "Vælg kategori: ( 1 - %s ): " "${#catagorys[@]}"
		else
			catagory_txt=${catagorys[$(( loop - 1 ))]}
			echo
			break
		fi
	done

	echo "Type:"
	loop=0
	for i in "${types[@]}";	do
		loop=$(( loop + 1 ))
		echo "${loop}) $i"
	done
	printf "Vælg type: ( 1 - %s ): " "${#types[@]}"
	while true ; do
		read -r type
		if [[ $type -gt ${#types[@]} || $type -lt 1 ]]; then
			echo "ERROR!! forkert input - $type - prøv igen.."
			printf "Vælg type: ( 1 - %s ): " "${#types[@]}"
		else
			type_txt=${types[$(( loop -1 ))]}
			echo
			break
		fi
	done

	while [[ ${starttime_accept:-} == "" ]] ; do
		echo "Indtast start tid for klippet:"
		read -r starttime
		if [[ ${starttime:-} != "" ]] ; then
			starttime_accept=$starttime
		else
			echo "start er tom..."
		fi
	done
	while [[ ${length_accept:-} == "" ]] ; do
		echo "Indtast længde på klippet: ( standard: 59 sekunder - bare tryk <enter> )"
		read -r length
		if [[ ${length:-} != "" ]] ; then
			length_accept=$length
		else
			echo "Længde er tom... Vi bruger standarden på 59 sekunder"
			length_accept=59
		fi
	done
	while [[ ${clipname_accept:-} == "" ]] ; do
		echo "Indtast kommentar på klippet (mellem bliver til '-') : "
		read -r clipname
		if [[ ${clipname:-} != "" ]] ; then
			clipname_accept=${clipname// /-}
			echo "Vi bruger '$clipname_accept'"
		else
			echo "Kommentar på klippet er tomt... prøv igen"
		fi
	done
	output_file_unspaced="${path_to_file}/${catagory_txt}${delimiter}${type_txt}${delimiter}${clipname_accept}.mp4"

	printf  "Laver videoklip:\n   -i %s\n   -ss %s\n   -t %s\n   %s: " "$input_file" "$starttime_accept" "$length_accept" "${output_file_unspaced}"
	epoc_sec_start=$(date +%s)
	ffmpeg -hide_banner -loglevel error -i "$input_file" -ss "$starttime_accept" -t "$length_accept" "${output_file_unspaced}" || {
		exit 1
	}
	epoc_sec_slut=$(date +%s)	
	convert_time=$(( epoc_sec_slut - epoc_sec_start ))
	echo "Konverterede $length_accept på $convert_time sekunder"

	printf "Done\n\nKlar til næste klip - Tryk <enter>"
	read -r next
	echo "$next"
	clear
	unset starttime_accept
	unset length_accept
	unset clipname_accept
	
done

# ffmpeg -i input.mp4 \
# -filter_complex "\
# 	[0:v]crop=2691:1200:0:0[out1];\
# 	[0:v]crop=4036:1200:2691:0[out2];\
# 	[0:v]crop=2691:1200:6727:0[out3];\
# 	[0:v]crop=4036:1200:9418:0[out4]" \
# -map [out1] -map 0:a out1.mp4 \
# -map [out2] -map 0:a out2.mp4 \
# -map [out3] -map 0:a out3.mp4 \
# -map [out4] -map 0:a out4.mp4

# The select filter is better for this.

# ffmpeg -i video \
#        -vf "select='between(t,4,6.5)+between(t,17,26)+between(t,74,91)',
#             setpts=N/FRAME_RATE/TB" \
#        -af "aselect='between(t,4,6.5)+between(t,17,26)+between(t,74,91)',
#             asetpts=N/SR/TB" out.mp4
#select and its counterpart filter is applied to the video and audio respectively. Segments selected are times 4 to 6.5 seconds, 17 to 26 seconds and finally 74 to 91 seconds. The timestamps are made continuous with the setpts and its counterpart filter..

# Download streaming fra Sportway
# https://stackoverflow.com/questions/32528595/ffmpeg-mp4-from-http-live-streaming-m3u8-file
# ffmpeg -i https://cdn.livearenasports.com/blobs0/63b812c58d4b4244f2340119/index.m3u8 -c copy -bsf:a aac_adtstoasc 2023-01-23-HØJ2-Rødovre.mp4