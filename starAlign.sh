#! /bin/bash

#ulimit -u 4096
#ulimit -n 4000


##### Example
# Build index
# bash starAlign.sh -b -t 20 -g $gtf -o ${out_dir}


OUTDIR=""
SAMPLE=""
FQ1=""
FQ2=""
THREADS=20

REF="/data/home2/Zhongxu/ref/genecode.v37.star.rsem/GRCh38.primary_assembly.genome.fa"
RNALIBRARY="none"

#STAR="/data/home2/Zhongxu/software/STAR-2.7.0f/bin/Linux_x86_64/"
STAR="/data/home2/Zhongxu/software/STAR-2.7.8a/bin/Linux_x86_64/"

# Default. Can be overwrited by -s
STARIND="/data/home2/Zhongxu/ref/genecode.v37.star.rsem/starind/star"
runSTAR="false"

# Default. Can be overwrited by -g
#GTF="/data/home2/Zhongxu/ref/refSeq.hg38.gtf"
GTF="/data/home2/Zhongxu/ref/genecode.v37.star.rsem/gencode.v37.annotation.gtf"

#RSEM="/data/home2/Zhongxu/software/RSEM/"
RSEM="/data/home2/Zhongxu/software/RSEM-1.3.3/"

# Default. Can be overwrited by -r
RSEMIND="/data/home2/Zhongxu/ref/genecode.v37.star.rsem/starind/rsem/rsem"
runRSEM="false"

buildIND="false"

BAM=""

while getopts "1:2:s:o:g:i:r:t:f:qba" arg ## arg is option
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
        q)
            runRSEM="true"
            ;;
        b)
            buildIND="true"
            ;;
        g)
            GTF="$OPTARG"  # overwrite default GTF
            ;;
        i)
            STARIND="$OPTARG"  # overwrite default GTF
            ;;
        r)
            RSEMIND="$OPTARG"  # overwrite default GTF
            ;;
        t)
            THREADS="$OPTARG"  # overwrite default GTF
            ;;
	l)
            RNALIBRARY="$OPTARG" # none|forward|reverse
	    ;;
        f)
            BAM="$OPTARG"  # overwrite default GTF
            ;;
        a)
            runSTAR="true"  # run STAR
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

if ${buildIND}; then

echo "Star index"

mkdir -p ${OUTDIR}/star
${STAR}/STAR --runThreadN ${THREADS} --runMode genomeGenerate \
     --genomeDir ${OUTDIR}/star \
     --genomeFastaFiles ${REF} \
     --sjdbGTFfile ${GTF} \
     --sjdbOverhang 149   
     

echo "RSEM index"

mkdir -p ${OUTDIR}/rsem
${RSEM}/rsem-prepare-reference --gtf ${GTF} \
     --star --star-path ${STAR}  \
     --star-sjdboverhang 149 -p ${THREADS}  ${REF}  \
     ${OUTDIR}/rsem/rsem

exit 0    
fi


if [ -z "$FQ1" ] || [ -z "$FQ2" ] || [ -z "$SAMPLE" ];then
	echo -e 'Fastq not exist (-1 or -2) or sample name not specified (-s)'
    exit 1
fi

if [ ! -d "${OUTDIR}" ];then
    mkdir ${OUTDIR}
fi

if [ -d "${OUTDIR}/star" ];then
    rm -rf ${OUTDIR}/TmpStar
fi

if ${runSTAR};then

# To output only one of the multi-mapping alignments, picked randomly out of the alignments with the highest score:
# --outMultimapperOrder Random --outSAMmultNmax 1
# On the other hand, simply reports only uniquely mapping reads, i.e. discards all the reads that are multi-mappers.  
# --outFilterMultimapNmax 1 


#  STAR does not use strand information for mapping
# If you want to get a Aligned.sortedByCoord.out.bam, use this option: 
# --outSAMtype BAM SortedByCoordinate

# Compatibility with Cufflinks/Cuffdif
# --outSAMstrandField intronMotif

# If you have stranded RNA-seq data, you do not need to use any specific STAR options

${STAR}/STAR --runThreadN ${THREADS} \
       --genomeDir ${STARIND} \
       --sjdbGTFfile ${GTF} \
       --readFilesIn ${FQ1} ${FQ2} \
       --outSAMtype BAM SortedByCoordinate --outSAMattributes All \
       --outFileNamePrefix ${OUTDIR}/${SAMPLE}.star --outTmpDir ${OUTDIR}/TmpStar  \
       --twopassMode Basic --outFilterMultimapNmax 1  \
       --genomeLoad NoSharedMemory --readFilesCommand zcat \
       --quantMode TranscriptomeSAM GeneCounts --outSAMunmapped Within KeepPairs

if [ $? -ne 0 ]; then
   echo "${SAMPLE}\tSTAR" >> ~/sample.error
   exit 1
fi

  samtools index -@ ${THREADS} ${OUTDIR}/${SAMPLE}.starAligned.sortedByCoord.out.bam
  
  BAM="${OUTDIR}/${SAMPLE}.starAligned.toTranscriptome.out.bam"

  rm -rf ${OUTDIR}/TmpStar
  rm -rf ${OUTDIR}/${SAMPLE}.star_STAR*

else
  if [ ! -f ${BAM}  ];then
      echo -e "pls input bam file by -f option"
      exit 1
  fi
fi



if ${runRSEM};then
  # --strand-specific
  # The RNA-Seq protocol used to generate the reads is strand specific, i.e., all (upstream) reads are derived from the forward strand. This option is equivalent to --forward-prob=1.0
  # --strandedness <none|forward|reverse>
  # This option defines the strandedness of the RNA-Seq reads. It recognizes three values: 'none', 'forward', and 'reverse'. 'none' refers to non-strand-specific protocols. 'forward' means all (upstream) reads are derived from the forward strand. 'reverse' means all (upstream) reads are derived from the reverse strand. 
  ${RSEM}/rsem-calculate-expression --paired-end -p ${THREADS} \
      --strandedness ${RNALIBRARY} --no-bam-output --alignments ${BAM} \
      ${RSEMIND} ${OUTDIR}/${SAMPLE}.rsem


  if [ $? -ne 0 ]; then
    echo "${SAMPLE}\tRSEM" >> ~/sample.error
    exit 1
  fi

else
  echo -e "Not run RSEM quantification"
fi



