#!/bin/sh
# Read from stdin and extract the oid.
# For example, if stdin has
#version https://git-lfs.github.com/spec/v1
#oid sha256:dfadb3bca91d6ea050b328ba2faa1fd1d941ffe7097f2146e8c1b3a44c533f04
#size 208289792
# this script returns:
#dfadb3bca91d6ea050b328ba2faa1fd1d941ffe7097f2146e8c1b3a44c533f04
grep -o 'sha256:[^"]*' | cut -d':' -f2 | head -1
