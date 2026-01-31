#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

add_to_processed()
{
  echo "$1" >> processed.txt
  return "$?"
}

has_been_processed()
{
  grep "$1" processed.txt -q
  return "$?"
}

add_to_missing()
{
  echo "$1" >> missing.txt
  return "$?"
}

copy_to()
{
  echo "$1 $2 $3"
  SOURCE=$2
  DESTINATION=$3

  while IFS= read -r line; do
    # remove trailing white spaces
    line=`echo "$line" | sed 's/\ //g'`
    if [ -z $line ]; then
      continue
    fi
    case $line in
      *.tcz)
        ;;
      *)
        line="$line.tcz"
        ;;
    esac
    if echo "$line" | grep "KERNEL" -q; then
      if echo "$DESTINATION" | grep "17.x/x86/tcz" -q; then
        line=`echo "$line" | sed 's/KERNEL/6.18.2-tinycore/g'`
      elif echo "$DESTINATION" | grep "16.x/x86/tcz" -q; then
        line=`echo "$line" | sed 's/KERNEL/6.12.11-tinycore/g'`
      else
        echo "Unsupported KERNEL translation for $DESTINATION"
        return 1
      fi
    fi
    TARGET="$SOURCE/$line"
    if has_been_processed "$line"; then
      continue
    fi
    add_to_processed "$line"
    if [ -f "$TARGET" ]; then
      echo "$TARGET exists"
      cp --update=older -v "$TARGET"* "$DESTINATION/"
      if [ $? -eq 0 ]; then
        continue
      else
        return 1
      fi
    else
      add_to_missing "$line"
    fi
    if [ -f "$TARGET.dep" ]; then
      copy_to "$TARGET.dep" "$SOURCE" "$DESTINATION"
    fi
  done < "$1"
  return $?
}

copy()
{
  if [ -f "$1" ]; then
    echo "$1 exits"
  else
    echo "$1 does not exist"
    return 1
  fi

  DESTINATION=`echo "$1" | cut -d'/' -f1,2,3`
  if [ -d "$DESTINATION" ]; then
    echo "$DESTINATION exists"
    continue
  else
    echo "$DESTINATION does not exist."
    return 1
  fi

  SOURCE=$2
  if [ -d "$SOURCE" ]; then
    echo "$SOURCE exists"
    continue
  else
    echo "$SOURCE does not exist."
    return 1
  fi

  copy_to "$1" "$SOURCE" "$DESTINATION"
  return $?
}

usage()
{
  echo "copy-dependencies [a.tcz.dep] [source-dir]"
  echo "example ./copy-dependencies.sh 16.x/x86/tcz/compiletc.tcz.dep /temp/tinycorelinux.net/16.x/x86/tcz"
  echo "where /temp/tinycorelinux.net/16.x/x86/tcz contains all current extensions copied from another mirror."
  echo "note if you rename info.lst from the mirror copy to special-temp-tcz.tcz.dep and use that as the first parameter, you'll copy everything."
  return 2
}

main()
{
  if [ $# -lt 1 ]; then
    usage
    exit $?
  fi
  case "$1" in
    *.tcz.dep)
      copy "$@"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
