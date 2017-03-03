#! /bin/bash
# Author: Jason
# This script will invoke varscan to call copy number variant
# Input bam file or pileup file. Required
# Mode:
#	1, Bam input, mpileup
#	2, Bam input, pileup
#	3, mpileup
#	4, pileup  . If mode 4, please set mpileup in -t option
#  


varscan="/data3/zzx-temp/VarScan.v2.4.1.jar"
samtools="/data/SG/Env/software_installed/samtools-1.2/samtools"
hgRef="/data/SG/Env/reference_data/ucsc.hg19.fasta"
sampleName='Sample'
normal=''
tumor=''
out=''
mode='1'
merge="/data3/zzx-temp/mergeSegments.pl"
arm="/data3/zzx-temp/armsize.bak"

while getopts "s:n:t:o:m:h" arg ## arg is option
do
    case $arg in 
        s) 
            sampleName="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            out="$OPTARG"
            ;;
        n)
            normal="$OPTARG"
            ;;
        t)
            tumor="$OPTARG"
            ;;
        m)                                                                                        
            mode="$OPTARG"                                                                       
            ;;
        h)
            echo "-n normal.bam -t tumor.bam -o out"
	    exit 0
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$normal" ];then
if [ ! -f "$normal" ]; then
  echo "Input file $normal not exist"
  exit 1
fi
fi

if [ ! -f "$tumor" ];then
  echo "Input file $tumor not exist"
  exit 1
fi
if [ -z "$out" ];then
  echo "Pleast set out path file"
  exit 1
fi

## recommend to filter low quality read by -q option
## varscan option
# --min-base-qual - Minimum base quality to count for coverage [20]
# --min-map-qual - Minimum read mapping quality to count for coverage [20]
# --min-coverage - Minimum coverage threshold for copynumber segments [20]
# --min-segment-size - Minimum number of consecutive bases to report a segment [10]
# --max-segment-size - Max size before a new segment is made [100]
# --p-value - P-value threshold for significant copynumber change-point [0.01]
# --data-ratio - The normal/tumor input data ratio for copynumber adjustment [1.0]
##

echo "`date`: copynumber call raw Copy number"
if [ "$mode"x = "1"x ];then
# mpileup
# need to filter in mpileup file
echo "Mode 1"
$samtools mpileup -q 1 -f $hgRef $normal $tumor | awk -F "\t" '$4 > 0 && $7 > 0' | java -jar ${varscan} copynumber  --output-file ${out}.raw --mpileup 1 
fi
if [ "$mode"x = "2"x ];then
# pileup
echo "Mode 2"
# current varscan version does not need to filter pileup file
bash -c "java -jar ${varscan} copynumber <($samtools mpileup -f $hgRef $normal) <($samtools mpileup -f $hgRef $tumor)  ${out}.raw " 
#bash -c "java -jar ${varscan} copynumber <($samtools mpileup -f $hgRef $normal| awk -F \"\\t\" '{if (\$4!=0) {print \$0}}') <($samtools mpileup -f $hgRef $tumor | awk -F \"\\t\" '{if (\$4!=0) {print \$0}}')  ${out}.raw " 
fi
if [ "$mode"x = "3"x ];then
echo "Mode 3"
cat $tumor | awk -F "\t" '$4 > 0 && $7 > 0' | java -jar ${varscan} copynumber --output-file ${out}.raw --mpileup 1  
fi
if [ "$mode"x = "4"x ];then
echo "Mode 4"
bash -c "java -jar ${varscan} copynumber cat $normal $tumor ${out}.raw " 
#bash -c "java -jar ${varscan} copynumber <(cat $normal | awk -F \"\\t\" '{if (\$4!=0) {print \$0}}') <(cat $tumor | awk -F \"\\t\" '{if (\$4!=0) {print \$0}}')  ${out}.raw " 
fi

echo "`date`: copycaller adjust for GC content"
java -jar ${varscan} copyCaller ${out}.raw.copynumber --output-file ${out}.raw.copynumber.called

echo "`date`: CBS by R"

R --vanilla <<END
library("DNAcopy")
cn <- read.table("${out}.raw.copynumber.called",header=T)
## optimize the marker position
pos <- round((cn[,2]+cn[,3])/2)
CNA.object <-CNA( genomdat = cn\$adjusted_log_ratio, chrom = cn[,1], maploc = pos, data.type = 'logratio', sampleid=c("$sampleName"), presorted=TRUE)
CNA.smoothed <- smooth.CNA(CNA.object)
segs <- segment(CNA.smoothed, verbose=0, min.width=2)
out=segments.p(segs)
write.table(out, file="${out}.copynumber.called.seg", row.names=F, col.names=T, quote=F, sep="\t")
END

echo "`date`: merge"
sed -i.bak '/NA/d' ${out}.copynumber.called.seg 
perl $merge ${out}.copynumber.called.seg  --ref-arm-sizes $arm --output ${out}
mv ${out}.events.tsv ${out}

rm ${out}.raw.copynumber
rm ${out}.raw.copynumber.called
rm ${out}.copynumber.called.seg
rm ${out}.raw.copynumber.called.gc
rm ${out}.copynumber.called.seg.bak

