#! /bin/bash
# 2019-03-26
# 2019-04-16: support subreads.bam in fofn file
# software, directory not absolute path
splicemap='/data/home2/Zhongxu/software/SpliceMap3352_example_linux-64/'
hg19chrdir='/data/home2/Zhongxu/ref/hg19Chr/'
hg19genome='/data/home2/Zhongxu/ref/UCSCHg19/ucsc.hg19.fasta'
#https://web.stanford.edu/group/wonglab/SpliceMap/hg19.all.gene.refFlat.txt
allrefflat='/data/home2/Zhongxu/ref/hg19.all.gene.refFlat.txt'
#http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/refFlat.txt.gz
refflat='/data/home2/Zhongxu/ref/hg19.refFlat.txt'
bowtieindex='/data/home2/Zhongxu/ref/hg19-bowtie2idx/genome'
lsc='/data/home2/Zhongxu/software/LSC-2.0/'
ropebwt='/data/home2/Zhongxu/software/ropebwt2-master/'
fmlrc='/data/home2/Zhongxu/software/fmlrc-master/'
proovread='/data/home2/Zhongxu/software/proovread/'
idp='/data/home2/Zhongxu/software/IDP-master'
idpfusion='/data/home2/Zhongxu/software/IDP-fusion_1.1.1'
gmap='/data/home2/Zhongxu/software/gmap-2019-03-15/'
gmaphg19index='/data/home2/Zhongxu/ref/gmapdb/hg19/'
star='/data/home2/Zhongxu/software/STAR-2.7.0f'
starindex='/data/home2/Zhongxu/ref/staridx'
rsem='/data/home2/Zhongxu/software/RSEM'
rsemindex='/data/home2/Zhongxu/ref/rsem-ref/genome'
hisat='/data/home2/Zhongxu/software/hisat2-2.1.0'
hisatindex='/data/home2/Zhongxu/ref/hisatindex/genome'
stringtie='/data/home2/Zhongxu/software/stringtie-1.3.5.Linux_x86_64'
#absolute executon file
blat='/data/home2/Zhongxu/software/blat'
seqmap='/data/home2/Zhongxu/software/seqmap-1.0.12-linux-64'
pbtranscript='/data/home2/Zhongxu/software/cDNA_primer-prebam/pbtranscript-tofu/pbtranscript/pbtools/pbtranscript/pbtranscript.py'
ensemblgtf='/data/home2/Zhongxu/ref/Homo_sapiens.GRCh37.87.gtf'
### options
SRfq1=''
SRfq2=''
# subreads.bam or subreads.bam in fofn file
LRbam=''
smp=''
outdir=''
STEP='all'
threads=20
primer=''


while getopts "1:2:s:l:o:p:b:" arg ## arg is option
do
    case $arg in
        1)
            SRfq1="$OPTARG" # arguments stored in $OPTARG
            ;;
        2)
            SRfq2="$OPTARG"
            ;;
        s)
            smp="$OPTARG"
            ;;
        o)
            outdir="$OPTARG"
            ;;
        l)
            LRbam="$OPTARG"
            ;;

        p)
            STEP="$OPTARG"
            ;;
        b)
	    primer="$OPTARG"
	    ;; 
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

# check options
if [[ ! -f "$SRfq1" || ! -f "$SRfq2"  || ! -f "$LRbam" ]];then
    echo "Please set fastq input by -1 and -2 option, long read bam file by -l"
    exit 1
fi
if [ -z "$smp" ];then
    echo "Please set a sample name by -s option"
    exit 1
fi

if [ -z "$outdir" ];then
    echo "Please set a output directory by -d option"
    exit 1
fi
dir=${outdir}

if [ ! -d "$outdir" ];then
    mkdir $outdir
fi
outdir=$(cd $outdir;pwd)

#######################################################################
# Splice Map
# http://web.stanford.edu/group/wonglab/SpliceMap/manual.html

