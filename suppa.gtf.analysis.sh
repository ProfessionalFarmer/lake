#! /bin/bash

outdir="./"
basegtf=''
normal=""
tumor=""


while getopts "o:g:n:t:" arg ## arg is option
do
    case $arg in
        g)
            basegtf="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            outdir="$OPTARG"
            ;;
        n)
            normal="$OPTARG" # arguments stored in $OPTARG
            ;;
        t)
            tumor="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$basegtf" ];then
	echo "pls specify gtf/gff file by -g option"
	exit 1
fi


if [ -z "$normal" ] || [ -z "$tumor" ];then
        echo "pls specify normal/tumor expression file"
        exit 1
fi


########### SUPPA ###########
#source activate suppa


# generate event by merged.clean.gtf
#-p | --pool-genes: - Optional. Redefine genes by clustering together transcripts by genomic stranded overlap and sharing at least one exon. It is crucial when creating ioe/ioi from annotations that are not loci-based, e.g.: RefSeq and UCSC genes.
#Using the --pool-genes option is also advisable to use with Ensembl and Gencode. The annotation contains genes with overlapping transcripts that share a great deal of sequence, hence their relative contribution to alternative splicing events should be taken into account.

suppa.py generateEvents -i $basegtf  -o ${outdir}/1.merged-ASevents.ioi -e SE SS MX RI FL -b S -p -f ioi --pool-genes
suppa.py generateEvents -i $basegtf -o ${outdir}/1.merged-ASevents.ioe -e SE SS MX RI FL -b S -p -f ioe --pool-genes


#Put all the ioe events in the same file: used in psi per event
awk 'FNR==1 && NR!=1{next;}{print}'  ${outdir}/1.merged-ASevents.ioe*ioe  > ${outdir}/2.merged-ASevents.merged7.ioe



# psi per event
suppa.py psiPerEvent -i ${outdir}/2.merged-ASevents.merged7.ioe -e ${tumor}  -o ${outdir}/3T.AStranscripts.psiPerEvent.tumor

suppa.py psiPerEvent -i ${outdir}/2.merged-ASevents.merged7.ioe -e ${normal} -o ${outdir}/3N.AStranscripts.psiPerEvent.normal

suppa.py diffSplice --save_tpm_events -m empirical -gc \
        -i ${outdir}/2.merged-ASevents.merged7.ioe \
        -p ${outdir}/3N.AStranscripts.psiPerEvent.normal.psi ${outdir}/3T.AStranscripts.psiPerEvent.tumor.psi \
        --tpm ${normal} ${tumor} \
        -o ${outdir}/4.diffSplice.events

# psi per isoform
suppa.py psiPerIsoform -e ${tumor} \
        -g $basegtf -o ${outdir}/5T.AStranscripts.psiPerIsofrom.tumor

suppa.py psiPerIsoform -e ${normal} \
        -g $basegtf -o ${outdir}/5N.AStranscripts.psiPerIsofrom.normal

suppa.py diffSplice --method empirical --input ${outdir}/1.merged-ASevents.ioi.ioi \
        --psi ${outdir}/5N.AStranscripts.psiPerIsofrom.normal_isoform.psi ${outdir}/5T.AStranscripts.psiPerIsofrom.tumor_isoform.psi \
        --tpm ${normal} ${tumor} \
        --area 1000 --lower-bound 0.05 -gc \
        -o ${outdir}/6.diffSplice.isoform --save_tpm_events


#conda deactivate
