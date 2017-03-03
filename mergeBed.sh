#! /bin/bash

bedtools='/home/zhuz/software/bedtools2/bin/bedtools'

cat $1 | sort -k1,1 -k2,2n > bedtools.in.sorted.bed

# -o can be followed by distinct, sum, min, max, absmin, absmax, mean, median, collapse, count_distinct, count
$bedtools merge -i bedtools.in.sorted.bed -c 4 -o distinct


rm bedtools.in.sorted.bed


