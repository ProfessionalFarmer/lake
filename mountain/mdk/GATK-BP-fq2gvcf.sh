#! /bin/bash
# Jason: 20161202

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
bwa='/src/bwa.kit/bwa'
picard='/src/picard-tools-1.124/picard.jar'
samtools='/src/samtools-1.3.1/samtools'
bundle_dir='/home/zhuz/ref/gatkbundle/'
interval='/home/zhuz/ref/trusight_cardio_manifest_a.bed'
#gatk='/src/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'
smp=''
fq1=''
fq2=''
dir=''
STEP='all'


while getopts "1:2:s:d:p:" arg ## arg is option
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
	p)  
	    STEP="$OPTARG"
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
    echo "Please set a output directory by -d option"
    exit 1
fi
dir=${dir}/$smp
if [ ! -d "$dir" ];then
    mkdir $dir
fi

if [ ! -d "$dir" ];then
    mkdir "$dir"
fi

# build bwa fasta index 
#$bwa index $reffa

#######################################################################
if [ $STEP == 1 -o $STEP == 'all' ]; then

# https://software.broadinstitute.org/gatk/documentation/article?id=2799
# Generate a SAM file containing aligned reads
# The -M flag causes BWA to mark shorter split hits as secondary (essential for Picard compatibility).

echo "`date`: Start BWA"
$bwa mem -M -t 8 \
    -R "@RG\tID:$smp\tSM:$smp\tLB:$smp\tPL:ILLUMINA" \
    $reffa $fq1 $fq2 > ${dir}/${smp}.sam

echo "`date`: Convert sam to bam, mark duplicate"
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
    METRICS_FILE=${dir}/${smp}.metrics.txt
java -jar $picard BuildBamIndex INPUT=${dir}/${smp}.dedup_reads.bam

fi
###################################################################




###################################################################
if [ $STEP == 2 -o $STEP == 'all' ]; then

# indel realignment
# Define intervals to target for local realignment
echo "`date`: Indel realignment"
java -jar $gatk \
    -T RealignerTargetCreator \
    -R $reffa \
    -I ${dir}/${smp}.dedup_reads.bam \
    --known ${bundle_dir}/1000G_phase1.indels.hg19.sites.vcf \
    --known ${bundle_dir}/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
    -o ${dir}/${smp}.forIndelRealigner.intervals \
    -L $interval
# Perform local realignment of reads around indels
java -jar $gatk \
    -T IndelRealigner \
    -R $reffa \
    -I ${dir}/${smp}.dedup_reads.bam \
    -known ${bundle_dir}/1000G_phase1.indels.hg19.sites.vcf \
    -known ${bundle_dir}/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
    -targetIntervals  ${dir}/${smp}.forIndelRealigner.intervals \
    -o ${dir}/${smp}.realignedBam.bam \
    -L $interval


# Base Quality Score Recalibration, produces the recalibration table
# Builds recalibration model
# Detect systematic errors in base quality scores
echo "`date`: Base Quality Score Recalibration"
# -nct: This tool can be run in multi-threaded mode using this option.
# GATK Lite does not support all of the features of the full version: base insertion/deletion recalibration is not supported, please use the --disable_indel_quals argument
java -jar $gatk \
    -T BaseRecalibrator \
    -R $reffa \
    -I ${dir}/${smp}.realignedBam.bam \
    -knownSites ${bundle_dir}/dbsnp_138.hg19.vcf \
    -knownSites ${bundle_dir}/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
    -nct 8 \
    -o ${dir}/${smp}.recal.table \
    -L $interval
# Use -L argument with BaseRecalibrator to restrict recalibration to capture targets.
# [-L exome_targets.intervals]

# Creates a new bam file using the input table generated previously which has exquisitely accurate base substitution, insertion, and deletion quality scores
java -jar $gatk \
    -T PrintReads \
    -R $reffa \
    -I ${dir}/${smp}.realignedBam.bam \
    -BQSR ${dir}/${smp}.recal.table \
    -o ${dir}/${smp}.recal.bam \
    -nct 8 \
    -L $interval
fi
###################################################################





###################################################################
if [ $STEP == 3 -o $STEP == 'all' ]; then

# Variant calling --- gVCF format, futher used for joint genotyping
# Call variants per sample using HaplotypeCaller
echo "`date`: call gVCF file by HaplotypeCaller"
java -jar $gatk \
    -T HaplotypeCaller \
    -R $reffa \
    -I ${dir}/${smp}.recal.bam \
    -o ${dir}/${smp}.g.vcf \
    -ERC GVCF \
    -L $interval
# [ -L exome_targets.intervals	\]
# -D or --dbsnp will add rsID in vcf file

fi
###################################################################


