#!/bin/sh

##############################################################
# Copyright (C) 2026 linic@hotmail.ca under GPL-3.0 license. #
# https://github.com/linic/tcz.facedebouc.sbs                #
##############################################################

usage()
{
  echo "./navigate.sh [list [artifacts|root] | download [artifact_name]] [url]"
  echo "example: ./navigate.sh list https://tcz.facedebouc.sbs"
}

get_artifacts_lst()
{
  ARTIFACTS_LST=`wget -qO- "$BASE_URL/artifacts.lst"`
  return $?
}

get_root_lst()
{
  ROOT_LST=`wget -qO- "$BASE_URL/root.lst"`
  return $?
}

get_download_info()
{
  ORGANIZATION=`wget -qO- "$BASE_URL/organization.txt"`
  #ORGANIZATION=`wget -qO- "$BASE_URL/16.x/x86/tcz/organization.txt"`
  if [ $? != 0 ] || [ -z "$ORGANIZATION" ]; then
    return 20
  fi
  REPOSITORY=`wget -qO- "$BASE_URL/repository.txt"`
  #REPOSITORY=`wget -qO- "$BASE_URL/16.x/x86/tcz/repository.txt"`
  if [ $? != 0 ] || [ -z "$REPOSITORY" ]; then
    return 21
  fi
  URL=https://github.com/$ORGANIZATION/$REPOSITORY.git/info/lfs/objects/batch
  H1="Accept: application/vnd.git-lfs+json"
  H2="Content-type: application/json"
  BODY="{\"operation\": \"download\", \"transfers\": [\"basic\"], \"ref\": {\"name\": \"refs/heads/main\"}, \"objects\": [{\"oid\": \"$SHA\", \"size\": $SIZE}], \"hash_algo\": \"sha256\"}"
  DOWNLOAD_INFO=`curl -s -X POST -H "$H1" -H "$H2" -d "$BODY" $URL`
  if [ $? != 0 ] || [ -z "$REPOSITORY" ]; then
    return 22
  fi
}

regular_download()
{
  wget -c -O "$ARTIFACT_NAME" "$BASE_URL/$ARTIFACT_RELATIVE_PATH"
  if [ $? != 0 ]; then
    echo "Failed to download $BASE_URL/$ARTIFACT_RELATIVE_PATH."
    return 50
  else
    echo "Downloaded $BASE_URL/$ARTIFACT_RELATIVE_PATH directly."
    echo "Maybe it is not in the github lfs."
    echo "When a file is not in the github lfs, download it directly."
    echo "Please inspect the file $ARTIFACT_NAME."
    return 0
  fi
}

download()
{
  if get_root_lst; then
    EXISTING="$ROOT_LST"
  elif get_artifacts_lst; then
    EXISTING="$ARTIFACTS_LST"
  fi
  ARTIFACT_RELATIVE_PATH=`echo "$EXISTING" | grep --text "$ARTIFACT_NAME" | head -1`
  if [ ! -z "$ARTIFACT_RELATIVE_PATH" ]; then
    pointer=`wget -qO- "$BASE_URL/$ARTIFACT_RELATIVE_PATH"`
    if [ $? != 0 ] || [ -z "$pointer" ]; then
      echo "Failed to get pointer: $pointer"
      regular_download
      return 10
    fi
    SHA=`echo "$pointer" | grep -o 'sha256:[^"]*' | cut -d':' -f2 | head -1`
    if [ $? != 0 ] || [ -z "$SHA" ]; then
      echo "Failed to extract SHA: $SHA"
      regular_download
      return 11
    fi
    SIZE=`echo "$pointer" | grep -o 'size [^"]*' | cut -d' ' -f2 | head -1`
    if [ $? != 0 ] || [ -z "$SIZE"  ]; then
      echo "Failed to extract SIZE: $SIZE"
      regular_download
      return 12
    fi
    get_download_info
    HREF=`echo "$DOWNLOAD_INFO" | grep -o '"href":.*"[^"]*"' | cut -d'"' -f4 | head -1`
    ARTIFACT_NAME=`echo "$ARTIFACT_RELATIVE_PATH" | rev | cut -d'/' -f1 | rev`
    wget -c -O "$ARTIFACT_NAME" "$HREF"
    if [ $? != 0 ]; then
      regular_download
      return 13
    fi
    return $?
  else
    echo "$ARTIFACT_NAME not found in $BASE_URL/artifacts.lst"
    return 1
  fi
}

main()
{
  case "$1" in
    list)
      BASE_URL=$3
      if [ -z "$BASE_URL" ]; then
        usage
        exit 3
      fi
      case "$2" in
        artifacts)
          get_artifacts_lst
          result=$?
          echo "$ARTIFACTS_LST"
          exit $result
          ;;
        root)
          get_root_lst
          result=$?
          echo "$RESULT_LST"
          exit $result
          ;;
        *)
          usage
          exit $?
          ;;
      esac
      ;;
    download)
      BASE_URL=$3
      if [ -z "$BASE_URL" ]; then
        usage
        exit 4
      fi
      ARTIFACT_NAME=$2
      if [ -z "$ARTIFACT_NAME" ]; then
        usage
        exit 5
      fi
      download
      exit $?
      ;;
    *)
      usage
      exit $?
      ;;
  esac
}

main "$@"