if [ $STEP == 1 -o $STEP == 'all' ]; then
        echo "Run splicemap: `date`"
        if [ ! -d "$outdir/splicemap" ];then
                mkdir ${outdir}/splicemap
        fi
        splicemap_cfg=`cat ${splicemap}/run.cfg`
        # genome_dir Each chromosome should be in a separate file (can be concatenated) 
        splicemap_cfg=`echo "${splicemap_cfg}" | sed  "s#genome_dir = genome#genome_dir = $hg19chrdir#g"  ` 
        # replace R1 and R2
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#data/long_reads_1_100K.txt.seq#$SRfq1#g"`
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#data/long_reads_2_100K.txt.seq#$SRfq2#g"`
        # read format  Choices are: FASTA, FASTQ, RAW
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#read_format = RAW#read_format = FASTQ#g"`
        # annotations = all.gene.refFlat.txt
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#annotations = all.gene.refFlat.txt#annotations = $allrefflat#g"` 
        # output temp directory
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#temp_path = temp#temp_path = $outdir/splicemap/temp#g"`
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#out_path = output#out_path = $outdir/splicemap/output#g"`
        # bowtie2 genome index
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#bowtie_base_dir = genome/chr21#bowtie_base_dir = $bowtieindex#g"`
        # threads
        splicemap_cfg=`echo "${splicemap_cfg}" | sed "s#num_threads = 2#num_threads = $threads#g"`
        echo  "${splicemap_cfg}"

        # real run 
        echo "${splicemap_cfg}" > ${outdir}/splicemap/run.cfg
        ${splicemap}/bin/runSpliceMap ${outdir}/splicemap/run.cfg

fi
###################################################################



###################################################################
if [ $STEP == 2 -o $STEP == 'all' ]; then
	# https://github.com/PacificBiosciences/unanimity/blob/develop/doc/PBCCS.md
        echo "Run ISO-SEQ: `date`"
        if [ ! -d "$outdir/isoseq" ];then
                mkdir ${outdir}/isoseq
        fi
        # judge file suffix is bam or fofn
        fofn=''
	if [ "${LRbam##*.}"x = "bam"x ];then 
            fofn=$LRbam
        elif [ "${LRbam##*.}"x = "fofn"x ];then 
	    fofn=`cat $LRbam`
        else
            echo "please input subreads.bam or fofn file by -l option"
            exit	    
        fi
	for bamfile in $fofn;do
	    if [ ! -f "$bamfile.pbi" ];then
                pbindex $bamfile
            fi
	    bname=`basename $bamfile .bam`
	    dataset create --type SubreadSet --force ${outdir}/isoseq/$bname.b.subreadset.xml $bamfile
        #1 circular consensus sequence calling
        # conda install -c bioconda pbccs
        # conda install -c bioconda bax2bam
        # Circular Consensus Sequence calling
        # obsolete https://github.com/kkrizanovic/cDNA_primer/tree/master/pbtranscript-tofu/pbtranscript/pbtools/pbtranscript
        # now https://github.com/PacificBiosciences/IsoSeq3/blob/master/README_v3.1.md
            ccs --noPolish --force --numThreads=$threads --minPasses=1  --minReadScore=0.75 --minLength=200 --minPredictedAccuracy=0.75 $bamfile ${outdir}/isoseq/$bname.ccs.bam  --reportFile ${outdir}/isoseq/$bname.ccs_report.txt
            echo $bamfile
	    exit
	#2 Primer removal and demultiplexing  ---> full length
        # Demultiplex Barcoded PacBio Data and Clip Barcodes
            lima ${outdir}/isoseq/$bname.ccs.bam $primer ${outdir}/isoseq/$bname.fl.bam --isoseq --no-pbi --peek-guess -j $threads
        #3 refine  full length read --> Trimming of poly(A) tails and Rapid concatmer identification and removal
        # If your sample has poly(A) tails, use --require-polya. This filters for FL reads that have a poly(A) tail with at least 20 base pairs and removes identified tail:
            isoseq3 refine `ls ${outdir}/isoseq/$bname.fl.*_5p--*_3p.bam` $primer ${outdir}/isoseq/$bname.flnc.bam --require-polya
	done
        #merge
	rm ${outdir}/isoseq/$smp.merged.flnc.xml
	rm ${outdir}/isoseq/$smp.merged.subreadset.xml
        dataset create --type TranscriptSet ${outdir}/isoseq/$smp.merged.flnc.xml `ls ${outdir}/isoseq/*flnc.bam`        
        dataset create --type SubreadSet ${outdir}/isoseq/$smp.merged.subreadset.xml `ls ${outdir}/isoseq/*.b.subreadset.xml` 
        #4 isoseq3 cluster - cluster FLNC reads and generate unpolished transcripts (FLNC to UNPOLISHED)
        if [ ! -d "${outdir}/isoseq/cluster" ];then
            mkdir ${outdir}/isoseq/cluster
	fi
	clusterjob=24
        isoseq3 cluster ${outdir}/isoseq/$smp.merged.flnc.xml ${outdir}/isoseq/cluster/$smp.unpolished.bam --verbose --num-threads $threads --split-bam $clusterjob
        #5 isoseq3 polish - polish transcripts using subreads (UNPOLISHED to POLISHED)
        # speed up polish
	for((i=0;i<$clusterjob;i++));
        do
	    isoseq3 polish ${outdir}/isoseq/cluster/$smp.unpolished.$i.bam ${outdir}/isoseq/$smp.merged.subreadset.xml ${outdir}/isoseq/cluster/$smp.polished.$i.bam --verbose &
            if [ $[i%4] -eq 3 ];then
                wait
            fi
        done
	wait
	#isoseq3 polish ${outdir}/isoseq/$smp.unpolished.bam ${outdir}/isoseq/$smp.subreadset.xml ${outdir}/isoseq/$smp.polished.bam --verbose --num-threads  $threads
	gunzip -dc ${outdir}/isoseq/cluster/$smp.polished.[0-9]*.lq.fasta.gz > ${outdir}/isoseq/$smp.polished.merge.lq.fasta 
	gunzip -dc ${outdir}/isoseq/cluster/$smp.polished.[0-9]*.hq.fasta.gz > ${outdir}/isoseq/$smp.polished.merge.hq.fasta
