#! /bin/bash
smp=$1
fq1=$2
fq2=$3
ref='/share/apps/reference/hs38DH/hs38DH.fa'
dir=$4/$1
mkdir $dir
#dir='/home/zhuz/tmp/20180619-cancer/umiresult/'

echo "`date`: fastq to sam"
java -Xmx8G -jar /share/apps/picard-2.6.0/picard.jar FastqToSam \
    FASTQ=$fq1 \
    FASTQ2=$fq2  \
    OUTPUT=$dir/$smp.ubam \
    READ_GROUP_NAME=$smp \
    SAMPLE_NAME=$smp \
    LIBRARY_NAME=$smp \
    PLATFORM_UNIT=HiseqX10 \
    PLATFORM=illumina \
    SEQUENCING_CENTER=MDK \
    RUN_DATE=`date --iso-8601=seconds` 

echo "`date`: add RX tag into ubam"
#python ~/lake/moveUMI2RXTag.py -i $dir/$smp.ubam  -o $dir/$smp.umi.ubam -1 2M149T -2 2M149T
java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar ExtractUmisFromBam \
    --input=$dir/$smp.ubam --output=$dir/$smp.umi.ubam \
    --read-structure=2M148T 2M148T --single-tag=RX --molecular-index-tags=ZA ZB


echo "`date`: align"
# SamToFastq
samtools fastq  $dir/$smp.umi.ubam | /share/apps/bwa.kit/bwa mem -t 7 -p $ref /dev/stdin | samtools view -b > $dir/$smp.umi.bam


echo "`date`: Merge bam file"
# Restore altered data and apply & adjust meta information using MergeBamAlignment
# https://software.broadinstitute.org/gatk/documentation/article.php?id=6483
# MergeBamAlignment will merge the output of bwa back into the unmapped BAM so you don't lose any read attributes like the RX tag.
java -Xmx8G -jar /share/apps/picard-2.6.0/picard.jar MergeBamAlignment R=$ref \
    UNMAPPED_BAM=$dir/$smp.umi.ubam  \
    ALIGNED_BAM=$dir/$smp.umi.bam \
    O=$dir/$smp.mergebamalignment.bam  \
    CREATE_INDEX=true    \
    MAX_GAPS=-1 ALIGNER_PROPER_PAIR_FLAGS=true VALIDATION_STRINGENCY=SILENT \
    SO=coordinate ATTRIBUTES_TO_RETAIN=XS  


echo "`date`: group by UMI"
#  group them by UMI 
java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar GroupReadsByUmi \
    --input=$dir/$smp.mergebamalignment.bam \
    --output=$dir/$smp.mergebamalignment.umigroup.bam  \
    --strategy=paired  --min-map-q=20  --edits=1 --raw-tag=RX

echo "`date`: Call consensus reads"
# Call consensus reads
#--error-rate-pre-umi=45 --error-rate-post-umi=30 --min-input-base-quality=30 \
#
java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar  CallMolecularConsensusReads \
    --min-reads=1 \
    --input=$dir/$smp.mergebamalignment.umigroup.bam \
    --output=$dir/$smp.callconsensus.bam


#java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar  CallDuplexConsensusReads \
#    --error-rate-pre-umi=45 --error-rate-post-umi=30 --min-input-base-quality=20 \
#    --input=$dir/$smp.mergebamalignment.umigroup.bam \
#    --output=$dir/$smp.callconsensus.bam


samtools fastq $dir/$smp.callconsensus.bam | bwa mem -t 7 -p $ref /dev/stdin | samtools view -b - |
samtools sort -T $smp.tmp -o $dir/$smp.callconsensus.sort.bam

java -Xmx8G -jar /share/apps/picard-2.6.0/picard.jar MergeBamAlignment R=$ref \
    UNMAPPED_BAM=$dir/$smp.callconsensus.bam  \
    ALIGNED_BAM=$dir/$smp.callconsensus.sort.bam \
    O=$dir/$smp.callconsensus.sort.mergebamalignment.bam  \
    CREATE_INDEX=true   \
    MAX_GAPS=-1 ALIGNER_PROPER_PAIR_FLAGS=true VALIDATION_STRINGENCY=SILENT \
    SO=coordinate ATTRIBUTES_TO_RETAIN=XS


echo "`date`: Filter consensus reads"
java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar FilterConsensusReads --input=$dir/$smp.callconsensus.sort.mergebamalignment.bam --output=$dir/$smp.callconsensus.filter.bam \
    --ref=$ref --min-reads=1 --max-read-error-rate=0.1 --max-base-error-rate=0.2 \
    --min-base-quality=20 --max-no-call-fraction=0.40

echo "`date`: Clip bam file"
# clip bam
java -jar /home/zhuz/tmp/20180619-cancer/fgbio/target/scala-2.12/fgbio-0.7.0-3f90c87-SNAPSHOT.jar ClipBam \
    --input=$dir/$smp.callconsensus.filter.bam   \
    --output=$dir/$smp.callconsensus.sort.mergebamalignment.filter.clip.bam \
    --ref=$ref  --soft-clip=false --clip-overlapping-reads=true

echo "`date`: Calling"
# minimum allele frequency
AF_THR="0.0005" 
/home/zhuz/tmp/20180619-cancer/VarDictJava/build/install/VarDict/bin/VarDict -G $ref \
    -f $AF_THR \
    -N $smp \
    -b $dir/$smp.callconsensus.sort.mergebamalignment.filter.clip.bam \
    -z -c 1 -S 2 -E 3 -g 4 -th 4 \
    /home/zhuz/tmp/20180619-cancer/cancer_precision_drug20180125.hg38.bed | \
    /home/zhuz/tmp/20180619-cancer/VarDictJava/VarDict/teststrandbias.R | \
    /home/zhuz/tmp/20180619-cancer/VarDictJava/VarDict/var2vcf_valid.pl -N $smp -E -f $AF_THR > $dir/$smp.raw.vcf 


