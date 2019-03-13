#! /bin/bash

# qsub -cwd -S /bin/bash -l vf=8G,cpu=6 -q all.q -o qsub.out -e qsub.error

for i in `ls $1/Data/Intensities/BaseCalls/*R1_001.fastq.gz`;do
    echo -n "bash ~/lake/pipeline/GATK-Lite-fq2vcf-1.0.1.sh -d $2 "
    echo -n ' -1 '$i' -2 '
    echo -n $i | sed 's/R1_001.fastq.gz/R2_001.fastq.gz/'
    echo -n ' -s '
    echo -n $i | awk -F'/' '{print $NF}' | cut -d '_' -f 1
done




