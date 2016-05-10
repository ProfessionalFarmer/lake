#! /bin/bash
# $1 input vcf
# $2 new sample name
# this script will change the sample name in last comment line


#line_number=`cat $1 | grep -n \#CHROM`
sed -ri "s/\tFORMAT\t.*$/\tFORMAT\t$2/" $1 

