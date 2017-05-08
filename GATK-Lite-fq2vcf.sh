#! /bin/bash
# Jason: 20161202, 20170320

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
bwa='/share/apps/bwa.kit/bwa'
picard='/share/apps/picard-tools-1.124/picard.jar'
samtools='/share/apps/samtools-1.3.1/samtools'
bundle_dir='/home/zhuz/ref/gatkbundle/'
interval='/home/zhuz/ref/trusight_cardio_manifest_a.bed'
gatk='/share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
#gatk='/share/apps/GenomeAnalysisTK.jar'
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

if [ ! -d "$dir" ];then
    mkdir $dir
fi
inputdir=${dir}
dir=${dir}/$smp
if [ ! -d "$dir" ];then
    mkdir $dir
fi

export JAVA_HOME=$JAVA7_HOME && export JRE_HOME=$JAVA_HOME/jre && export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH && export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

########################################################################
if [ $STEP == 0 -o $STEP == 'all' ]; then
#http://www.usadellab.org/cms/?page=trimmomatic
echo "`date`: Start trimming"

bash ~/lake/fastq-trimmonmatic.sh -1 $fq1 -2 $fq2 -s $smp -o $dir
# relink fq file
fq1=$dir/$smp.clean.R1.fastq.gz fq2=$dir/$smp.clean.R2.fastq.gz

fi
#########################################################################


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
# sam file is large, remove it
rm ${dir}/${smp}.sam
# mark dup
java -jar $picard MarkDuplicates \
    INPUT=${dir}/${smp}.sorted_reads.bam \
    OUTPUT=${dir}/${smp}.dedup_reads.bam \
    METRICS_FILE=${dir}/${smp}.dedup_reads.bam.metrics.txt
java -jar $picard BuildBamIndex INPUT=${dir}/${smp}.dedup_reads.bam

java -jar $gatk -T CallableLoci -R $reffa \
    -I ${dir}/${smp}.dedup_reads.bam -L $interval -o ${dir}/${smp}.callable_status.bed \
    --minDepth 20 --minMappingQuality 20 --minBaseQuality 20 \
    --summary ${dir}/${smp}.callableloci.summary

cat ${dir}/${smp}.callable_status.bed >> ${dir}/${smp}.callableloci.summary
rm ${dir}/${smp}.callable_status.bed

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
    -L $interval \
    -o ${dir}/${smp}.forIndelRealigner.intervals 
# Perform local realignment of reads around indels
java -jar $gatk \
    -T IndelRealigner \
    -R $reffa \
    -I ${dir}/${smp}.dedup_reads.bam \
    -known ${bundle_dir}/1000G_phase1.indels.hg19.sites.vcf \
    -known ${bundle_dir}/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
    -targetIntervals  ${dir}/${smp}.forIndelRealigner.intervals \
    -L $interval \
    -o ${dir}/${smp}.realignedBam.bam 



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
    -knownSites ${bundle_dir}/1000G_phase1.snps.high_confidence.hg19.sites.vcf \
    -nct 8 \
    -L $interval \
    -o ${dir}/${smp}.recal.table \
    --disable_indel_quals
# Use -L argument with BaseRecalibrator to restrict recalibration to capture targets.
# [-L exome_targets.intervals]

# Creates a new bam file using the input table generated previously which has exquisitely accurate base substitution, insertion, and deletion quality scores
java -jar $gatk \
    -T PrintReads \
    -R $reffa \
    -I ${dir}/${smp}.realignedBam.bam \
    -BQSR ${dir}/${smp}.recal.table \
    -o ${dir}/${smp}.recal.bam \
    -L $interval \
    -nct 8 
fi
###################################################################

###################################################################
if [ $STEP == 3 -o $STEP == 'all' ]; then

# call SNP/INDEL by UnifiedGenotyper
# GATK-Lite does not support HaplotypeCaller
echo "`date`: call variants by UnifiedGenotyper"
java -jar $gatk \
    -T UnifiedGenotyper \
    -R $reffa \
    -nct 8 \
    -I ${dir}/${smp}.recal.bam \
    -o ${dir}/${smp}.raw.vcf \
    -L $interval \
    -D ${bundle_dir}/dbsnp_138.hg19.vcf \
    -glm BOTH 

#    -A StrandBiasBySample -A  

#    --min_mapping_quality_score 20 \
#    --min_base_quality_score 20 \
#    -rf MappingQuality # rf read filter 

# [ -L exome_targets.intervals  \]
# -D or --dbsnp will add rsID in vcf file

# annotation list 
# java -jar /share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar -T VariantAnnotator --list -V variant.vcf -R ~/ref
#   -A StrandAlleleCountsBySample \


fi
###################################################################


###################################################################
if [ $STEP == 4 -o $STEP == 'all' ]; then
# subset variant by indel and snp
echo "`date`: subset variant by indel and snp"
java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    -V ${dir}/${smp}.raw.vcf \
    -selectType SNP \
    -o ${dir}/${smp}.raw_snps.vcf

java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    -V ${dir}/${smp}.raw.vcf \
    -selectType INDEL \
    -o ${dir}/${smp}.raw_indels.vcf

# apply hard filter
echo "`date`: start filtering"
# snp filter. Add DP<=10
# http://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set
# http://gatkforums.broadinstitute.org/gatk/discussion/3225/i-am-unable-to-use-vqsr-recalibration-to-filter-variants
java -jar $gatk \
    -T VariantFiltration \
    -R $reffa \
    -V ${dir}/${smp}.raw_snps.vcf \
    --filterExpression "DP < 20" --filterName "lowDP" --filterExpression "QD < 2.0" --filterName "lowQD" --filterExpression "FS > 60.0" --filterName "highFS" --filterExpression "MQ < 40.0" --filterName "lowMQ"   \
    --filterExpression "(vc.hasAttribute('MQRankSum') && MQRankSum < -12.5)" --filterName "lowMQRankSum"  \
    --filterExpression "(vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -8.0) " --filterName "lowReadPosRankSum"  \
    -o ${dir}/${smp}.filtered_snps.vcf

# indel filter.
java -jar $gatk \
    -T VariantFiltration \
    -R $reffa \
    -V ${dir}/${smp}.raw_indels.vcf \
    --filterExpression "DP < 20" --filterName "lowDP" --filterExpression "QD < 2.0" --filterName "lowQD" --filterExpression "FS > 200" --filterName "highFS" \
    --filterExpression "(vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -20.0) " --filterName "lowReadPosRankSum" \
    -o ${dir}/${smp}.filtered_indels.vcf

# merge files and remove

java -jar $gatk \
    -T CombineVariants \
    -R $reffa \
    --variant ${dir}/${smp}.filtered_snps.vcf \
    --variant ${dir}/${smp}.filtered_indels.vcf \
    --genotypemergeoption UNSORTED \
    -o ${dir}/${smp}.filter.vcf
rm ${dir}/${smp}.filtered_snps.vcf*  ${dir}/${smp}.filtered_indels.vcf* ${dir}/${smp}.raw_indels.vcf* ${dir}/${smp}.raw_snps.vcf*

java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    --excludeFiltered \
    -V ${dir}/${smp}.filter.vcf \
    -o ${dir}/${smp}.pass.vcf

fi


##################################################################


##################################################################
if [ $STEP == 5 -o $STEP == 'all' ]; then
echo "`date`: Start annotation"

bash ~/lake/vep-annotation.sh -i ${dir}/${smp}.pass.vcf -o ${dir}/${smp}.annotation.txt


fi
##################################################################


cp `dirname $0`/$0 ${dir}/${smp}.analysis_script.sh 

