#! /bin/bash
# Jason, 20161210. 20170310: Leftalign and split MNP. 20170322: use vt package to split MNP
#

freebayes='/share/apps/freebayes/bin/freebayes'
reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
reffadict='/home/zhuz/ref/hg19/ucsc.hg19.dict'
picard='/share/apps/picard-tools-1.124/picard.jar'
bwa='/share/apps/bwa.kit/bwa'
#gatk='/share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/share/apps/GenomeAnalysisTK-3.6/GenomeAnalysisTK.jar'
interval='/home/zhuz/ref/trusight_cardio_manifest_a.bed'
splitscript='/home/zhuz/lake/splitMNPsAndComplex.py'
vt='/share/apps/vt/vt'
smp=''
dir=''
STEP='all'
fq1=''
fq2=''

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

##################################################################
if [ $STEP == 2 -o $STEP == 'all' ]; then
# run freebayes
echo "`date`: Call variants"


$freebayes -f $reffa -b ${dir}/${smp}.dedup_reads.bam \
    --targets $interval \
    --strict-vcf \
    --min-mapping-quality 10 \
    --min-base-quality 20 \
    --min-alternate-count 6 \
    > ${dir}/${smp}.unsort.raw.vcf 
#--min-mapping-quality
#--min-base-quality
#--min-alternate-count 


fi

##################################################################


##################################################################
if [ $STEP == 3 -o $STEP == 'all' ]; then
# sort and filter 
echo "`date`: sort and filter vcf file"

# Input VCF(s) to be sorted. Multiple inputs must have the same sample names (in order) Default value: null. This option
java -jar $picard SortVcf \
    I=${dir}/${smp}.unsort.raw.vcf \
    O=${dir}/${smp}.raw.vcf \
    SEQUENCE_DICTIONARY=$reffadict

# must rm old idx file. This can fix error
# MESSAGE: Lexicographically sorted human genome sequence detected in variant.
rm ${dir}/${smp}.raw.vcf.idx

java -jar $gatk \
    -T VariantFiltration \
    -R $reffa \
    --variant ${dir}/${smp}.raw.vcf \
    --filterExpression "DP <= 10 || QUAL <= 20" \
    --filterName "hard_filter" \
    -o ${dir}/${smp}.filter.vcf

java -jar $gatk \
    -T LeftAlignAndTrimVariants \
    -R $reffa \
    --variant ${dir}/${smp}.filter.vcf  \
    -o ${dir}/${smp}.leftalign.vcf

# obsolete when find vt package. use vt package instead. http://genome.sph.umich.edu/wiki/Vt
# cat ${dir}/${smp}.leftalign.vcf | python $splitscript > ${dir}/${smp}.leftalign-split.vcf 
$vt decompose_blocksub ${dir}/${smp}.leftalign.vcf > ${dir}/${smp}.leftalign-split.vcf

java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    --excludeFiltered \
    -V ${dir}/${smp}.leftalign-split.vcf \
    -o ${dir}/${smp}.pass.vcf

fi
###################################################################



