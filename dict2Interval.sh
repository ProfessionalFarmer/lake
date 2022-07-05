#! /bin/bash

cat $1 |\
    grep -v '@HD' |\
    awk '{print $2"\t"$3}' |\
    sed "s#SN:##g" |\
    sed "s#LN:##g" | \
    awk '{print $1"\t0\t"$2}'


