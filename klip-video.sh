#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && set -x

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
echo " - filnavn: <katagogiMan skriver bare dit klips navn"
echo " - Alle mellemrum bliver lavet om til '-' ; dvs 'bla bla' bliver lavet om til 'bla-bla'"
echo " - Programmet sætter selv '.mp4' på den endelige fil; 'bla-bla.mp4'"
echo " "
echo "Aflutning:"
echo " - Afvent sidste konvertering er færdig"
echo " - '<ctrl> + c' vil til enhver tid stoppe programmet"
echo " "
echo "Lad os komme i gang .."
echo

## declare an array variable
declare -a catagorys=("forsvar" "angreb" "retur" "kontra")
declare -a types=("7mod6" "franskX" "centerX" "fløjX" "rundgang" "special")


while true ; do
	echo "Katagorier:"
	loop=0
	for i in "${catagorys[@]}";	do
		loop=$(( $loop + 1 ))
		echo "${loop}) $i"
	done
	printf "Vælg kategori: ( 1 - ${#catagorys[@]} ): "
	while true ; do
		read -r catagory
		if [[ $catagory -gt ${#catagorys[@]} || $catagory -lt 1 ]]; then
			echo "ERROR!! forkert input - $catagory - prøv igen.."
			printf "Vælg kategori: ( 1 - ${#catagorys[@]} ): "
		else
			catagory_txt=${catagorys[$(( loop -1 ))]}
			echo
			break
		fi
	done

	echo "Type:"
	loop=0
	for i in "${types[@]}";	do
		loop=$(( $loop + 1 ))
		echo "${loop}) $i"
	done
	printf "Vælg type: ( 1 - ${#types[@]} ): "
	while true ; do
		read -r type
		if [[ $type -gt ${#types[@]} || $type -lt 1 ]]; then
			echo "ERROR!! forkert input - $type - prøv igen.."
			printf "Vælg type: ( 1 - ${#types[@]} ): "
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
		echo "Indtast længde på klippet:"
		read -r length
		if [[ ${length:-} != "" ]] ; then
			length_accept=$length
		else
			echo "Længde er tom... prøv igen"
		fi
	done
	while [[ ${clipname_accept:-} == "" ]] ; do
		echo "Indtast kommentar på klippet (mellem bliver til '-') : "
		read -r clipname
		if [[ ${clipname:-} != "" ]] ; then
			clipname_accept=${clipname// /-}
		else
			echo "Navnet på klippet er tomt... prøv igen"
		fi
	done
	output_file_unspaced="${path_to_file}/${catagory_txt}@${type_txt}@${clipname_accept}.mp4"

	clear
	printf  "Laver videoklip:\n   -i %s\n   -ss %s\n   -t %s\n   %s: " "$input_file" "$starttime_accept" "$length_accept" "${output_file_unspaced}"
	ffmpeg -hide_banner -loglevel error -i "$input_file" -ss "$starttime_accept" -t "$length_accept" "${output_file_unspaced}" || {
		exit 1
	}
	printf "Done\n\n"
	unset starttime_accept
	unset length_accept
	unset clipname_accept
done
