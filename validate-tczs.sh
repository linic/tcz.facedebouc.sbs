#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

validate_target()
{
  result=0
  TARGET="$1/$2"
  TARGET_DIR="$1"
  TARGET_NAME="$2"
  grep "$TARGET_NAME" processed.txt -q
  if [ $? -eq 0 ]; then
    echo -n "-"
    return 0
  fi
  if [ -f "$TARGET".md5.txt ]; then
    cd $TARGET_DIR
    md5sum -c "$TARGET_NAME".md5.txt --status
    result=$?
    cd $OLDPWD
    if [ $result -eq 1 ]; then
      echo -n "1"
      echo "$TARGET" >> invalid.txt
    else
      echo -n "0"
      echo "$TARGET" >> valid.txt
    fi
  else
    echo -n "2"
    echo "$TARGET" >> missing.txt
    result=$(($result | 4))
  fi
  echo "$TARGET" >> processed.txt
  if [ -f "$TARGET.dep" ]; then
    validate_dep "$TARGET.dep" "$TARGET_DIR"
    result=$((result | $?))
  else
    echo -n ","
  fi
  return $result
}

validate_dep()
{
  result=0

  TARGET_DIR=$2

  while IFS= read -r TARGET_NAME; do
    # remove trailing white spaces
    TARGET_NAME=`echo "$TARGET_NAME" | sed 's/\ //g'`
    if [ -z $TARGET_NAME ]; then
      continue
    fi
    case $TARGET_NAME in
      *.tcz)
        ;;
      *)
        TARGET_NAME="$TARGET_NAME.tcz"
        ;;
    esac
    # KERNEL substitution for 16.x/x86 if present.
    # TODO make this more generic? Maybe a translation table in the script?
    TARGET_NAME=`echo "$TARGET_NAME" | sed 's/KERNEL/6.12.11-tinycore/g'`
    validate_target "$TARGET_DIR" "$TARGET_NAME"
    result=$((result | $?))
  done < "$1"
  return $result
}

validate()
{
  result=0

  TARGET_DIR=`echo "$1" | cut -d'/' -f1,2,3`
  if [ -d "$TARGET_DIR" ]; then
    echo "$TARGET_DIR exists"
    continue
  else
    echo "$TARGET_DIR does not exist."
    return 1
  fi

  while IFS= read -r TARGET_NAME; do
    if [ -z $TARGET_NAME ]; then
      continue
    fi
    TARGET="$TARGET_DIR/$TARGET_NAME"
    validate_target $TARGET_DIR $TARGET_NAME
  done < "$1"
  return $result
}

usage()
{
  echo "./validate-tczs.sh [info.lst]"
  echo "example ./validate-tczs.sh 16.x/x86/tcz/info.lst"
  return 2
}

main()
{
  rm -f processed.txt
  rm -f valid.txt
  rm -f invalid.txt
  rm -f missing.txt
  touch processed.txt
  touch valid.txt
  touch invalid.txt
  touch missing.txt
  if [ $# -lt 1 ]; then
    usage
    exit $?
  fi
  case "$1" in
    *info.lst)
      validate "$@"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
