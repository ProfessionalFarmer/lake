#! /bin/bash
# copy from https://hub.docker.com/r/bowhan/smrtanalysis-2.3.0.140936/

# docker pull bowhan/smrtanalysis-2.3.0.140936
# docker run -it -v /home/bowhan/myData:/data bowhan/smrtanalysis-2.3.0.140936 bash

# it option creates an interactive shell inside of the container
# -v option mount host directory to a directory inside of the container
# /home/bowhan/myData is where you store your data (i.e., h5 files)
# /data is the directory mounted inside the container
# this is the old analysis pipeline. Isoseq3 is available https://github.com/PacificBiosciences/IsoSeq3/blob/master/README_v3.1.md, correspond SMRT Analysis 7.

# invoke smrtshell, which prepares the enviroment for smrtanalysis
/opt/smrtanalysis/current/smrtcmds/bin/smrtshell
# run specific analysis; for example, to run iso-seq
# 1. generate CCS from h5 files, whose names are stored in a fofn (file of file names)

# $1 input fofn and $2 output directory
ConsensusTools.sh CircularConsensus  \
    --minFullPasses 0  --minPredictedAccuracy 75 \
    --parameters /opt/smrtanalysis/install/smrtanalysis_2.3.0.140936/analysis/etc/algorithm_parameters/2014-09/ \
    --numThreads 8 --fofn $1 \
    -o $2

# 2. run Iso-Seq classify
pbtranscript.py classify \
    --cpus 8 --min_seq_len 300 \
    --flnc $2/isoseq_flnc.fasta \
    --nfl $2/isoseq_nfl.fasta \
    -d $2/out \
    $2/ccs.fa \
    $2/isoseq_draft.fasta

# 3. run iso-seq cluster
pbtranscript.py cluster \
    $2/isoseq_flnc.fasta $2/final.consensus.fa \
    --nfl_fa $2/isoseq_nfl.fasta -d $2/clusterOut \
    --ccs_fofn $2/reads_of_insert.fofn --bas_fofn $1 \
    --cDNA_size under1k --quiver --blasr_nproc 8 \
    --quiver_nproc 8

 
