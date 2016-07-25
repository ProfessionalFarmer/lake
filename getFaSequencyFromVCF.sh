#! /bin/bash
# $1 vcf $2 reference sequence  $3 output fasta path

gatk='/data/SG/Env/software_installed/GenomeAnalysisTK.jar'

# create dict
# java -jar CreateSequenceDictionary.jar R=./chrM.fa O=./chrM.dict
# samtools faidx chrM.fa 

# extract specific chromosome
# samtools faidx /data/SG/Env/reference_data/ucsc.hg19.fasta chrM

java -jar $gatk -T FastaAlternateReferenceMaker  -R $2 -o $3 -V $1 --lineWidth 50


