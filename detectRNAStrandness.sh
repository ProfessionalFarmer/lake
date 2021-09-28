#! /bin/bash

# rseqc tools infer-experiment.py
# http://rseqc.sourceforge.net/#infer-experiment-py

# 1++,1–,2+-,2-+
#read1 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand

# 1+-,1-+,2++,2–
#read1 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand


# Input alignment file in SAM or BAM format
BAM=$1
# Reference gene model in bed fomat
BED=$2

infer_experiment.py -i $BAM -r $BED -s 5000000


