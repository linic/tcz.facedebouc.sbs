#!/bin/sh

###################################################################
# Copyright (C) 2026  linic@hotmail.ca Subject to GPL-3.0 license.#
# https://git@github.com:linic/tcz.facedebouc.sbs.git             #
###################################################################

TC17="17.x/x86/tcz"
TC16="16.x/x86/tcz"

update_dbs()
{
  # Subject to change.
  # What I consider databases which are updated by this script:
  # - 16.x/x86/tcz/tags.db.gz
  # - 16.x/x86/tcz/info.lst
  # - 16.x/x86/tcz.html
  cd "$1"
  ls *.tcz > info.lst
  cp info.lst ../tcz.html
  # Updating tags.db.gz
  gunzip tags.db.gz

  : > tags.db.tmp   # temporary output

  for f in *.tcz; do
    # skip if already present in tags.db
    if [ -f tags.db ] && grep -q "^$f\\b" tags.db; then
        continue
    fi

    # try to find full line in tinycorelinux.net.tags.db
    line=$(grep "^$f\\b" tinycorelinux.net.tags.db)

    if [ -n "$line" ]; then
        printf '%s\n' "$line" >> tags.db.tmp
    else
        printf '%s\n' "$f" >> tags.db.tmp
    fi
  done

  # append the diff in .tmp
  cat tags.db.tmp >> tags.db
  rm -f tags.db.tmp
  gzip tags.db
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
      update_dbs "$@"
      exit $?
      ;;
    "$TC16")
      update_dbs "$@"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
