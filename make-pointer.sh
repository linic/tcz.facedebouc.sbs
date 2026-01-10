#!/bin/sh
USAGE="Usage: ./make-pointer.sh [maybe-pointer.tcz]"
if [ ! $# -eq 1 ]; then
  echo "$USAGE"
  exit 1
fi
if [ ! -f $1 ]; then
  echo "$USAGE"
  exit 2
fi
# Moves a maybe-pointer.tcz file to maybe-pointer.tcz.pointer when it
# has this format:
#version https://git-lfs.github.com/spec/v1
#oid sha256:dfadb3bca91d6ea050b328ba2faa1fd1d941ffe7097f2146e8c1b3a44c533f04
#size 208289792
MAYBE_POINTER="$1"
# The < is for the shell to open the file and pipe it in the stdin of wc.
# That way, the name of the file is not in the returned value.
LINES=`wc -l < "$MAYBE_POINTER"` 
BYTES=`wc -c < "$MAYBE_POINTER"`

echo "$MAYBE_POINTER, $LINES, $BYTES"

if [ $LINES -eq 3 ]; then
  # I picked 200 bytes because my first test got me 134 bytes. The version and oid seem
  # to have a constant length. The size has a variable length. This is a quick sanitization
  # to avoid processing garbage later on.
  if [ $BYTES -lt 200 ]; then
    echo "$1 is a pointer file. Checking if the name ends with .tcz.pointer"
    case "$1" in
      *.tcz.pointer)
        echo "$1 has already been renamed."
        ;;
      *)
        mv "$1" "$1.pointer"
        echo "File renamed to $1.pointer"
        ;;
    esac
  else
    echo "$1 has $BYTES which is more than the max of 200 bytes expected."
  fi
else
  echo "$1 has $LINES which is more than the 3 lines expected."
fi
