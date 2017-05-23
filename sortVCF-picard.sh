#! /bin/bash
# Jason, 20161210

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
reffadict='/home/zhuz/ref/hg19/ucsc.hg19.dict'
picard='/share/apps/picard-tools-1.124/picard.jar'
#gatk='/share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'


# sort and filter 
echo "`date`: sort and filter vcf file"

# Input VCF(s) to be sorted. Multiple inputs must have the same sample names (in order) Default value: null. This option
java -jar $picard SortVcf \
    I=$1 \
    O=$2 \
    SEQUENCE_DICTIONARY=$reffadict

# must rm old idx file. This can fix error
# MESSAGE: Lexicographically sorted human genome sequence detected in variant.
rm $2.idx