fi 
##################################################################





###################################################################
if [ $STEP == 3 -o $STEP == 'all' ]; then
        echo "Run error corection: `date`"
        if [ ! -d "$outdir/lrcorrect" ];then
                mkdir ${outdir}/lrcorrect
        fi
	cat ${outdir}/isoseq/$smp.polished.merge.hq.fasta ${outdir}/isoseq/$smp.polished.merge.lq.fasta > ${outdir}/lrcorrect/raw2correct.fa	
        # error correction can be make by LSC, fmlrc or proovread
        # LSC
	$lsc/bin/runLSC.py --long_reads ${outdir}/lrcorrect/raw2correct.fa --short_reads $SRfq1 $SRfq2 --short_read_file_type fq --threads $threads --specific_tempdir ${outdir}/lrcorrect/lsctemp -o ${outdir}/lrcorrect/lscoutput --mode 0 &
	#LRCorrectfa=${outdir}/lrcorrect/lscoutput/corrected_LR.fa
        # fmlrc
	cat $SRfq1 $SRfq2 | awk 'NR % 4 == 2' | sort | tr NT TN |  $ropebwt/ropebwt2 -LR | tr NT TN | $fmlrc/fmlrc-convert -f ${outdir}/lrcorrect/$smp.comp_msbwt.npy
        $fmlrc/fmlrc ${outdir}/lrcorrect/$smp.comp_msbwt.npy ${outdir}/lrcorrect/raw2correct.fa  ${outdir}/lrcorrect/$smp.fmlrc.lq.corrected_reads.fa
	#LRCorrectfa="${outdir}/lrcorrect/$smp.fmlrc.lq.corrected_reads.fa"
	# proovread
	# -u unitigs
        $proovread/bin/proovread -l ${outdir}/lrcorrect/raw2correct.fa -s $SRfq1 -s $SRfq2 -p ${outdir}/lrcorrect/proovread -t $threads --overwrite --keep-temporary-files
	#LRCorrectfa=${outdir}/lrcorrect/proovread/proovread.trimmed.fa
