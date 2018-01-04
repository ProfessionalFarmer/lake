#! /bin/bash

bam=$1
geneBedDir=$2
ref='/share/apps/reference/hg19/ucsc.hg19.fasta'
gatk='/share/apps/GenomeAnalysisTKLite-2.3-9-gdcdccbb/GenomeAnalysisTKLite.jar'
# jdk7
export JAVA_HOME=$JAVA7_HOME && export JRE_HOME=$JAVA_HOME/jre && export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH && export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
for fn in `ls "$geneBedDir"/*`; do
    gene="`echo $fn | awk -F '/' '{print $NF}' | cut -f 1 -d '.'  `"
    java -jar $gatk  -T CallableLoci -R $ref -I $bam -L $fn  \
        --minDepth 20 --minMappingQuality 20 --minBaseQuality 20 \
        --summary $bam.gene.callable.summary.txt \
        -o $bam.gene.callable.stat.txt >/dev/null 
    # merge
    cat $bam.gene.callable.stat.txt >> $bam.gene.callable.summary.txt
    echo -n -e "$gene"
    # total length and callalable bases
    sed -n '3,7p' $bam.gene.callable.summary.txt | awk '{a[NR]=$2;b=$2+b}END{printf(",%d,%.2f%"),b,a[1]/b*100}'
    # NO_COVERAGE 
    sed -n '3,7p' $bam.gene.callable.summary.txt | awk '{a[NR]=$2;b=$2+b}END{printf(",%.2f%"),a[2]/b*100}'
    # LOW_COVERAGE
    sed -n '3,7p' $bam.gene.callable.summary.txt | awk '{a[NR]=$2;b=$2+b}END{printf(",%.2f%"),a[3]/b*100}'
    # EXCESSIVE_COVERAGE
    sed -n '3,7p' $bam.gene.callable.summary.txt | awk '{a[NR]=$2;b=$2+b}END{printf(",%.2f%"),a[4]/b*100}'
    # POOR_MAPPING_QUALITY
    sed -n '3,7p' $bam.gene.callable.summary.txt | awk '{a[NR]=$2;b=$2+b}END{printf(",%.2f%"),a[5]/b*100}'
    # remove 
    rm $bam.gene.callable.stat.txt $bam.gene.callable.summary.txt
    echo -n -e "\n"
done

# end



