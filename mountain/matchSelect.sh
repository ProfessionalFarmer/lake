#! /bin/bash
# Please note The first column must be considered.
# This script will print information in $3

cat $1 | cut -f $2 | awk -F "\t" '{ print $0 }' > .temp.1.select
cat $3 | grep -Ff .temp.1.select | cut -f $4
rm .temp.1.select


