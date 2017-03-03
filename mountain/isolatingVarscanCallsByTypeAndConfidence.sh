#! /bin/bash
# by Jason, create on: 2016-04-20
# 
# awk will convet a string with % to without %, E.g. 50.5% ---> 50.5
# use +0 will convert a string to number in awk


if [ "$1"x = "-h"x ];then
    echo "
Usage: script -i <INPUT> [-n 0.01] [-t 0.3] [-p 0.05] [-v 4]

This script is to Isolating Calls by Type and Confidence
#default parameter
#  -t      --min-tumor-freq - Minimum variant allele frequency in tumor 
#  -n      --max-normal-freq - Maximum variant allele frequency in normal
#  -p      --p-value - P-value for high-confidence calling 
#  --min-coverage  Minimum read depth at a position to make a call [TODO]
#  -v    Minimum supporting reads at a position to call variants 


The above command will produce 4 output files:
output.snp.Somatic.hc  (high-confidence Somatic mutations)
output.snp.Somatic.lc  (low-confidence Somatic mutations)
output.snp.Germline    (sites called Germline)
output.snp.LOH                 (sites called loss-of-heterozygosity, or LOH)
Ref: http://varscan.sourceforge.net/somatic-calling.html

"
   exit
fi

in=""
maxNormalFreq="1"
minTumorFreq="30"
pValue="0.05"
variantBase="4"

while getopts "i:t:n:p:v:" arg ## arg is option
do
    case $arg in 
        i) 
            in="$OPTARG" # arguments stored in $OPTARG
            ;;
	t)
	    minTumorFreq=`echo "$OPTARG" | awk '{print $1*100}'`
	    ;;
	n)
	    maxNormalFreq=`echo "$OPTARG" | awk '{print $1*100}'`
	    ;;
	p)
	    pValue="$OPTARG"
	    ;;
	v)
	    variantBase="$OPTARG"
	    ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done


if [ -z "$in" ];then
    echo "Please set input file by -i option"
    exit 1
else
    echo "`date`: Working $in"
fi

if [ -f $in.Somatic.hc ];then
  rm $in.Somatic.hc
fi
if [ -f $in.Somatic ];then
  rm $in.Somatic
fi
echo "chrom	position	ref	var	normal_reads1	normal_reads2	normal_var_freq	normal_gt	tumor_reads1	tumor_reads2	tumor_var_freq	tumor_gt	somatic_status	variant_p_value	somatic_p_value	tumor_reads1_plus	tumor_reads1_minus	tumor_reads2_plus	tumor_reads2_minus	normal_reads1_plus	normal_reads1_minus	normal_reads2_plus	normal_reads2_minus" > $in.Somatic.hc
head -1 $in.Somatic.hc > $in.Somatic
echo "`date`: Somatic"
cat $in | grep "Somatic" | awk -F "\t" -v inf=$in -v min=$minTumorFreq -v max=$maxNormalFreq -v p=$pValue -v v=$variantBase \
            '{if (($7+0<max)&&($11+0>min)&&($15<p)&&($10>=v)) {print $0 >> inf".Somatic.hc"} \
	    else {print $0 >> inf".Somatic"}}'


echo "`date`: Germline"
head -1 $in.Somatic.hc > $in.Germline
cat $in | grep "Germline" >> $in.Germline

echo "`date`: LOH"
head -1 $in.Somatic.hc > $in.LOH
cat $in | grep "LOH" >> $in.LOH







