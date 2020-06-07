#! /bin/bash

#vcf or vcf.gz
input=''
output=''
gversion='hg38'
threads=10

while getopts "i:o:g:" arg ## arg is option
do
    case $arg in
        i)
            input="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            output="$OPTARG"
            ;;
	g)
            gversion="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done


# check
echo -e "*****************\n Note: run information is redirected to stderr\n*****************\nInput file should be vcf format with PASS variant\n"
if [[ $input == *vcf.gz  ]];then
	echo "Input format: vcf.gz (should have tbi)" 1>&2
elif [[ $input == *vcf  ]];then
	echo "Input format: vcf" 1>&2
else
	echo "Not a vcf file" 1>&2
	exit 1
fi

# check 
if [[ "$output" = "" ]];then
    echo -e "\n\nUser not specify output file. Use stdout instead\n" 1>&2
fi



annovar='/data/home/Hao/software/annovar/table_annovar.pl'
db='/data/home/Hao/software/annovar/humandb/'

rnd="`date +%s%N | md5sum | head -c 10`"
echo "`date`: Temp directory for $input: $rnd"  1>&2

mkdir -p $rnd

#-remove  remove all temporary files
$annovar $input $db -buildver $gversion -remove \
       	-protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a,cosmic89_coding,cosmic89_noncoding,clinvar_20190305 \
	-operation g,r,f,f,f,f,f,f \
	-nastring . -vcfinput -polish --thread $threads \
	-out ${rnd}/${rnd} 1>&2

if [[ "$output" = "" ]];then
        cat ${rnd}/${rnd}.${gversion}_multianno.txt
	echo "\nInvalid input\n****\n****--\n****----\n****------\n****--------\n" 1>&2
	cat ${rnd}/${rnd}.invalid_input  1>&2
else
	mv ${rnd}/${rnd}.${gversion}_multianno.txt $output
        mv ${rnd}/${rnd}.invalid_input $output.invalid_input
fi

rm -rf $rnd


