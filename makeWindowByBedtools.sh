#! /bin/bash
bedtools="/home/zzx/software/bedtools2/bin/bedtools"
fai="/data/SG/Env/reference_data/ucsc.hg19.fasta.fai"

$bedtools makewindows -g $fai -w 2000000

