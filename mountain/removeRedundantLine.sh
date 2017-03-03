#! /bin/bash
# Author:ZZX
# Create time: 20160812


if [ ! -z "$1" ];then
awk '!a[$0]++{print $0}' $1
else

    if [ -f "./.line.repeat.num.tmp" ];then
        rm "./.line.repeat.num.tmp"
    fi

    while read line; do
        echo -e "$line" >> "./.line.repeat.num.tmp"
    done
    awk '!a[$0]++{print $0}' ./.line.repeat.num.tmp && rm ./.line.repeat.num.tmp

fi


another_way="
if [ -f "./.line.repeat.num.tmp" ];then
    rm "./.line.repeat.num.tmp"
fi

tmp="./.line.repeat.num.tmp"

if [ -z "$1" ];then

while read line; do
   echo -e "$line" >> "./.line.repeat.num.tmp"
done

else
    tmp=$1    
fi


perl -ne 'print unless $dup{$_}++;' $tmp

if [ -f "./.line.repeat.num.tmp" ];then
    rm "./.line.repeat.num.tmp"
fi
"

# Also, one can use sort and unique (-d and -u) option to finish this job.


