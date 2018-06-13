#! /bin/bash
# $1 is file path
# Author: Jason 2018-06-01

fileName=`echo $1 | awk -F '/' '{print $NF}'`

echo -n -e "`date`: add $fileName to $1"

sed -i '1s/^/'$fileName'\'$'\n/g' $1

echo -n -e "     Done\n"


