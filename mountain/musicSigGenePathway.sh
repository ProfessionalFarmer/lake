#! /bin/bash
# Author: ZZX
# Create on: 20160914

bamList=''

ref='ucsc.hg19.fasta'
# can download from https://github.com/ding-lab/calc-roi-covg/tree/master/data or create by yourself
roi='ensembl_67_cds_ncrna_and_splice_sites_hg19'
outDir=''

# https://www.biostars.org/p/77547/  https://github.com/ding-lab/parse-kegg/tree/master/all_pathway_files
pathwayFile='KEGG_120910'

mafFile=''


# more option should be added
while getopts "b:o:m:" arg ## arg is option
do
    case $arg in 
        b) 
            bamList="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            outDir="$OPTARG"
            ;;
        m)  
            mafFile="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$bamList" ] || [ -z "$mafFile" ] || [ -z "$outDir" ];then
    echo -e '-b option for bam.list\n-m option for merged.maf\n-o option for output directory'
    exit 1
fi


genome music bmr calc-covg \
   --bam-list $bamList \
   --output-dir $outDir \
   --reference-sequence $ref \
   --roi-file $roi

genome music bmr calc-bmr \
   --bam-list $bamList \
   --maf-file $mafFile \
   --output-dir $outDir \
   --reference-sequence $ref \
   --roi-fil $roi

genome music smg --gene-mr-file $outDir/gene_mrs --output-file $outDir/smgs

genome music path-scan \
   --bam-list $bamList \
   --gene-covg-dir $outDir/gene_covgs/ \
   --maf-file $mafFile \
   --output-file $outDir/sm_pathways \
   --pathway-file  $pathwayFile \
   --bmr 8.7E-07

 



