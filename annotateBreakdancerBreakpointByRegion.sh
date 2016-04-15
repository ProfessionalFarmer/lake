#! /bin/bash
annovar="/home/qyy/src/annovar/table_annovar.pl"
db="/home/qyy/src/annovar/humandb/ -buildver hg19"
in=$1
out=$2

cat $in | grep -Ev "^#" | awk -F '\t' '{print $1"\t"$2"\t"$2"\tA\tA\n"$4"\t"$5"\t"$5"\tA\tA"}' > "$in.av.input"
 
perl ${annovar} $in.av.input $db -remove -otherinfo -protocol refGene,cytoBand,tfbsConsSites,phastConsElements46way,wgRna -operation g,r,r,r,r -csvout -nastring . -outfile $out.temp &&  rm "$in.av.input"

grep -v "^#" $out.temp.hg19_multianno.csv | cut -d ',' -f  1-2,6-50 |sed '1s/Start/Breakpoint/' > ${out} && rm $out.temp.hg19_multianno.csv


