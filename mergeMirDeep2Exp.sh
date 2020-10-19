#! /bin/bash

# merge miRdeep2 expression result in current directory
# just set output file name

out=$1
uid=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
#uid="ttt"
mkdir $uid

for file in `ls */*expressed_all*`;
do
    smp=` echo $file | cut -f 1 -d '/' `
    echo $file

    cat $file | grep '^#' | sed "s#read_count#${smp}_read_count#g" | sed "s#seq(norm)#${smp}_seq(norm)#g"> $uid/$smp.raw.exp.tsv
    cat $file | grep -v '^#' >> $uid/$smp.raw.exp.tsv 

    cut -f 2,6 $uid/$smp.raw.exp.tsv > $uid/$smp.cut.exp.tsv


done

cut -f 1,3 `ls $uid/*raw.exp.tsv | head -1` | sed "s#\###g" > $uid.1.tsv
paste $uid/*.cut.exp.tsv  > $uid.2.tsv

paste $uid.1.tsv $uid.2.tsv > $uid.3.tsv


if [[ ! -n $out ]]; then
  mv $uid.3.tsv mirdeep2.exp.tsv
else  
  mv $uid.3.tsv $out
fi 

rm -rf $uid*

