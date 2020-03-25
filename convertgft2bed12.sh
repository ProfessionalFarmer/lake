#! /bin/bash
# see https://gist.github.com/gireeshkbogu/f478ad8495dca56545746cd391615b93

# How to convert GTF format into BED12 format (Human-hg19)?
# How to convert GTF or BED format into BIGBED format?
# Why BIGBED (If GTF or BED file is very large to upload in UCSC, you can use trackHubs. However trackHubs do not accept either of the formats. Therefore you would need bigBed format)

# First, download UCSC scripts
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/genePredToBed
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed

# Second, download chromosome sizes and filter out unnecessary chromosomes
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes
grep -v chrM hg19.chrom.sizes| grep -v _hap | grep -v Un_gl |grep -v random > hg19.chrom.filtered.sizes
rm hg19.chrom.sizes

# Third, make them executable
chmod +x gtfToGenePred genePredToBed bedToBigBed

# Convert Gtf to genePred
./gtfToGenePred $1 $1.genePred

# Convert genPred to bed12
./genePredToBed $1.genePred $1.bed12 && rm $1.genePred

# sort bed12
sort -k1,1 -k2,2n $1.bed12 > $1.sorted.bed && rm $1.bed12

# Convert sorted bed12 to bigBed (useful for trackhubs)
./bedToBigBed $1.sorted.bed hg19.chrom.filtered.sizes $1.bb



