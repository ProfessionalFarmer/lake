#! /bin/bash
# Zhongxu
# $1 report path

line=`tail -1 "$1"`
IFS=", "
list=${line}
raw_read="" 
raw_base="" 
raw_q20="" 
raw_q30="" 
raw_gc="" 
raw_npp="" 
clean_read="" 
clean_base="" 
clean_q20="" 
clean_q30="" 
clean_gc="" 
clean_npp="" 

echo "`date`: Stat" 1>&2
for var in $list;do
   if [[ $var =~ ^102=* ]];then
       raw_read=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1132=* ]];then
       raw_base=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1134=* ]];then
       raw_q20=`echo $var | cut -d "=" -f 2 `
       raw_q20=${raw_q20:0:3}
   fi 
   if [[ $var =~ ^1135=* ]];then
       raw_q30=`echo $var | cut -d "=" -f 2 `
       raw_q30=${raw_q30:0:3}
   fi
   if [[ $var =~ ^1011=* ]];then
       raw_gc=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1012=* ]];then
       raw_npp=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^103=* ]];then
       clean_read=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1133=* ]];then
       clean_base=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1136=* ]];then
       clean_q20=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1137=* ]];then
       clean_q30=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1013=* ]];then
       clean_gc=`echo $var | cut -d "=" -f 2 `
   fi
   if [[ $var =~ ^1014=* ]];then
       clean_npp=`echo $var | cut -d "=" -f 2 `
   fi
done

##################
echo -e "Raw Data Statistic" 
echo -e "Sample\tLength\tReads\tBases\tQ20(%)\tQ30(%)\tGC(%)\tN(ppm)"
echo -e "$1\t$raw_read\t$raw_base\t$raw_q20\t$raw_q30\t$raw_gc\t$raw_npp"  |  awk -F "\t"  '{printf ("%s\t150\t%.0f\t%.0f\t%.1f\t%.1f\t%.1f\t%.2f\n\n",$1,$2,$3,$4/10,$5/10,$6/10,$7/100) }' 

##################
echo -e "Clean Data Statistic" 
echo -e "Sample\tLength\tReads\tBases\tQ20(%)\tQ30(%)\tGC(%)\tN(ppm)" 
echo -e "$1\t$clean_read\t$clean_base\t$clean_q20\t$clean_q30\t$clean_gc\t$clean_npp"  |  awk -F "\t"  '{printf ("%s\t%.1f\t%.0f\t%.0f\t%.1f\t%.1f\t%.1f\t%.2f\n\n",$1,$3/$2,$2,$3,$4/10,$5/10,$6/10,$7/100) }' 

##################
echo -e "Trim Ratio" 
echo -e "Raw Reads\tClean Reads\tRatio of Reads (%)\tRaw Bases\tClean Bases\tRatio of Bases(%)" 
echo -e "$raw_read\t$clean_read\t$raw_base\t$clean_base" |  awk -F "\t" '{printf ("%.0f\t%.0f\t%.2f\t%.0f\t%.0f\t%.2f\n\n",$1,$2,$2/$1*100,$3,$4,$4/$3*100) }' 

##################
total_read=`cat $1   | sed -n '20,45p' | cut -f 2 | awk -F "\t"  '{a=a+$1}END{print a}'`
total_mapped=`cat $1 | sed -n '20,45p' | cut -f 3 | awk -F "\t" '{a=a+$1}END{print a}'`
unmapped=`echo -e "$total_read\t$total_mapped"   | awk -F "\t"  '{print $1-$2}'`
secondary_read=`echo -e "$total_read\t$clean_read"   | awk -F "\t"  '{print $1-$2}'`

single_mapped=`echo -e "$clean_read\t$unmapped" | awk -F "\t"  '{print $1-$2}'`
uniq_mapped=`echo -e "$single_mapped\t$secondary_read" | awk -F "\t"  '{print $1-$2}'`

echo -e "Mapping Statistic" 
echo -e "Total Reads\tReads mapped to genome\tMapped Reads Ratio(%)\tUniq Reads\tUniq Reads Ratio(%)" 
echo -e "$clean_read\t$single_mapped\t$uniq_mapped" | awk -F "\t" '{printf("%.0f\t%.0f\t%.2f\t%.0f\t%.2f\n\n",$1,$2,$2/$1*100,$3,$3/$1*100) }' 

##################
covered_base=`head -17 "$1" | tail -1 | cut -f 2`
genome_base="3137161264"
mean_depth=`head -18 "$1" | tail -1 | cut -f 6`
echo -e "Coverage Statistic" 
echo -e "Genome Bases\tCovered Bases\tCoverage(%)\tMean depth of mapped region"
echo -e "$genome_base\t$covered_base\t$mean_depth" | awk -F "\t" '{printf("%.0f\t%.0f\t%.2f\t%.2f\n\n",$1,$2,$2/$1*100,$3)}' 

IFS="\t"



