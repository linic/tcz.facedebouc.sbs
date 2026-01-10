#!/bin/sh
# Support for github pages tinycore tcz mirror requires curl to do github API requests.
./get-curl.sh
# curl requires the following
# ca-certificates has 1 dependency
./get-ca-certificates.sh
# libzstd has 0 dependency
./get-libzstd.sh

# getting ca-certificates dependency
# openssl has 1 dependency
./get-openssl.sh

# getting openssl depency
# gcc_libs has 0 dependency
./get-gcc_libs.sh

