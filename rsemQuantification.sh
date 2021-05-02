#! /bin/bash

OUTDIR=""
SAMPLE=""
FQ1=""
FQ2=""
THREADS=20

REF="/data/home2/Zhongxu/ref/hg38/Homo_sapiens_assembly38.fasta"

STAR="/data/home2/Zhongxu/software/STAR-2.7.0f/bin/Linux_x86_64/"

# Default. Can be overwrited by -s
STARIND="/data/home2/Zhongxu/ref/staridx.hg38.refSeq"

# Default. Can be overwrited by -g
GTF="/data/home2/Zhongxu/ref/refSeq.hg38.gtf"

RSEM="/data/home2/Zhongxu/software/RSEM/"

# Default. Can be overwrited by -r
RSEMIND="/data/home2/Zhongxu/ref/rsemidx.hg38.refSeq/rsem"

buildIND="false"


while getopts "1:2:s:o:g:r:t:b" arg ## arg is option
do
    case $arg in
        1)
            FQ1="$OPTARG" # arguments stored in $OPTARG
            ;;
        2)
            FQ2="$OPTARG"
            ;;
        s)
            SAMPLE="$OPTARG"
            ;;
        o)
            OUTDIR="$OPTARG"
            ;;
        b)
            buildIND="true"
            ;;
        g)
            GTF="$OPTARG"  # overwrite default GTF
            ;;
        r)
            RSEMIND="$OPTARG"  # overwrite RSEM index
            ;;
        t)
            THREADS="$OPTARG"  # overwrite threads
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z $OUTDIR ]; then
   echo -e "Pls specify output directory"
   exit 1
fi

if [ ${buildIND} ]; then

mkdir -p ${OUTDIR}
${RSEM}/rsem-prepare-reference --gtf ${GTF} \
     --star --star-path /data/home2/Zhongxu/software/STAR-2.7.0f/bin/Linux_x86_64/  \
     --star-sjdboverhang 149 -p ${THREADS}  ${REF}  \
     ${OUTDIR}

exit 0    

fi


if [ -z "$FQ2" ] || [ -z "$FQ2" ] ;then
    echo -e 'Fastq not exist'
    exit 1
fi

if [! -d "${OUTDIR}" ];then
    mkdir ${OUTDIR}
fi

${RSEM}/rsem-calculate-expression --paired-end -p ${THREADS} \
    --append-names --output-genome-bam --sort-bam-by-coordinate  \
    --strandedness none\
    --star --sort-bam-memory-per-thread 1G --star-bzipped-read-file\
    $FQ1 $FQ2 \
    ${RSEMIND} ${OUTDIR}/${SAMPLE}.rsem




