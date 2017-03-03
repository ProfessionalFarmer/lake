#! /bin/bash
# Jason, 20161219

#gatk='/src/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'
reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'

# A very common question about a NGS set of reads is what areas of the genome are considered callable. This tool considers the coverage at each locus and emits either a per base state or a summary interval BED file that partitions the genomic intervals into the following callable states

bam=''
interval=''

#  bash -b .bam [ -l interval.bed ] 
#  to stdout
while getopts "b:l:" arg ## arg is option
do
    case $arg in 
        b) 
            bam="$OPTARG" # arguments stored in $OPTARG
            ;;
        l)
            interval="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done


if [ -z "$bam" ];then
    echo "set a bam file by -b option"
    exit 1
fi

tmp=$bam

if [ ! -z "$interval" ];then
    bam="${bam} -L $interval "
fi

java -jar $gatk \
    -T CallableLoci \
    -R $reffa \
    -I $bam\
    --minDepth 20 \
    --minMappingQuality 20 \
    --minBaseQuality    20 \
    --summary $tmp.tmp.summary
cat $tmp.tmp.summary 
echo '#########################' 
rm $tmp.tmp.summary 


