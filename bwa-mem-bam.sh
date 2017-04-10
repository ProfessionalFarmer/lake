#! /bin/bash
# Jason: 20161210. 20170322 from fastq to dedup.sort.bam
# Workflow for fastq read alignment

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
bwa='/share/apps/bwa.kit/bwa'
picard='/share/apps/picard-2.6.0/picard.jar'
#picard='/share/apps/picard-tools-1.124/picard.jar'
smp=''
fq1=''
fq2=''
dir=''
out=''
interval='/home/zhuz/ref/trusight_cardio.interval'
bedinterval='/home/zhuz/ref/trusight_cardio_manifest_a.bed'
gatk='/share/apps/GenomeAnalysisTK-3.6/GenomeAnalysisTK.jar'
#gatk='/share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'

# new gatk and picard require jdk8
export JAVA_HOME=$JAVA8_HOME && export JRE_HOME=$JAVA_HOME/jre && export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH && export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

while getopts "1:2:s:d:o:" arg ## arg is option
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
        d)
            dir="$OPTARG"
	    ;;
	o) 
	    out="$OPTARG"
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

if [ -z "$dir" ];then
    echo "Please set a output directory"
    exit 1
fi

if [ ! -d "$dir" ];then
    mkdir "$dir"
fi

#dir=${dir}/${smp}/
#if [ ! -d "$dir" ];then
#    mkdir $dir
#fi

# build bwa fasta index 
#$bwa index $reffa

# https://software.broadinstitute.org/gatk/documentation/article?id=2799
# Generate a SAM file containing aligned reads
# The -M flag causes BWA to mark shorter split hits as secondary (essential for Picard compatibility).

echo "`date`: Start BWA"
$bwa mem -M -t 8 \
    -R "@RG\tID:$smp\tSM:$smp\tLB:$smp\tPL:ILLUMINA" \
    $reffa $fq1 $fq2 > ${dir}/${smp}.sam

# Convert to BAM, sort and mark duplicates
# sort and convert
java -jar $picard SortSam \
    INPUT=${dir}/${smp}.sam \
    OUTPUT=${dir}/${smp}.sorted_reads.bam \
    SORT_ORDER=coordinate
# mark dup
java -jar $picard MarkDuplicates \
    INPUT=${dir}/${smp}.sorted_reads.bam \
    OUTPUT=${dir}/${smp}.dedup_reads.bam \
    METRICS_FILE=${dir}/${smp}.dedup_reads.bam.metrics.txt

statfile=${dir}/${smp}.stat.txt

java -jar $picard BuildBamIndex INPUT=${dir}/${smp}.dedup_reads.bam

java -jar $picard CollectHsMetrics \
    I=${dir}/${smp}.dedup_reads.bam O=${dir}/${smp}.dedup_reads.bam.hs_metrics.txt \
    R=$reffa BAIT_INTERVALS=${interval} TARGET_INTERVALS=${interval}

java -jar $gatk -T CallableLoci -R $reffa \
    -I ${dir}/${smp}.dedup_reads.bam -L $bedinterval -o ${dir}/${smp}.callable_status.bed \
    --minDepth 20 --minMappingQuality 20 --minBaseQuality 20 \
    --summary ${dir}/${smp}.callableloci.summary

cat ${dir}/${smp}.callable_status.bed >> ${dir}/${smp}.callableloci.summary
rm ${dir}/${smp}.callable_status.bed



#echo `date`> $statfile
#sed -n '6,9p'  ${dir}/${smp}.dedup_reads.bam.metrics.txt >> $statfile
#sed -n '6,9p'  ${dir}/${smp}.dedup_reads.bam.hs_metrics.txt >> $statfile 

if [ ! -z "$out" ];then
    mv ${dir}/${smp}.dedup_reads.bam $out
fi



# calculate duplication  awk '{a=$3*2+$2+a;b=$6+$7*2+b;}END{print b/a}'
# calculate mapped ratio awk '{a=$3*2+$2+a;b=$5+b;}END{print 1-b/a}'



