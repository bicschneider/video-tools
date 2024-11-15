#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && set -x

#######################################
# Download stream from URL base .m3u8 file
# usage:
#   Find the stream file from "anywhere". 
#   In Team Account:
#     - Login to TeamAccount
#     - Find and open the recoding
#     - Open DeveloperTools in the browser ( Ctrl + shift + I )
#     - In the tools panel open the network tab
#     - In the "filter" add "index"
#######################################

function print_info {
  echo "Download full video: Just provide url as first parameter.."
  echo
  echo "You can also download as many sections of the video as you want ( 1. half and 2. half), but as one video ( i.e cut sections out ) in the follow way"
  echo "Example:"
  printf "%s <url> ss=1:00@to=35:00,ss=46:00@to=1:01:00 ( downloads 1st section from 1 minute until 35 minutes + from 46 minute and until 1 hour and 1 minute )\n" "$(basename "$0")"
  echo
  echo "Start time: -ss=<time> "
  echo "Until time: -to=<time>"
  echo "<time> is written like this:"
  echo " - 1 second: 1"
  echo " - 1 minute: 1:00"
  echo " - 1 hour: 1:00:00"
  echo
}

function download {
  local _stream_url=$1
  local _download_option=${2:-}
  local _iteration=${3:-}

  [[ ${_iteration:-} != "" ]] && _iteration="-${_iteration}"
  eval "$(echo ${_download_option} | cut -d @ -f 1 )" || { echo "ERROR: something is wrong with the parameters" ; exit 1; }  
  eval "$(echo ${_download_option} | cut -d @ -f 2 )" || { echo "ERROR: something is wrong with the parameters" ; exit 1; }



  video_file_name=${filename_base}
  
  IFS=$'\n'
  echo "Download: from $ss to $to output: ${video_file_name}${_iteration:-}.mp4"
  ffmpeg \
      -y \
      -hide_banner -loglevel error \
      -ss ${ss} \
      -to ${to} \
      -i ${_stream_url} \
      -c copy -bsf:a aac_adtstoasc \
      ${video_file_name}${_iteration:-}.mp4 2> ${video_file_name}${_iteration:-}.log || {
        cat ${video_file_name}${_iteration:-}.log
      }
      rm -f ${video_file_name}${_iteration:-}.log 2> /dev/null
      }

[[ ${1:-} == "" ]] && {
  echo "ERROR: Please provide a url for download as first parameter"
  print_info
  exit 1
}

if [[ ${filename_base:-} == "" ]]; then
  dirname="${PWD##*/}"
  export filename_base=${dirname/ /-}
  echo "INFO: filename_base is empty - use the current dirname as target video filename: $filename_base"
else
  echo "INFO: filename_base is set: $filename_base"
fi

[[ -e ${filename_base}.mp4 ]] && {
  echo "cleanup :  ${filename_base}.mp4"
  rm -f "${filename_base}.mp4"
}
rm -f tmp.*
ls -1 "${filename_base}-*.mp4" 2> /dev/null | xargs rm -f || true 


if [[ ${2:-} == "" ]] ; then 
  echo "INFO: Download full video .. Otherwise specify start time and duration or stop time like this"
  print_info
  echo "Wait 5 sec - You can ctrl + c to cancel and run with parameters"
  sleep 5
  download "$1"
else
  iteration=1
  IFS=, 
  for time_interval in ${2} ; do
    download "$1" "${time_interval}" "$iteration" &
    iteration=$(( iteration + 1))
  done
  sleep 5
  echo "wait until jobs are done:"
  jobs
  wait 
  echo "Download - Done"
  echo "Merge videos"
  debug=${debug:-} merge-videos.sh $(ls -1 ${filename_base}-*.mp4) ${filename_base}.mp4  
  echo "Cleanup" 
  ls -1  ${filename_base}-*.mp4 | xargs rm -f 
  ls -l
fi

