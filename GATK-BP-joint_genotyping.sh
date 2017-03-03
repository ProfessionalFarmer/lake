#! /bin/bash
# Jason, 20161203

dir=''
out=''
reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
picard='/src/picard-tools-1.124/picard.jar'
samtools='/src/samtools-1.3.1/samtools'
interval='/home/zhuz/ref/trusight_cardio_manifest_a.bed'
#gatk='/src/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'
bundle_dir='/home/zhuz/ref/gatkbundle/'

while getopts "d:o:" arg ## arg is option
do
    case $arg in 
        o) 
            out="$OPTARG" # arguments stored in $OPTARG
            ;;
        d)
            dir="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$dir" ];then
    echo "Please set a output directory by -d option"
    exit 1
fi

if [ ! -d "$dir" ];then
    echo "Please set a directoy path"
fi


gvcf=`ls $dir/*/* | grep 'g.vcf$' | sed "s#^##g" | awk '{printf " -V "$0" "}'`
gvcf="${gvcf}`ls $dir | grep 'g.vcf$' | sed "s#^#$dir/#g" | awk '{printf " -V "$0" "}'`"

java -jar $gatk \
    -T GenotypeGVCFs \
    -R $reffa \
    $gvcf \
    -o $out \
    --dbsnp ${bundle_dir}/dbsnp_138.hg19.vcf
# -D or --dbsnp will add rsID in vcf file





