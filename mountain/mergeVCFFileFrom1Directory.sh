#! /bin/bash
# Created by ZZX, 20220514
# CombinedVariants didn't work anymore. This year, MergeVcfs (Picard) was used.

# $1 is dir, $2 is output

echo ""
echo "`date`: Prepare"

vcffile=`ls $1/*.vcf.gz | sed "s#^$1/#$1/#g" | awk '{print " I="$0}'`

#echo "`date`: Start to merge VCF file"
picard MergeVcfs $vcffile O=$2

# bcftools merge file1.vcf.gz fle2.vcf.gz file3.vcf.gz > out.vcf

# #! /bin/bash
# # Created by ZZX, 20160616
# # Modified on:
# 
# GATK='/data/SG/Env/software_installed/GenomeAnalysisTK.jar'
# ref='/data/SG/Env/reference_data/ucsc.hg19.fasta'
# 
# echo ""
# echo "`date`: Prepare"
# #ls $1/*.vcf | awk -F '/' '{split($NF,arr,".");print " \"s/\\tFORMAT\\t.*$/\\tFORMAT\\t"arr[1]"/\"  "$0}' | xargs -L 1 sed -ir 
# vcffile=`ls $1/*.vcf | sed "s#^$1/#$1/#g" | awk '{print " --variant "$0}'`
# 
# echo "`date`: Start to merge VCF file"
# java -jar $GATK -T CombineVariants -R $ref  -o $2 -genotypeMergeOptions UNIQUIFY
# 
