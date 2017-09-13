#!/bin/bash

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

INPUT_DIR=$1
OUTPUT_DIR=$2

OUTPUT_DIR=`readlink -f $OUTPUT_DIR`

mkdir -p $OUTPUT_DIR

export INPUT_DIR
for f in `find $1 -name "*.txt"`
do
    NEW_FILENAME=`echo $f | perl -ne 's/\s/_/g; s/_$//g; $name = $1 if /$ENV{INPUT_DIR}\/(.*)/; $name =~ s/\//_/g; print "$name\n"'`
    echo $NEW_FILENAME
    echo $f | xargs -I{} cp {} $OUTPUT_DIR/$NEW_FILENAME
done

IFS=$SAVEIFS
