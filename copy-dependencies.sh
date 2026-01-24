#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

copy_to()
{
  echo "$1 $2 $3"
  SOURCE=$2
  DESTINATION=$3

  while IFS= read -r line; do
    TARGET="$SOURCE/$line"
    if [ -f "$TARGET" ]; then
      echo "$TARGET exists"
      cp --update=older -v "$TARGET"* "$DESTINATION/"
      if [ $? -eq 0 ]; then
        continue
      else
        return 1
      fi
    else
      echo "$TARGET doesn't exist."
      return 1
    fi
    if [ -f "$TARGET.dep" ]; then
      copy_to "$TARGET.dep" "$SOURCE" "$DESTINATION"
    fi
  done < "$1"
  return $?
}

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
      cp --update=older -v "$TARGET"* "$DESTINATION/"
      if [ $? -ne 0 ]; then
        echo "cp error"
        return $?
      fi
    else
      echo "$TARGET does not exist!"
      return 1
    fi
    if [ -f "$TARGET.dep" ]; then
      echo "calling copy_to"
      copy_to "$TARGET.dep" "$SOURCE" "$DESTINATION"
      if [ $? -ne 0 ]; then
        echo "copy_to error"
        return $?
      fi
    else
      echo "$TARGET.dep does not exist."
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
