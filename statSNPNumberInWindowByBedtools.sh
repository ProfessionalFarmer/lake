#! /bin/bash
#
# preprocessing
# make windows
# bedtools makewindows -g /data/SG/Env/reference_data/ucsc.hg19.fasta.fai -w 100000  > window.snp.bed
# rm unrelated chr
# sed -i '/_gl0/d' window.snp.bed 
# sed -i '/hap/d' window.snp.bed 
# convert fai file to genome file accpted by bedtools
# sed -i "/Un_g\|_hap\|_random/d" ucsc.hg19.fasta.fai
#

bedtools="/home/zzx/software/bedtools2/bin/bedtools"
# genome chr length file 两列：第一列chr，第二列length
genomeFile="/home/zzx/ref/hg19.genomefile.txt"
# window file generate by bdetools make windows
windowFile="/home/zzx/ref/window.snp.bed"

$bedtools map -a $windowFile -c 4 -g $genomeFile -o count -b $1 -sorted

