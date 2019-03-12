#! /bin/bash
# Jason: 20161210

#reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
picard='/src/picard-tools-1.124/picard.jar'
samtools='/src/samtools-1.3.1/samtools'
in=''
out=''

while getopts "o:i:" arg ## arg is option
do
    case $arg in 
        i) 
            in="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            out="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ ! -f "$in" ];then
    echo "Please set a sam file path by -i option"
    exit 1
fi


echo "`date`: Convert sam to bam, mark duplicate"
# Convert to BAM, sort and mark duplicates
# sort and convert
java -Djava.io.tmpdir="`pwd`" -jar $picard SortSam \
    INPUT=${in} \
    OUTPUT=${in}.sorted_reads.bam \
    SORT_ORDER=coordinate \
    TMP_DIR="`pwd`"
# mark dup
java -jar $picard MarkDuplicates \
    INPUT=${in}.sorted_reads.bam \
    OUTPUT=${out} \
    METRICS_FILE=${in}.metrics.txt 

java -jar $picard BuildBamIndex INPUT=$out

rm ${in}.sorted_reads.bam 


