#! /bin/bash
# Jason, 20161212

#gatk='/src/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
gatk='/src/GenomeAnalysisTK.jar'
reffa='/home/zhuz/ref/hg19/ucsc.hg19.fasta'

# This tool takes in two callsets (vcfs) and tabulates the number of sites which overlap and share alleles, and for each sample, the genotype-by-genotype counts (e.g. the number of sites at which a sample was called homozygous-reference in the EVAL callset, but homozygous-variant in the COMP callset). It outputs these counts as well as convenient proportions (such as the proportion of het calls in the EVAL which were called REF in the COMP) and metrics (such as NRD and NRS).

evaluatateFile=''
outFile=''
# bechmark/golden standard set
compareFile=''

# pls make sure the sampel name in vcf file are the same.
#  bash -e .vcf -c .vcf -o out
while getopts "e:c:o:" arg ## arg is option
do
    case $arg in 
        e) 
            evaluatateFile="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            outFile="$OPTARG"
            ;;
        c)
            compareFile="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done


if [[ -z "$evaluatateFile" || -z "$compareFile" ]];then
    echo "set evaluate file by -e option and set compare file by -c option"
    exit 1
fi

java -jar $gatk \
    -T GenotypeConcordance \
    -R $reffa \
    -eval $evaluatateFile \
    -comp $compareFile \
    --moltenize \
    -o temp.gatk.genotypeconcordance.txt \
    --printInterestingSites temp.gatk.genotypeconcordance.interstingsite.txt

if [ -z "$outFile" ];then
    cat temp.gatk.genotypeconcordance.txt temp.gatk.genotypeconcordance.interstingsite.txt
    rm  temp.gatk.genotypeconcordance.txt temp.gatk.genotypeconcordance.interstingsite.txt
else
    mv temp.gatk.genotypeconcordance.txt $outFile
    cat temp.gatk.genotypeconcordance.interstingsite.txt  >> $outFile
    rm  temp.gatk.genotypeconcordance.interstingsite.txt
fi



