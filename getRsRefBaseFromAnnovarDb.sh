#! /bin/bash
annovar_db="/home/qyy/src/annovar/humandb/hg19_avsnp1424.txt"

sed -ibak 's#$#$#g' $1
grep -f $1 $annovar
mv ${1}bak $1


