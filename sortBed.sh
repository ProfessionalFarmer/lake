#! /bin/bash
# Author: Jason 20170426
# bash sh $1

BED_FILE=$1

# -V, --version-sort          natural sort of (version) numbers within text

sort -V -k1,1 -k2,2n $BED_FILE


