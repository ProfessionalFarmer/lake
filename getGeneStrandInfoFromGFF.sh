#! /bin/bash
# input gff file from NCBI: ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/ARCHIVE/BUILD.37.3/GFF/ref_GRCh37.p5_top_level.gff3.gz
# Gff file can also download from http://genome.ucsc.edu/cgi-bin/hgTables  use refflat

if [ -f ./.strand.tmp ];then
    rm ./.strand.tmp
fi

if [ -z "$1" ];then
    while read line; do
        echo "$line" >>  ./.strand.tmp
    done
else
    cp $1 ./.strand.tmp
fi

# remove none gene field
sed -i -n '/\tgene\t/p' .strand.tmp
# remove comment line
sed -i '/^#/d' .strand.tmp



echo -e "\n`date`: get strand info" 1>&2
cat ./.strand.tmp | cut -f 7 > ./.strand.tmp.strand1 
echo -e "`date`: get gene symbol info" 1>&2
cat ./.strand.tmp | cut -d ';' -f 2 | cut -d '=' -f 2 > ./.strand.tmp.strand2
echo -e "`date`: merge strand and gene symbol" 1>&2
paste ./.strand.tmp.strand2 ./.strand.tmp.strand1 
echo -e "`date`: Done\n" 1>&2

rm ./.strand.tmp ./.strand.tmp.strand1 ./.strand.tmp.strand2


