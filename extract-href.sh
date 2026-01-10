#!/bin/sh
# Usage: ./get-download-info.sh | ./extract-href.sh
# Read from stdin, output href URL
# ./get-download-info produces a JSON response like this one
#{
#  "objects": [
#    {
#      "oid": "dfadb3bca91d6ea050b328ba2faa1fd1d941ffe7097f2146e8c1b3a44c533f04",
#      "size": 208289792,
#      "actions": {
#        "download": {
#          "href": "https://github-cloud.githubusercontent.com/alambic/media/1006207579/df/ad/dfadb3bca91d6ea050b328ba2faa1fd1d941ffe7097f2146e8c1b3a44c533f04?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA5BA2674WPWWEFGQ5%2F20260105%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260105T141534Z&X-Amz-Expires=3600&X-Amz-Signature=24ff0dde17267d350b26f5a9f238a7c799164dc47b7c5ef9a687c080237cd995&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=1125244795&token=1",
#          "expires_at": "2026-01-05T15:15:34Z",
#          "expires_in": 3600
#        }
#      }
#    }
#  ]
#}
grep -o '"href":.*"[^"]*"' | cut -d'"' -f4 | head -1
