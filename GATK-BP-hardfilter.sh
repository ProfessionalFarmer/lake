#! /bin/bash
# Jason. 20161206
#
# Variant recalibration (VQSR) is the best method we have to filter them but requires: 
# 1) Very well curated known variation resources 
# 2) Sufficient number of variants (typically 1 WGS sample or 30 WEx) 
# Manual filtration is the last ditch solution if you cannot do VQSR 
# 1) No appropriate resources are available: RNAseq, non-model organisms 
# 2) Callset is too small and cohort cannot be padded. 
# REF: http://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set


in=""
out="hardfilter.vcf"

reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
#gatk='/src/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'

while getopts "i:o:" arg ## arg is option
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
    echo "Please set a vcf path by -i option"
    exit 1
fi 



#######################################
# subset variant by indel and snp
echo "`date`: subset variant by indel and snp"
java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    -V $in \
    -selectType SNP \
    -o $out.raw_snps.vcf

java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    -V $in \
    -selectType INDEL \
    -o $out.raw_indels.vcf

# apply hard filter
echo "`date`: start filtering"
# snp filter. Add DP<=6
java -jar $gatk \
    -T VariantFiltration \
    -R $reffa \
    -V $out.raw_snps.vcf \
    --filterExpression "DP <= 6 || QD < 2.0 || FS > 60.0 || MQ < 40.0 || (vc.hasAttribute('MQRankSum') && MQRankSum < -12.5) || (vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -8.0) " \
    --filterName "snp_hard_filter" \
    -o $out.filtered_snps.vcf

# indel filter.
java -jar $gatk \
    -T VariantFiltration \
    -R $reffa \
    -V $out.raw_indels.vcf \
    --filterExpression "DP <= 6 || QD < 2.0 || FS > 200.0 || SOR > 10.0 || (vc.hasAttribute('InbreedigCoeff') && InbreedigCoeff < -0.8) || (vc.hasAttribute('ReadPosRankSum') &&ReadPosRankSum < -20.0) " \
    --filterName "indel_hard_filter" \
    -o $out.filtered_indels.vcf

# merge files and remove
# Input VCF(s) to be sorted. Multiple inputs must have the same sample names (in order) Default value: null. This opti
on may be specified 0 or more times.
java -jar $picard SortVcf \
    I=${dir}/${smp}.filtered_snps.vcf \
    I=${dir}/${smp}.filtered_indels.vcf \
    O=${dir}/${smp}.filter.vcf

#java -jar $gatk \
#    -T CombineVariants \
#    -R $reffa \
#    --variant $out.filtered_snps.vcf \
#    --variant $out.filtered_indels.vcf \
#    --genotypemergeoption REQUIRE_UNIQUE \
#    -o $out

rm $out.filtered_snps.vcf*  $out.filtered_indels.vcf* $out.raw_indels.vcf* $out.raw_snps.vcf*

java -jar $gatk \
    -T SelectVariants \
    -R $reffa \
    --excludeFiltered \
    -V ${dir}/${smp}.filter.vcf \
    -o ${dir}/${smp}.pass.vcf

#########################################


