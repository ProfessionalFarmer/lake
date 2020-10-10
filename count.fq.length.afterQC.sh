#! /bin/bash
dir=$1
out=$2

# not finished, to be done

ls $1/*fastq.gz | while read id; do
smp=`echo $id | awk -F '/' '{print $NF}'| cut -f 1 -d '.' `

zcat $id | \
  awk '{ if(NR%4==2) print length($0) }' |\
  sort -n | uniq -c | \
  awk '{ OFS="\t";$1=$1;print $2"\t"$1 }' > len.ttt.${smp}.txt


# count totat reads
echo "$id" >&2
echo "total reads: " >&2
awk '{sum+=$2}END{print sum}' len.ttt.${smp}.txt >&2
echo "done" >&2

# limit range

cat len.ttt.${smp}.txt | awk '{if ($1>=18 && $1<=150) print $0}' > len.ttt.${smp}.18-150.txt

done

rm len.ttt*txt



#do less ${id} \
#| awk '{ if(NR%4==2) print length($0) }' \
#| sort -n | uniq -c \
#| awk '{ OFS="\t";$1=$1;print $2"\t"$1 }' > len.${id%.*}.txt; done 



