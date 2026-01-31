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
  
	md5sum -c "$TARGET".md5.txt --status
  if [ "$?" != 0 ]; then
    result=$((result | $?))
    echo "$TARGET md5sum validation failed:" >> expected-md5-summary.txt
    echo "On mirror:" >> expected-md5-summary.txt
    cat "$TARGET".md5.txt >> expected-md5-summary.txt
    echo "Expected:" >> expected-md5-summary.txt
    md5sum "$TARGET" >> expected-md5-summary.txt
    echo "" >> expected-md5-summary.txt
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
    check $TARGET
    if [ "$?" != 0 ]; then
      result=$((result | $?))
    fi
  done < "$1"

  return $result
}

usage()
{
  echo "./expected-md5.sh [invalid.txt]"
  echo "validate-tczs.sh produces a invalid.txt which lists the extensions for which md5sum check fails."
  echo "expected-md5 checks http://repo.tinycorelinux.net/ to see if the issue is there."
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
