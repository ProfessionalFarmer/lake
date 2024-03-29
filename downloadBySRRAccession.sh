#! /bin/bash

# cat meta.dat.tsv| tail -n +2 | cut -f 1 | sort | uniq > accession.list
# nohup bash ~/software/lake/downloadBySRRAccession.sh -i ./accession.list &

Accessions=""
Threads=8
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

if [ ! -n "$Accessions" ];then
    echo "Must input accesion list by -i option"
    exit 1
fi	


if [ ! -d $OUT ];then
    mkdir $OUT
fi

#conda install parallel-fastq-dump
#conda install -c hcc aspera-cli
#conda install sra-tools


sort -u $Accessions | parallel --lb -j ${Threads} "prefetch --force yes -O ${OUT} {}"

# parallel jobs: 4, -t threads. Total threads 4*threads
sort -u $Accessions | parallel --lb -j 4 "${pfastq} -t ${Threads} --split-3 --gzip --outdir ${OUT}/{} ${OUT}/{}/{}.sra && rm ${OUT}/{}/{}.sra"

# not remove sra file
#sort -u $Accessions | parallel --lb -j 4 "${pfastq} -t ${Threads} --split-3 --gzip --outdir ${OUT}/{} ${OUT}/{}/{}.sra"

