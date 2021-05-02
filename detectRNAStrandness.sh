#! /bin/bash

# rseqc tools infer-experiment.py
# http://rseqc.sourceforge.net/#infer-experiment-py

# Input alignment file in SAM or BAM format
BAM=$1
# Reference gene model in bed fomat
BED=$2

infer-experiment-py -i $BAM -r $BED -s 500000


