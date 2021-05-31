#! /bin/bash



Accessions=""
Threads=5
OUT="./"
# https://github.com/rvalieris/parallel-fastq-dump
pfastq="/data/home2/Zhongxu/software/pfastq-dump/bin/pfastq-dump"


# https://www.ncbi.nlm.nih.gov/Traces/study/?acc=prjna592293&o=acc_s%3Aa


while getopts "i:o:" arg ## arg is option
do
    case $arg in
        i)
            Accessions="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            OUT="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

#conda install parallel-fastq-dump
#conda install -c hcc aspera-cli
#conda install sra-tools

sort -u $Accessions | parallel --lb -j ${Threads} "prefetch --force yes --verify yes -p -O ${OUT} {}"
#sort -u $Accessions | parallel --lb -j ${Threads} "${pfastq} -t ${Threads} --DIR ${OUT}/{}/ --split-3 --gzip ${OUT}/{}/{}.sra "





