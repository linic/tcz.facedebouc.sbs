#!/bin/sh

##############################################################
# Copyright (C) 2026 linic@hotmail.ca under GPL-3.0 license. #
# https://github.com/linic/tcz.facedebouc.sbs                #
##############################################################

HTML_PAGE="artifacts.html"
LIST_FILE="artifacts.lst"
TREE_PREFIX="├─"

usage()
{
  echo "./update_artifacts_tree.sh [files]"
}

generate_all_files()
{
  tree --noreport -H . >> $HTML_PAGE
  tree --noreport . | sed 's/[^a-zA-Z0-9.-_]//g' > $LIST_FILE
}

generate_files()
{
  rm "../$LIST_FILE"
  touch "../$LIST_FILE"
  rm $HTML_PAGE
  touch $HTML_PAGE
  echo "<!DOCTYPE html>" >> $HTML_PAGE
  echo "<html><head><title>$HTML_PAGE</title><meta charset="UTF-8"></head><body><p><code><pre>" >> $HTML_PAGE
  walk "." "." $TREE_PREFIX "."
  result=$?
  echo "</pre></code></p></body></html>" >> $HTML_PAGE
  return $result
}

walk()
{
  NEXT_DIR_NAME=$1
  RELATIVE_PATH=$2
  TREE_LEVEL=$3
  FILES_DIR=$4
  cd $NEXT_DIR_NAME
  ls | while read line; do
    if [ -d "$line" ]; then
      walk "$line" "$RELATIVE_PATH/$line" "$TREE_LEVEL$TREE_PREFIX" "$FILES_DIR/.."
      if [ $? != 0 ]; then
        return "$?"
      fi
    elif [ -f "$line" ] || [ -x "$line" ]; then
      echo "artifacts/$RELATIVE_PATH/$line" | sed "s|\./||" >> "../$FILES_DIR/$LIST_FILE"
      echo "$TREE_LEVEL <a href=\"$RELATIVE_PATH/$line\">$line</a>" >> "$FILES_DIR/$HTML_PAGE"
    else
      echo "Ignoring $line"
    fi
  done
  return 0
}

add_links()
{
  while read line; do
    name=`echo "$line" | cut -d' ' -f2`
    path=`find -name "$name" -printf "%P\n" | head -n 1`
    if [ -f "$path" ]; then
     href="<a href=\"./$path\">$name</a>"
     sed -i "s|$name|$href|" $HTML_PAGE
     echo "tried to replace $name with $href"
   else
     echo "$path does not exist"
    fi
  done < $LIST_FILE
}

main()
{
  case "$1" in
    links)
      echo "running an old iteration, this won't do what you want probably"
      echo "it worked on a tree.txt file"
      add_links
      ;;
    files)
      generate_files
      ;;
    *)
      usage
      ;;
  esac
  exit "$?"
}

main "$@"
