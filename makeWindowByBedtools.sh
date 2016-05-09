#! /bin/bash
bedtools="/home/zzx/software/bedtools2/bin/bedtools"
fai="/data/SG/Env/reference_data/ucsc.hg19.fasta.fai"

size="100000"
while getopts "s:" arg ## arg is option
do
    case $arg in 
        s) 
            size="$OPTARG" # arguments stored in $OPTARG
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

$bedtools makewindows -g $fai -w $size

