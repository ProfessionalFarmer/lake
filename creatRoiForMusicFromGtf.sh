#! /bin/bash
# Author: Zhongxu Zhu, clone from biostar. 
# Create on: 20160915
# https://www.biostars.org/p/81170/
# Create an --roi-file for use with MuSiC, which adds 2bp flanks (for splice junctions) to each exon, and uses 1-based start and stop loci
# $1 gtf file
# output to stdout
# another method is 1. grep exon 2. use bedtools flank 3. use bedtools merge


mergebed='/home/zzx/software/bedtools2/bin/mergeBed'

perl -ne 'chomp; @c=split(/\t/); $c[3]--; $c[8]=~s/.*gene_name\s\"([^"]+)\".*/$1/; print join("\t",@c[0,3,4,8,5,6])."\n" if($c[2] eq "CDS" or $c[2] eq "exon")' $1 | sort -k1,1 -k2,2n  > .tmp.all_exon_loci.bed

# have change -nms to -c 4 -o distinct. add -delim option
# change cut 1-4 to cut 1-3,5
$mergebed -s -c 4 -o distinct -i .tmp.all_exon_loci.bed -delim ";" | perl -pe 's/;.*//' | cut -f 1-3,5 > .tmp.all_exon_loci.merged.bed

# adds 2bp flanks (for splice junctions) to each exon, and uses 1-based start and stop loci`
perl -ane '$F[1]--; $F[2]+=2; print join("\t",@F[0..3])."\n";' .tmp.all_exon_loci.merged.bed

rm .tmp.all*

