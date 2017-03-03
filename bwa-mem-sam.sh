#! /bin/bash
# Jason: 20161210
# Output to stdout, should redirect.

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
bwa='/src/bwa.kit/bwa'
smp=''
fq1=''
fq2=''

while getopts "1:2:s:" arg ## arg is option
do
    case $arg in 
        1) 
            fq1="$OPTARG" # arguments stored in $OPTARG
            ;;
        2)
            fq2="$OPTARG"
            ;;
        s)
            smp="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

# check options
if [[ ! -f "$fq1" || ! -f "$fq2" ]];then
    echo "Please set fastq input by -1 and -2 option"
    exit 1
fi

if [ -z "$smp" ];then
    echo "Please set a sample name by -s option"
    exit 1
fi

# build bwa fasta index 
#$bwa index $reffa

# https://software.broadinstitute.org/gatk/documentation/article?id=2799
# Generate a SAM file containing aligned reads
# The -M flag causes BWA to mark shorter split hits as secondary (essential for Picard compatibility).

echo "`date`: Start BWA"
$bwa mem -M -t 8 \
    -R "@RG\tID:$smp\tSM:$smp\tLB:$smp\tPL:ILLUMINA" \
    $reffa $fq1 $fq2 



