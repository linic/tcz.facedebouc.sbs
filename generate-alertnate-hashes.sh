#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

TC17="17.x/x86/tcz"
TC16="16.x/x86/tcz"

generate_hashes()
{
  cd "$1"
  while IFS= read -r line; do
    if [ ! -f $line.sha1.txt ]; then
      sha1sum $line > $line.sha1.txt
    fi
    if [ ! -f $line.sha256.txt ]; then
      sha256sum $line > $line.sha256.txt
    fi
    if [ ! -f $line.sha512.txt ]; then
      sha512sum $line > $line.sha512.txt
    fi
  done < "info.lst"
  cd $OLDPWD
}

usage()
{
  echo "Usage: ./update-dbs.sh [path]"
  echo "example ./update-dbs.sh 16.x/x86/tcz"
  return 2
}

main()
{
  if [ ! $# -eq 1 ]; then
    usage
    exit $?
  fi
  case "$1" in
    "$TC17")
      generate_hashes "$1"
      exit $?
      ;;
    "$TC16")
      generate_hashes "$1"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