fi
###################################################################
	#LRCorrectfa=${outdir}/lrcorrect/lscoutput/corrected_LR.fa
	LRCorrectfa="${outdir}/lrcorrect/$smp.fmlrc.lq.corrected_reads.fa"
	#LRCorrectfa=${outdir}/lrcorrect/proovread/proovread.trimmed.fa


###################################################################
if [ $STEP == 4 -o $STEP == 'all' ]; then
        echo "Run IDP: `date`"
        if [ ! -d "$outdir/idp" ];then
                mkdir ${outdir}/idp
        fi
        idp_cfg=`cat $idp/src/main/python/run.cfg` 
        # specify type
	idp_cfg=`echo "$idp_cfg" | sed "s#LR_gpd_pathfilename =  data/LR.gpd#LR_gpd_pathfilename =  #g" `
        idp_cfg=`echo "$idp_cfg" | sed "s#psl_type = 1#psl_type = 3 #g"`
	# long read path
	# Long reads should be corrected with LSC first, and the corrected.fa and full.fa files should be concatonated into a single fasta for use in IDP
	cat ${outdir}/isoseq/$smp.polished.merge.hq.fasta ${outdir}/isoseq/$smp.polished.merge.lq.fasta $LRCorrectfa > ${outdir}/idp/input.fasta
	LRCorrectfa="${outdir}/idp/input.fasta"
        idp_cfg=`echo "$idp_cfg" | sed "s#LR_pathfilename = /hsgs/projects/whwong/pegahta/IDP_0.1/example/data/longreads.fa#LR_pathfilename = $LRCorrectfa#g"`
	# whole genome fa in one file
        idp_cfg=`echo "$idp_cfg" | sed "s#genome_pathfilename = /hsgs/projects/whwong/pegahta/IDP_0.1/example/data/genome.fa#genome_pathfilename = $hg19genome#g"`
	# SR alignment and jucntion file
        idp_cfg=`echo "$idp_cfg" | sed "s#SR_jun_pathfilename = /hsgs/projects/whwong/pegahta/IDP_0.1/example/data/junction_color.bed#SR_jun_pathfilename = ${outdir}/splicemap/output/junction_color.bed#g"`
	idp_cfg=`echo "$idp_cfg" | sed "s#SR_sam_pathfilename = /hsgs/projects/whwong/pegahta/IDP_0.1/example/data/good_hits.sam#SR_sam_pathfilename = ${outdir}/splicemap/output/good_hits.sam#g"`
	# gmap aligner
	idp_cfg=`echo "$idp_cfg" | sed "s#gmap_index_pathfoldername = ./data/gmap_hg19/#gmap_index_pathfoldername = $gmaphg19index#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#gmap_executable_pathfilename = gmap#gmap_executable_pathfilename = $gmap/bin/gmap##g"`	
	# blat
	idp_cfg=`echo "$idp_cfg" | sed "s#blat_executable_pathfilename = blat#blat_executable_pathfilename = $blat#g"`
	# seqmap
	idp_cfg=`echo "$idp_cfg" | sed "s#seqmap_executable_pathfilename = seqmap#seqmap_executable_pathfilename = $seqmap#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#temp_foldername = temp#temp_foldername = ${outdir}/idp/temp#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#output_foldername = output#output_foldername = ${outdir}/idp/output#g"`
        # threads
	idp_cfg=`echo "$idp_cfg" | sed "s#Nthread = 10#Nthread = $threads#g"`
        # annotation
        idp_cfg=`echo "$idp_cfg" | sed "s#allref_annotation_pathfilename = /home/kinfai/3seq/IDP_0.1/test_data/hg19.all.gene_est.refFlat.txt#allref_annotation_pathfilename = $allrefflat#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#ref_annotation_pathfilename = /home/kinfai/3seq/IDP_0.1/test_data/normal_ref.gpd#ref_annotation_pathfilename = $refflat#g"`
        # do not have 
	idp_cfg=`echo "$idp_cfg" | sed "s#CAGE_data_filename = /home/kinfai/3seq/H1_CAGE/encodeTssHmm.bedRnaElements#CAGE_data_filename = #g"`
	idp_cfg=`echo "$idp_cfg" | sed "s#detected_exp_len = /hsgs/projects/whwong/pegahta/IDP_0.1/example/data/multiexon_refFlat.txt_positive_exp_len#detected_exp_len = #g"`
	# read len
	idp_cfg=`echo "$idp_cfg" | sed "s#read_length = 50#read_length = 101#g"`

	echo "$idp_cfg" > $outdir/idp/run.cfg
