#! /bin/bash
# Modified on: 20160411  
# Require: vcf format
# For annovar, -outfile option parameter is basename, the final result is basename.hg19_multianno.csv
# Final result file is convert to TBA delimited file.
annovar="/home/qyy/src/annovar/table_annovar.pl"
converter="/home/qyy/src/annovar/convert2annovar.pl"
db="/home/qyy/src/annovar/humandb/ -buildver hg19"
in=$1
out=$2
csvXtab="python /home/zzx/bin/csvXtab.py"

if [ -z "$out" ];then
    $out=".tmp.annovar"
fi

# --includeinfo will print all information in vcf
# --withzyg  print zygosity/coverage/quality
# --withfreq print frequency information
# argument: -withfreq and -withzyg are mutually exclusive

#perl $converter -format vcf4 --withzyg $in > ${in}.avinput

# other like hgmd
perl $annovar  ${in}.avinput $db  -nastring . -outfile $out.temp  -remove -otherinfo -protocol refGene,genomicSuperDups,phastConsElements46way,esp6500siv2_all,1000g2012apr_all,1000g2014oct_all,1000g2014oct_eas,cosmic70,clinvar_20150629,avsnp142,ljb26_all,gwasCatalog -operation g,r,r,f,f,f,f,f,f,f,f,r 

#perl $annovar  ${in} $db  -nastring . -outfile $out.temp  -remove -otherinfo -protocol refGene,genomicSuperDups,phastConsElements46way,esp6500siv2_all,1000g2014oct_all,1000g2014oct_eas,cosmic70,clinvar_20150629,avsnp142,ljb26_all -operation g,r,r,f,f,f,f,f,f,f
# $csvXtab -i "$out.temp.hg19_multianno.csv" > $out

if [ "$out" == ".tmp.annovar" ];then
    cat "$out.temp.hg19_multianno.txt"
else
   cp "$out.temp.hg19_multianno.txt" "$out"
fi

rm $out.temp.*
rm ${in}.avinput

