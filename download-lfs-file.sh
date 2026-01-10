#!/bin/sh
USAGE="Usage: ./download-lfs-file.sh [a.tcz.pointer]"
if [ ! $# -eq 1 ]; then
  echo "$USAGE"
  exit 1
fi
POINTER="$1"
case "$1" in
  *.tcz.pointer)
    echo "$1 is a pointer file which is good."
    ;;
  *)
    echo "$1 is not a pointer file!"
    echo "$USAGE"
    exit 2
    ;;
esac
INFO=`./get-download-info.sh "$POINTER"`
echo "$INFO"
URL=`echo "$INFO" | ./extract-href.sh`
echo "URL=$URL"
TCZ_NAME="${POINTER%.pointer}"
echo "Resulting file will be $TCZ_NAME"

wget -c -O "$TCZ_NAME" "$URL"
