#! /bin/bash

dir=$1
smp=$2

# print sample name
echo -n -e $smp"\t"

# print fastq stats
echo -n -e "`sed -n '2p' $dir/$2.fastq_stat.txt | sed "s# #\t#g"`""\t"
echo -n -e "`sed -n '5p' $dir/$2.fastq_stat.txt | sed "s# #\t#g"`""\t"

# print qc ratio
echo -n -e "`sed -n '2p;5p' $dir/$2.fastq_stat.txt | awk -F'\t' '{reads[NR]=$2;bases[NR]=$3}END{printf ("%.2f\t%.2f"),reads[2]/reads[1]*100,bases[2]/bases[1]*100}'`""\t"

# print align ratio
echo -n -e "`sed -n '8p' $dir/$smp.dedup_reads.bam.metrics.txt | awk '{a=$3*2+$2;b=$5;}END{printf ("%.2f"),(1-b/a)*100}'`""\t"

# print duplication ratio
echo -n -e "`sed -n '8p' $dir/$smp.dedup_reads.bam.metrics.txt | awk '{a=$3*2+$2;b=$6+$7*2;}END{printf ("%.2f"),b/a*100}'`""\t"

# print variant count
# total
echo -n -e "`/share/apps/bin/bcftools stats $dir/$smp*.pass.vcf | grep '^SN' | grep 'number of records' | cut -f 4`""\t"
# snp count
echo -n -e "`/share/apps/bin/bcftools stats $dir/$smp*.pass.vcf | grep '^SN' | grep 'number of SNPs'   | cut -f 4`""\t"
# indels count
echo -n -e "`/share/apps/bin/bcftools stats $dir/$smp*.pass.vcf | grep '^SN' | grep 'number of indels' | cut -f 4`""\t"

# print callable ratio
sed -n '3,7p' $dir/$smp.callableloci.summary | awk '{a[NR]=$2;b=$2+b}END{printf("%.2f"),a[1]/b*100}'



