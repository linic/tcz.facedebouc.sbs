#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################


copy()
{
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

  while IFS= read -r line; do
    TARGET="$SOURCE/$line"
    if [ -f "$TARGET" ]; then
      echo "$TARGET exists"
      cp -v "$TARGET"* "$DESTINATION/"
      #echo "cp -v $TARGET* $DESTINATION/$line"
      if [ $? -eq 0 ]; then
        continue
      else
        return 1
      fi
    else
      echo "$TARGET doesn't exist."
      return 1
    fi
  done < "$1"
  return $?
}

usage()
{
  echo "copy-dependencies [a.tcz.dep] [source-dir]"
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
