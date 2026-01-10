#!/bin/sh
USAGE="Usage: ./get-download-info.json [a.tcz.pointer]"
if [ ! $# -eq 1 ]; then
  echo "$USAGE"
  exit 1
fi
POINTER=$1
case "$1" in
  *.tcz.pointer)
    echo "$1 is a pointer file which is good."
    ;;
  *)
    echo "$1 is not a pointer file!"
    echo "$USAGE"
    exit 2
    ;;
esac
SHA=`cat $1 | ./extract-oid.sh`
SIZE=`cat $1 | ./extract-size.sh`
ORGANIZATION=linic
REPOSITORY=tcz.facedebouc.sbs
URL=https://github.com/$ORGANIZATION/$REPOSITORY.git/info/lfs/objects/batch

echo "Continuing with SHA=$SHA, SIZE=$SIZE, URL=$URL"

# Le body est spécifié directement dans -d parce que j'avais essayé de le mettre dans une
# variable BODY et de l'utiliser avec `-d '$BODY'`, mais les '' passe en fait directement
# la chaîne de caractère $BODY à curl et github répond avec une erreur.
# Le -s est important pour pouvoir utiliser le pipe sinon on se retrouve avec le status
# du téléchargement de la réponse au lieu de la réponse.
curl -s -X POST \
-H "Accept: application/vnd.git-lfs+json" \
-H "Content-type: application/json" \
-d "{\"operation\": \"download\", \"transfers\": [\"basic\"], \"ref\": {\"name\": \"refs/heads/main\"}, \"objects\": [{\"oid\": \"$SHA\", \"size\": $SIZE}], \"hash_algo\": \"sha256\"}" \
$URL

