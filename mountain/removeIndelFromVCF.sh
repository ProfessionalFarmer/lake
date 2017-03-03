#! /bin/bash
#$1 input vcf, $2 output vcf


vcftools --vcf $1 --remove-indels --recode --recode-INFO-all --out SNPs_only
if [ -z $2];then
   cat SNPs_only.recode.vcf && rm SNPs_only.recode.vcf
else
    mv SNPs_only.recode.vcf $2
fi

rm SNPs_only.log

