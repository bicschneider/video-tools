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

function download {
  local _stream_url=$1
    
  video_file_name=$(basename "$(pwd)")
  [[ -e "${video_file_name}" ]] && {
    echo "ERROR: Filename already exists: $video_file_name - exit"
    exit 1
  }
  
  ffmpeg \
      -i \
      ${_stream_url} \
      -c copy -bsf:a aac_adtstoasc \
      ${video_file_name}.mp4
}

[[ ${1:-} == "" ]] && {
  echo "ERROR: Please provide a url for download as first parameter"
  exit 1
}
download "$1"
