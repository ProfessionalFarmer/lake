#! /bin/bash

# conda install -c bioconda rseqc  # infer_experiment.py
# conda install -c bioconda bedops # gff2bed


BAM=""
GENOME="hg38"

while getopts "g:i:" arg ## arg is option
do
    case $arg in
        i)
            BAM="$OPTARG"  # overwrite default GTF
            ;;
        g)
            GENOME="$OPTARG"  # run STAR
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z $BAM ];then
    echo "Pls specify -i option"
    exit 1
fi

if [ $GENOME == "hg38" ];then
  GFF="http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gff3.gz"
elif [ $GENOME == "hg19" ];then
  GFF=""
else
  echo "Pls specify a genome version: hg19, hg38"
  exit 1
fi

BED="./gencode.bed"

if [ ! -f $BED ];then
  wget -qO- $GFF | gunzip -c - | gff2bed --max-mem 20G - > gencode.bed 
fi

# http://rseqc.sourceforge.net/#infer-experiment-py
## For pair-end RNA-seq, there are two different ways to strand reads (such as Illumina ScriptSeq protocol):
#
#1++,1–,2+-,2-+
#
#read1 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#
#read1 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#
#read2 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#
#read2 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
#
#1+-,1-+,2++,2–
#
#read1 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#
#read1 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
#
#read2 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#
#read2 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand

infer_experiment.py -r $BED -i $BAM -s 2000000 -q 30 



