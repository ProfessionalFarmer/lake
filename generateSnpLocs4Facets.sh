#! /bin/bash
#$1 ~/ref/hg38/dbsnp_146.hg38.vcf 
#$2 ~/ref/agilent/hg38v7/S31285117_Regions.bed| head

out=$3
rm $3/snploc*
echo "Start at `date`"
bedtools intersect -a $1 -b $2 | \
	# chr pos rs ref alt
	cut -f 1-5 | \
	# consider snp
	awk '{if(length($5)==length($4)){print}}' | \
	# consider pos
	cut -f 1,2 | \
	# redirect
        awk '{print $2 >> "'$out'""/snplocs"$1}'	
echo "End at `date`"