#        $idp/src/main/python/runIDP.py $outdir/idp/run.cfg 0

	cut -f 2- $outdir/idp/output/isoform.gpd > $outdir/idp/output/isoform.2.gpd
	genePredToGtf file $outdir/idp/output/isoform.2.gpd $outdir/idp/output/isoform.gtf
        rm $outdir/idp/output/isoform.2.gpd
fi
###################################################################




###################################################################
if [ $STEP == 5 -o $STEP == 'all' ]; then
        echo "Run IDP-fusion: `date`"
        if [ ! -d "$outdir/idpfusion" ];then
                mkdir ${outdir}/idpfusion
        fi
	idp_cfg=`cat $idpfusion/run.cfg`
	cat ${outdir}/isoseq/$smp.polished.merge.hq.fasta ${outdir}/isoseq/$smp.polished.merge.lq.fasta $LRCorrectfa | cut -f 1 -d ' '  > ${outdir}/idpfusion/input.fasta
        LRCorrectfa="${outdir}/idpfusion/input.fasta"
        # threads
        idp_cfg=`echo "$idp_cfg" | sed "s#Nthread = 10#Nthread = $threads#g"`
	# in out
        idp_cfg=`echo "$idp_cfg" | sed "s#output_foldername = output_gmap#output_foldername = ${outdir}/idpfusion/output#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#temp_foldername = temp_gmap#temp_foldername = ${outdir}/idpfusion/temp#g"`
        # aligner gmap
	idp_cfg=`echo "$idp_cfg" | sed "s#aligner_choice = gmap#aligner_choice = gmap#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#blat_executable_pathfilename =#blat_executable_pathfilename = $blat#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#gmap_index_pathfoldername = #gmap_index_pathfoldername = $gmaphg19index#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#gmap_executable_pathfilename = gmap#gmap_executable_pathfilename = $gmap/bin/gmap##g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#seqmap_executable_pathfilename =#seqmap_executable_pathfilename = $seqmap#g"`
        # LR 
        idp_cfg=`echo "$idp_cfg" | sed "s#LR_pathfilename = #LR_pathfilename = $LRCorrectfa#g"`
	idp_cfg=`echo "$idp_cfg" | sed "s#genome_pathfilename = data/genome.fasta#genome_pathfilename = $hg19genome#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#psl_type = 1#psl_type = 3 #g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#ref_annotation_pathfilename = data/normal_ref.gpd#ref_annotation_pathfilename = $refflat#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#allref_annotation_pathfilename = data/hg19.all.gene_est.refFlat.txt#allref_annotation_pathfilename = $allrefflat#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#uniqueness_bedGraph_pathfilename = data/wgEncodeDukeMapabilityUniqueness35bp.bedGraph#uniqueness_bedGraph_pathfilename = #g"`
	# junction
        idp_cfg=`echo "$idp_cfg" | sed "s#SR_jun_pathfilename = data/junction_color.bed#SR_jun_pathfilename = ${outdir}/splicemap/output/junction_color.bed#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#SR_sam_pathfilename = data/good_hits.sam#SR_sam_pathfilename = ${outdir}/splicemap/output/good_hits.sam#g"`
	idp_cfg=`echo "$idp_cfg" | sed "s#read_length = 101#read_length = 101#g"`
        # star
	idp_cfg=`echo "$idp_cfg" | sed "s#star_path =#star_path = $star/bin/Linux_x86_64/STAR#g"`
        idp_cfg=`echo "$idp_cfg" | sed "s#genome_bowtie2_index_pathfilename = # genome_bowtie2_index_pathfilename = $bowtieindex#g"`
	#cat $SRfq1 $SRfq2 |sed -n '1~4s/^@/>/p;2~4p' > ${outdir}/idpfusion/input.SR.fa
	idp_cfg=`echo "$idp_cfg" | sed "s#SR_pathfilename =#SR_pathfilename = ${outdir}/idpfusion/input.SR.fa#g"`
	
	echo "$idp_cfg" > $outdir/idpfusion/run.cfg
        $idpfusion/bin/runIDP.py $outdir/idpfusion/run.cfg 0

