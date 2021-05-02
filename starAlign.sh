#! /bin/bash

OUTDIR=""
SAMPLE=""
FQ1=""
FQ2=""
THREADS=15

STAR="/data/home2/Zhongxu/software/STAR-2.7.0f/bin/Linux_x86_64/STAR"
genomeDir="/data/home2/Zhongxu/ref/staridx.hg38.refSeq"
GTF="/data/home2/Zhongxu/ref/refSeq.hg38.gtf"

RSEM="/data/home2/Zhongxu/software/RSEM/rsem-calculate-expression"
RSEMIND="/data/home2/Zhongxu/ref/rsemidx.hg38.refSeq/rsem"
runRSEM="false"


while getopts "1:2:s:o:r" arg ## arg is option
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
        r)
            runRSEM="true"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$FQ2" ] || [ -z "$FQ2" ] ;then
    echo -e 'Fastq not exist'
    exit 1
fi

if [! -d "${OUTDIR}" ];then
    mkdir ${OUTDIR}
fi

if [ -d "${OUTDIR}/star" ];then
    rm -rf ${OUTDIR}/star
fi

$STAR --runThreadN ${THREADS} \
     --genomeDir ${genomeDir} \
     --sjdbGTFfile ${GTF} \
     --readFilesIn ${FQ1} ${FQ2} \
     --outSAMtype BAM SortedByCoordinate --outSAMattributes All \
     --outFileNamePrefix ${OUTDIR}/${SAMPLE}.star --outTmpDir ${OUTDIR}/star  \
     --twopassMode Basic --outMultimapperOrder Random \
     --outSAMmultNmax 1 --outFilterMultimapNmax 1  \
     --genomeLoad NoSharedMemory --readFilesCommand zcat \
     --quantMode TranscriptomeSAM GeneCounts --outSAMunmapped Within KeepPairs

if [ "${runRSEM}" ];then
  $RSEM --paired-end -p ${THREADS} \
      --bam ${OUTDIR}/${SAMPLE}.starAligned.toTranscriptome.out.bam \
      ${RSEMIND} ${OUTDIR}/${SAMPLE}.rsem
else
  echo -e "Not run RSEM quantification"
fi



