#! /bin/bash
# Jason: 20170521

smplist=''
outputdir=''
bed='/share/apps/DECoN/DECoN-1.0.1/Linux/trusight_cardio_manifest_a.bed'
fa='/share/apps/reference/hg19/ucsc.hg19.fasta'
batch=''

while getopts "s:b:o:" arg ## arg is option
do
    case $arg in 
        s) 
            smplist="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            outputdir="$OPTARG"
            ;;
        b)
            batch="$OPTARG"
            ;;
        ?)
            echo "unkonw argument. bash sh -o outputdir -s smplist -b batchnunber"
            exit 1
        esac
done

# check options
if [ -z "batch" ];then
    echo "Please set batch number by -b option"
    exit 1
fi

if [ -z "$outputdir" ];then
    echo "Please set a output directory by -o option"
    exit 1
fi

if [ -z "$smplist" ];then
    echo "Please set a sample list by -s option"
    exit 1
fi

cd '/share/apps/DECoN/DECoN-1.0.1/Linux'

echo "`date`: Start call CNV"
Rscript ReadInBams.R --bams smp.list --be $bed  --fasta $fa --out $outputdir/$batch   

#Running quality checks
#--exons customNumbers.file 
Rscript IdentifyFailures.R --Rdata $outputdir/${batch}.RData  --mincorr .98 --mincov 100 --custom FALSE --out $outputdir/${batch}.qc 

#Calling exon CNVs
#--exons customNumbers.file
#The default value is set to 0.01, a high threshold value to increase sensitivity.
Rscript makeCNVcalls.R --Rdata $outputdir/${batch}.RData --transProb 0.01  --custom FALSE --out $outputdir/${batch}.call --plot All --plotFolder $outputdir/ 
echo "`date`: End call CNV"


