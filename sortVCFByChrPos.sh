#! /bin/bash
# Create by Jason Zhu, on: 2016-02-29, 2016-03-01 
# Modify on:
# $1 is input file. Result wil print by stdout

chr_order="chrM\nchr1\nchr2\nchr3\nchr4\nchr5\nchr6\nchr7\nchr8\nchr9\nchr10\nchr11\nchr12\nchr13\nchr14\nchr15\nchr16\nchr17\nchr18\nchr19\nchr20\nchr21\nchr22\nchrX\nchrY"

#cat "$1" | grep "^#" > .pre.sorted.vcf
#cat "$1" | grep -v "^#" | sort -k1,1 -k2,2n  >> .pre.sorted.vcf
#bgzip -c .pre.sorted.vcf > .pre.sorted.vcf.gz
#tabix -f -p vcf .pre.sorted.vcf.gz
#tabix -H .pre.sorted.vcf.gz > .sort.vcf
#echo -e $chr_order | xargs tabix -h .pre.sorted.vcf.gz >> .sort.vcf
#cat .sort.vcf && rm .pre.sorted.vcf.gz .pre.sorted.vcf .sort.vcf

## another way to sort
cat "$1" | grep "^#" > .header.vcf
cat "$1" | grep -v "^#" | sort -k1,1 -k2,2n > .pre.sorted.vcf
echo -e $chr_order | while read line
do
    cat .pre.sorted.vcf | grep "^$line"$'\t' >> .header.vcf
done

cat .header.vcf && rm .header.vcf .pre.sorted.vcf

