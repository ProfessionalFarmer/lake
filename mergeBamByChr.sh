#! /bin/bash
#
# All single chr bam should be in the same directory (inputDir)
# Named by ${sampleName}.chr${i}.unique.bam
#
sampleName=$1
inputDir=$2
out=$3
input=""

for i in {1..22}
do
    input="INPUT=${inputDir}/${sampleName}.chr${i}.unique.bam ${input}"
done
input="${input} INPUT=${inputDir}/${sampleName}.chrX.unique.bam INPUT=${inputDir}/${sampleName}.chrY.unique.bam "

java -jar /data/SG/Env/software_installed/picard-tools-1.119/MergeSamFiles.jar ${input} OUTPUT=${out}

