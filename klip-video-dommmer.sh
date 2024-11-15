#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && set -x

delimiter="--"

IFS=$'\n'
if [[ ${1:-} == "" ]]; then 
	echo "Venligst angiv input video som første parameter.."
	ls -1 *.mp4
	read -p "-->: " -r video_file 
else
	video_file=${1}
fi
[[ -f $video_file ]] || {
	echo "Den indtastede fil eksistere ikke: $video_file"
	exit 1
}  
video_file=$(realpath "$video_file")
path_to_file="$(dirname "$video_file")"

if [[ ${2:-} == "" ]]; then 
	echo "Venligst angiv csv fil som første parameter.."
	ls -1 *.csv
	read -p " -->: " -r csv_file 
else
	csv_file=${2}
fi
[[ -f $csv_file ]] || {
	echo "Den indtastede fil eksistere ikke: $csv_file"
	exit 1
}  

echo "Alt ser fint ud .. "
echo 

IFS=$'\r\n'
for cut in $(cat $csv_file | grep -v 'Name;Position' ); do 
	catagory=$(echo $cut |cut -f 1 -d ';' | sed -e "s|/|-|g" )
	halvleg=$(echo $cut |cut -f 4 -d ';' | cut -d . -f 1 )
	start_time=$(echo $cut |cut -f 2 -d ';' | cut -d : -f -2)
	start_time_txt=$(echo $start_time )
	
	duration_time=$(echo $cut |cut -f 3 -d ';' )
	file_comments=$(echo $cut |cut -f 7 -d ';' \
						| sed -e 's/ /-/g' \
						| sed -e 's/\./-/g' \
						| sed -e 's/,/-/g' \
						)
	#secs=$(date -d "1970-01-01T00:${start_time} UTC" "+%s")
	
	output_file="${halvleg}${delimiter}${start_time_txt}${delimiter}${catagory}${delimiter}${file_comments}.mp4"
	output_file_unspaced="${path_to_file}/${output_file/ /}"
	printf  "Laver videoklip:\n   -i %s\n   -ss %s\n   -t %s\n   %s: " \
				"$video_file" \
				"$start_time" \
				"$duration_time" \
				"${output_file_unspaced}"
	epoc_sec_start=$(date +%s)
	ffmpeg -hide_banner -loglevel error \
		-ss "$start_time" \
		-i "$video_file" \
		-c copy \
		-ss "00:01" \
		-t "$duration_time" \
		-y \
		"${output_file_unspaced}" || {
		exit 1
	}
	epoc_sec_slut=$(date +%s)	
	convert_time=$(( epoc_sec_slut - epoc_sec_start ))
	echo "Konverterede $start_time / $duration_time på $convert_time sekunder"
	
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