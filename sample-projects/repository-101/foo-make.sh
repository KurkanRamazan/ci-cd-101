#!/bin/bash
if [ -d "dist" ]; then rm -Rf dist; fi
mkdir dist
echo $RANDOM | md5sum > dist/generated_file.txt
cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 5 >> dist/generated_file.txt