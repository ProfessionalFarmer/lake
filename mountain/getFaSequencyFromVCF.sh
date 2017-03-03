#! /bin/bash
# $1 vcf $2 reference sequence  $3 output fasta path
# https://software.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_fasta_FastaAlternateReferenceMaker.php
#If there are multiple variants that start at a site, it chooses one of them randomly.
#When there are overlapping indels (but with different start positions) only the first will be chosen.
#This tool works only for SNPs and for simple indels (but not for things like complex substitutions).


gatk='/data/SG/Env/software_installed/GenomeAnalysisTK.jar'

# create dict
# java -jar CreateSequenceDictionary.jar R=./chrM.fa O=./chrM.dict
# samtools faidx chrM.fa 

# extract specific chromosome
# samtools faidx /data/SG/Env/reference_data/ucsc.hg19.fasta chrM

java -jar  ${gatk}  -T FastaAlternateReferenceMaker -R $2 -o $3 -V $1 --lineWidth 50


