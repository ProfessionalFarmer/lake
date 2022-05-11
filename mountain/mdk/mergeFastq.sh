#! /bin/bash
# Author: Jason, 2018-07-09
#

smp=''
inputDir=''
outputDir=''
while getopts "i:s:o:" arg ## arg is option
do
    case $arg in 
        i) 
            inputDir="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            outputDir="$OPTARG"
            ;;
        s)
            smp="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ ! -d $outputDir ];then
    mkdir -p $outputDir
fi



rm $outputDir/$smp.R1.fastq.gz
rm $outputDir/$smp.R2.fastq.gz
for i in `ls $inputDir/$smp*R1_001.fastq.gz`;do
    fq1=$i
    fq2=`echo -n $i | sed 's/R1_001.fastq.gz/R2_001.fastq.gz/'`
    echo $fq1
    cat $fq1 >> $outputDir/$smp.R1.fastq.gz
    echo $fq2
    cat $fq2 >> $outputDir/$smp.R2.fastq.gz

done



