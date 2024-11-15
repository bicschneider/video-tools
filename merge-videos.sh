#!/bin/bash

set -euo pipefail

[[ ${debug:-} == true ]] && {
  export debug=true
  set -x
}

#######################################
# Merge mp4 files into one output mp4 file
# usage:
#   mergemp4 #merges all mp4 in current directory
#   mergemp4 video1.mp4 video2.mp4
#   mergemp4 video1.mp4 video2.mp4 [ video3.mp4 ...] output.mp4 
#######################################

function mergemp4() {
  if [ $# = 1 ]; then return; fi

  outputfile="output.mp4"

  rm -f $outputfile
  rm -f tmp.*

  temp_cat_file=$(mktemp -p .)

  #if no arguments we take all mp4 in current directory as array
  if [ $# = 0 ]; then ls -1v *.mp4 | xargs -I % echo "file './%'" > $temp_cat_file; fi
  if [ $# = 2 ]; then echo "$1 $2" | xargs -I % echo "file './%'" > $temp_cat_file; fi
  if [ $# -ge 3 ]; then
    outputfile=${@: -1} # Get the last argument
    for file in $( echo ${@:1:$# - 1}) ; do 
      echo "file './${file}'" >> $temp_cat_file
    done
  fi

  cat $temp_cat_file

  # -y: automatically overwrite output file if exists
  # -loglevel quiet: disable ffmpeg logs
  ffmpeg \
      -y \
      -hide_banner -loglevel error \
      -f concat \
      -safe 0 \
      -i $temp_cat_file \
      -c copy $outputfile

  if test -f "$outputfile"; then echo "$outputfile created"; fi
  rm -f $temp_cat_file
}
mergemp4 $*