fi
###################################################################




###################################################################
if [ $STEP == 6 -o $STEP == 'all' ]; then
        echo "Run STAR Aligner: `date`"
        if [ ! -d "$outdir/rnaseq" ];then
                mkdir ${outdir}/rnaseq
        fi
	# For unstranded RNA-seq data, Cufflinks/Cuffdiff require spliced alignments with XS strand attribute, which STAR will generate with --outSAMstrandField intronMotif option
	# --quantMode TranscriptomeSAM option STAR will output alignments translated into transcript coordinates in the Aligned.toTranscriptome.out.bam file (in addition to alignments in genomic coordinates in Aligned.*.sam/bam files).  
        # STA:
	rm -rf ${outdir}/rnaseq/star
	$star/bin/Linux_x86_64/STAR --runThreadN $threads --outSAMstrandField intronMotif --genomeLoad NoSharedMemory  \
	  --quantMode TranscriptomeSAM GeneCounts --sjdbGTFfile $ensemblgtf --genomeDir $starindex --outSAMunmapped Within \
	  --outFilterMultimapNmax 1 --outFilterMismatchNmax 3 \
	  --chimSegmentMin 10 --chimOutType WithinBAM SoftClip --chimJunctionOverhangMin 10 --chimScoreMin 1 --chimScoreDropMax 30 --chimScoreJunctionNonGTAG 0 --chimScoreSeparation 1 --alignSJstitchMismatchNmax 5 -1 5 5 --chimSegmentReadGapMax 3 \
          --readFilesIn $SRfq1 $SRfq2 --outSAMtype BAM SortedByCoordinate \
          --outFileNamePrefix ${outdir}/rnaseq/$smp.STAR --twopassMode Basic --outTmpDir ${outdir}/rnaseq/star 
	# RSEM
	$rsem/rsem-calculate-expression --paired-end --bam ${outdir}/rnaseq/$smp.STARAligned.toTranscriptome.out.bam -p $threads $rsemindex ${outdir}/rnaseq/$smp.rsem
	# HISAT
	$hisat/extract_splice_sites.py $ensemblgtf > ${outdir}/rnaseq/splicesites.txt
	$hisat/hisat2 -x $hisatindex -1 $SRfq1 -2 $SRfq2 -p $threads -q --known-splicesite-infile ${outdir}/rnaseq/splicesites.txt | samtools view -Su | samtools sort  --threads $threads -T ${outdir}/rnaseq/$smp - > ${outdir}/rnaseq/$smp.hisat.sort.bam
        rm ${outdir}/rnaseq/splicesites.txt
        # Stringtie
	$stringtie/stringtie ${outdir}/rnaseq/$smp.hisat.sort.bam  -G $ensemblgtf -o ${outdir}/rnaseq/$smp.stringtie.gtf -b ${outdir}/rnaseq/stringtie 
         # HLA Genotype
        if [ ! -d "$outdir/rnaseq/hla" ];then
                mkdir ${outdir}/rnaseq/hla
        fi
        python ~/software/seq2HLA/seq2HLA.py -1 $SRfq1  -2 $SRfq2 -r ${outdir}/rnaseq/hla/$smp  -p 10
        
        source activate OptiType-env
        razers3 -i 95 -m 1 -dr 0 -o ${outdir}/rnaseq/hla/OptiType.R1.bam \
		/data/cache/zhongxu/miniconda3/envs/OptiType-env/share/optitype-1.3.2-3/data/hla_reference_rna.fasta $SRfq1
 	 razers3 -i 95 -m 1 -dr 0 -o ${outdir}/rnaseq/hla/OptiType.R2.bam \
                /data/cache/zhongxu/miniconda3/envs/OptiType-env/share/optitype-1.3.2-3/data/hla_reference_rna.fasta $SRfq2
        samtools bam2fq ${outdir}/rnaseq/hla/OptiType.R1.bam  > ${outdir}/rnaseq/hla/OptiType.R1.fished.fastq
        samtools bam2fq ${outdir}/rnaseq/hla/OptiType.R2.bam  > ${outdir}/rnaseq/hla/OptiType.R2.fished.fastq        
        OptiTypePipeline.py -i ${outdir}/rnaseq/hla/OptiType.R1.fished.fastq ${outdir}/rnaseq/hla/OptiType.R2.fished.fastq --rna --outdir ${outdir}/rnaseq/hla/ -v
	conda deactivate

         # defuse to detect fusion                 defuse_create_ref.pl -d defuserefdata
	 if [ ! -d "$outdir/rnaseq/defuse" ];then
                mkdir ${outdir}/rnaseq/defuse
         fi
         rm ${outdir}/rnaseq/defuse/*
         source activate defuse-env
         defuse_run.pl -d /data/home2/Zhongxu/ref/defuserefdata -1 $SRfq1 -2 $SRfq2 -p $threads -o ${outdir}/rnaseq/defuse 
         conda deactivate
	 # STAR-Fusion
         if [ ! -d "$outdir/rnaseq/star-fusion" ];then
                mkdir ${outdir}/rnaseq/star-fusion
         fi
	 STAR-Fusion --genome_lib_dir /data/home2/Zhongxu/ref/GRCh37_gencode_v19_CTAT_lib_Mar272019.plug-n-play/ctat_genome_lib_build_dir \
		 --left_fq $SRfq1 --right_fq $SRfq2 --CPU $threads \
		 --output_dir ${outdir}/rnaseq/star-fusion

          if [ ! -d "$outdir/rnaseq/arriba" ];then
                mkdir ${outdir}/rnaseq/arriba
          fi
          /data/home2/Zhongxu/software/arriba_v1.1.0/arriba -x ${outdir}/rnaseq/$smp.STARAligned.sortedByCoord.out.bam \
		  -o ${outdir}/rnaseq/arriba/fusion.tsv -O ${outdir}/rnaseq/arriba/fusion.discarded.tsv \
		  -a $hg19genome -g $ensemblgtf -T -P \
		  -b /data/home2/Zhongxu/software/arriba_v1.1.0/database/blacklist_hg19_hs37d5_GRCh37_2018-11-04.tsv.gz




fi
###################################################################

###################################################################
if [ $STEP == 7 -o $STEP == 'all' ]; then
        echo "Run Sqanti: `date`"
        if [ ! -d "$outdir/sqanti" ];then
                mkdir ${outdir}/sqanti
        fi
        cat $LRCorrectfa ${outdir}/isoseq/$smp.polished.merge.hq.fasta > ${outdir}/sqanti/input.fa
        python ~/software/ConesaLab-sqanti-6927e53e56d2/sqanti_qc.py \
            -c ${outdir}/rnaseq/$smp.STARSJ.out.tab  \
	    -n -e  ${outdir}/rnaseq/$smp.rsem.isoforms.results \
            -t 20 -o $smp -d ${outdir}/sqanti -x $gmaphg19index  \
            ${outdir}/sqanti/input.fa  \
	    $ensemblgtf $hg19genome 
        python ~/software/ConesaLab-sqanti-6927e53e56d2/sqanti_filter.py -d ${outdir}/sqanti ${outdir}/sqanti/${smp}_classification.txt
        echo "${outdir}/sqanti/input_corrected.gtf" > ${outdir}/sqanti/tmp.list
        $stringtie/stringtie --merge -p 8 -o ${outdir}/sqanti/sqanti.clean.gtf ${outdir}/sqanti/tmp.list
	rm ${outdir}/sqanti/tmp.list

fi


###################################################################






