#!/bin/sh
ls | while read line; do
  if echo "$line" | grep "sha512" || echo "$line" | grep "md5"; then
    sed -i 's|./release/1.*.0/||' $line 
  fi
done
