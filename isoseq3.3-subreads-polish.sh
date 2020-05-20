#! /bin/bash


rawdata=""
smp=""
outdir=""
fq1=""
fq2=""


while getopts "r:s:o:1:2" arg ## arg is option
do
    case $arg in
        r)
            rawdata="$OPTARG" # arguments stored in $OPTARG
            ;;
        s)
            smp="$OPTARG"
            ;;
        o)
            outdir="$OPTARG"
            ;;
        1)
            fq1="$OPTARG"
            ;;
        2)
            fq2="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

# check options
if [[ ! -f "$rawdata" ]];then
    echo "Please set subreads.bam by -r option"
    exit 1
fi

if [ -z "$outdir" ];then
    echo "Please set a output directory by -o option"
    exit 1
fi


source activate isoseq3

echo "`date`: $smp - CCS"
ccs --min-rq 0.9 --num-threads 30 \
    --minPasses 2 --min-length 50 --maxDropFraction 0.5  --reportFile ${outdir}/${smp}.ccs_report.txt \
    $rawdata \
    ${outdir}/${smp}.ccs.bam 



echo ">primer_5p
AAGCAGTGGTATCAACGCAGAGTACATGGGG
>primer_3p
AAGCAGTGGTATCAACGCAGAGTAC" >  ${outdir}/${smp}.barcoded_primers.fasta


echo "`date`: $smp - LIMA"
## lima Primer removal and demultiplexing # 先不加 --require-polya  --min-polya-length 20
lima --isoseq --peek-guess --num-threads 40 \
    ${outdir}/${smp}.ccs.bam \
    ${outdir}/${smp}.barcoded_primers.fasta \
    ${outdir}/${smp}.fl.bam 


echo "`date`: $smp - Refine"
##  refine Trimming of poly(A) tails    Rapid concatemer identification and removal
## output is FLNC  --require-polya # 考虑好是否要require polya 
isoseq3 refine --num-threads 40  \
    ${outdir}/${smp}.fl.primer_5p--primer_3p.bam \
    ${outdir}/${smp}.barcoded_primers.fasta \
    ${outdir}/${smp}.flnc.bam 


echo "`date`: $smp - Cluster"
## cluster
isoseq3 cluster --verbose --use-qvs \
    ${outdir}/${smp}.flnc.bam \
    ${outdir}/${smp}.clustered.bam 
    

echo "`date`: $smp - Polish"
## polish
isoseq3 polish -j 40 ${outdir}/${smp}.clustered.bam \
    ${outdir}/${smp}.subreads.bam \
    ${outdir}/${smp}.polished.bam




rslformt="fasta"
zcat ${outdir}/${smp}.polished.hq.$rslformt.gz > ${outdir}/${smp}.gmap.input.$rslformt

# Error correction
if [[ ! -f "$fq1" && ! -f "$fq2" ]];then
    echo "No NGS correction"    
else
    echo "`date`: $smp - NGS correction"

    ## FLNC reads correction
    source activate lordec 
    
        zcat ${outdir}/${smp}.polished.lq.$rslformt.gz > zcat ${outdir}/${smp}.polished.lq.$rslformt

        zcat $fq1 $fq2 | paste - - - - | sed 's/^@/>/g'| cut -f1-2 | tr '\t' '\n' > ${outdir}/${smp}.fastq2fasta      
        lordec-correct -i ${outdir}/${smp}.polished.lq.$rslformt -2 ${outdir}/${smp}.fastq2fasta -T 40 -k 21 -s 2  -o ${outdir}/${smp}.polished.lq.corrected.$rslformt && rm ${outdir}/${smp}.fastq2fasta 
        
        cat ${outdir}/${smp}.polished.lq.corrected.$rslformt >> ${outdir}/${smp}.gmap.input.$rslformt

    conda deactivate


fi


echo "`date`: $smp - GMAP"
### GMAP
gmap="/data/home2/Zhongxu/software/gmap-2019-03-15/bin/gmap"
db="/data/home2/Zhongxu/ref/gmapdb/hg38 -d hg38 "


$gmap -D $db -f samse -n 0 -t 30 \
     --max-intronlength-ends 200000 -z sense_force \
     ${outdir}/${smp}.gmap.input.$rslformt > ${outdir}/${smp}.gmap.isoforms.sam 2> .${outdir}/${smp}.gmap.isoforms.sam.log
    

# sort sam
sort -k 3,3 -k 4,4n ${outdir}/${smp}.gmap.isoforms.sam > ${outdir}/${smp}.gmap.isoforms.sort.sam


echo "`date`: $smp - Cupcake"
### Cupcake

# cupcake collpase
    
collapse_isoforms_by_sam.py \
    --input ${outdir}/${smp}.gmap.input.$rslformt \
    -s ${outdir}/${smp}.gmap.isoforms.sort.sam \
    --dun-merge-5-shorter -c 0.95 -i 0.90 \
    -o ${outdir}/${smp}.cupcake
    

# post collpased
# Get abundance/read stat information after running collapse script. 
get_abundance_post_collapse.py ${outdir}/${smp}.cupcake.collapsed ${outdir}/${smp}.clustered.cluster_report.csv
    
# Filter collapse results by minimum FL count support
# filter_by_count.py  --min_count 2 ${outdir}/${smp}.cupcake.collapsed
    
# if collapse is run with --dun-merge-5-shorter
filter_away_subset.py ${outdir}/${smp}.cupcake.collapsed

    
conda deactivate

