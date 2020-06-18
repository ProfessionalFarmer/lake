#! /bin/bash
# last parameter is output vcf.gz path. The first severals are files to merge


out=`echo $@ | awk -F ' ' '{print $NF}'`
n=`echo $@ | awk -F ' ' '{for(i=1;i<NF;i++){print "-V "$i" "}}' | tr -d '\n' | cut -f 1 -d '%'`
ref='/data/home2/Zhongxu/ref/hg38/Homo_sapiens_assembly38.fasta'
interval='/data/home2/Zhongxu/ref/agilent/hg38v7/S31285117_Regions.bed'
tmp=$RANDOM
af='/data/home2/Zhongxu/ref/hg38/af-only-gnomad.hg38.vcf.gz'

# Create a GenomicsDB from the normal Mutect2 calls
gatk GenomicsDBImport -R $ref -L $interval \
    --merge-input-intervals --genomicsdb-workspace-path ${tmp}pon_db $n
# https://gatkforums.broadinstitute.org/gatk/discussion/24057/how-to-call-somatic-mutations-using-gatk4-mutect2#latest
gatk CreateSomaticPanelOfNormals -R $ref \
  -V gendb://${tmp}pon_db \
  -O $out

#  --germline-resource $af \

# gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz
# gs://gatk-best-practices/somatic-b37/Mutect2-exome-panel.vcf


rm -rf ${tmp}pon_db
