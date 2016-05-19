#! /bin/bash
# Create on: 20160519
# accept pipestream: chr pos
# then print chr pos ref 

smts="/data/SG/Env/software_installed/samtools-1.2/samtools"
fa="/data/SG/Env/reference_data/ucsc.hg19.fasta"

# split("str",arr,"-") 用-将str分割，放在arr中
while read line;
do
echo "$line" | sed '#^[chr|Chr]##g' |  awk '{print "chr"$1":"$2"-"$2}' |  xargs -L 1 $smts faidx $fa | sed 's#^>##g' | awk -F '-' '{   \
           if(NR%2==1) {split($1,arr,":");printf("%s\t%s\t",arr[1],arr[2])} \
           else {print $1} \
                                  }'
done


