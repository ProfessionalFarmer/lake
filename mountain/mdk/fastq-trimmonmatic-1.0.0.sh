#! /bin/bash

trimmonmatic='/share/apps/Trimmomatic-0.36/trimmomatic-0.36.jar'
adapter='/share/apps/Trimmomatic-0.36/adapters/NexteraPE-PE.fa'
fq1=''
fq2=''
smp=''
out=''
fqcheck='/home/zhuz/lake/mountain/check_fastq.py'


while getopts "1:2:s:o:" arg ## arg is option
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

if [ -z "$out" ];then
    echo "Please set a output directory by -o option"
    exit 1
fi

if [ -z "$smp" ];then
    echo "Please set a sample name by -o option"
    exit 1
fi

if [ ! -d "$out" ];then
    mkdir "$out"
fi


gunzip -c $fq1 $fq2 | python $fqcheck > $out/$smp.fastq_stat.txt

java -jar $trimmonmatic PE -threads 8 \
    $fq1 $fq2 \
    $out/$smp.clean.R1.fastq.gz $out/$smp.unpaired_R1.fastq.gz \
    $out/$smp.clean.R2.fastq.gz $out/$smp.unpaired_R2.fastq.gz \
    ILLUMINACLIP:$adapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

gunzip -c $out/$smp.clean.R1.fastq.gz $out/$smp.clean.R2.fastq.gz | python $fqcheck  >> $out/$smp.fastq_stat.txt

rm $out/$smp.unpaired_R1.fastq.gz $out/$smp.unpaired_R2.fastq.gz



