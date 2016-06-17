#! /bin/bash
# Created by ZZX, 20160616
# Modified on:

GATK='/data/SG/Env/software_installed/GenomeAnalysisTK.jar'
ref='/data/SG/Env/reference_data/ucsc.hg19.fasta'

echo ""
echo "`date`: Prepare"
#ls $1/*.vcf | awk -F '/' '{split($NF,arr,".");print " \"s/\\tFORMAT\\t.*$/\\tFORMAT\\t"arr[1]"/\"  "$0}' | xargs -L 1 sed -ir 
vcffile=`ls $1/*.vcf | sed "s#^$1/#$1/#g" | awk '{print " --variant "$0}'`

echo "`date`: Start to merge VCF file"
java -jar $GATK -T CombineVariants -R $ref  -o $2 -genotypeMergeOptions UNIQUIFY

