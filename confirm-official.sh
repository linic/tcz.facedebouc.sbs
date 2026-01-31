#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

MIRROR="http://repo.tinycorelinux.net"
TEMP_DIR="./temp/"
mkdir -pv $TEMP_DIR

check()
{
  TARGET=`echo "$1" | cut -d'/' -f4`

  result=0

  cd $TEMP_DIR
  
	md5sum -c "$TARGET".md5.txt

  cd $OLDPWD

  return $result
}

download()
{
  result=0

  cd $TEMP_DIR
	wget -cq "$MIRROR"/"$1".md5.txt 2>/dev/null
  if [ "$?" != 0 ]; then
    result=$((result | 4))
  fi
	wget -c "$MIRROR"/"$1"
  if [ "$?" != 0 ]; then
    result=$((result | 8))
  fi
  cd $OLDPWD

  return $result
}

confirm_official()
{
  result=0

  while IFS= read -r TARGET; do
    if [ -z $TARGET ]; then
      continue
    fi
    download $TARGET
    if [ "$?" != 0 ]; then
      echo "$TARGET download failed."
      result=$((result | $?))
      continue
    fi
    check $TARGET
    if [ "$?" != 0 ]; then
      echo "$TARGET check failed."
      result=$((result | $?))
    fi
  done < "$1"

  return $result
}

usage()
{
  echo "./confirm-official.sh [invalid.txt]"
  echo "validate-tczs.sh produces a invalid.txt which lists the extensions for which md5sum check fails."
  echo "confirm-official checks http://repo.tinycorelinux.net/ to see if the issue is there."
  return 2
}

main()
{
  if [ $# -lt 1 ]; then
    usage
    exit $?
  fi
  case "$1" in
    *invalid.txt)
      confirm_official "$@"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
