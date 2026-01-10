#!/bin/sh
USAGE="Usage: ./update-dbs.sh"
if [ ! $# -eq 0 ]; then
  echo "$USAGE"
  exit 1
fi
# Subject to change.
# What I consider databases which are updated by this script:
# - 16.x/x86/tcz/tags.db.gz
# - 16.x/x86/tcz/info.lst
# - 16.x/x86/tcz.html
cd 16.x/x86/tcz/
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
cd -
