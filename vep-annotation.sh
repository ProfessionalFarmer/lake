#! /bin/bash
# ref: http://asia.ensembl.org/info/docs/tools/vep/script/vep_options.html

vep='/share/apps/bin/variant_effect_predictor.pl'
cache='/share/apps/ensembl-tools-release-87/vepcache/'
fasta='/home/zhuz/ref/hg19/ucsc.hg19.fasta'
in=''
out=''

while getopts "i:o:" arg ## arg is option
do
    case $arg in 
        i) 
            in="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            out="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

perl $vep --input_file $in --output_file $out --tab --force_overwrite \
    --everything --fork 8 \
    --dir_cache $cache --cache_version 87 --fasta $fasta \
    --offline --refseq --species homo_sapiens \
    --domains --numbers --allele_number --gene_phenotype 






