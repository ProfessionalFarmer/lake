#! /bin/bash
# $1 bam directory  $2 output file path
# Create on: 20160429

picard_mergesam="/data/SG/Env/software_installed/picard-tools-1.119/MergeSamFiles.jar"

bamfile=" "
echo "`date`:Merge BAM from $1"
bamfile=`ls $1/* | sed "s#^$1/#$1/#g" | awk '{print " INPUT="$0}'`
bamfile=`echo $bamfile`
java -jar $picard_mergesam USE_THREADING=true ${bamfile} OUTPUT=$2
echo "`date`: Finish merge BAM, output path -- $2"


