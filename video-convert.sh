#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && {
  export debug=true
  set -x
}

#######################################
# Convert mp4 file to unified format
# usage:
#   mergemp4 #merges all mp4 in current directory
#   mergemp4 video1.mp4 video2.mp4
#   mergemp4 video1.mp4 video2.mp4 [ video3.mp4 ...] output.mp4 
#######################################

cd raw
time merge-videos.sh
cd -
time ffmpeg  -loglevel error -i raw/output.mp4  "$(basename "$(pwd)").mp4"