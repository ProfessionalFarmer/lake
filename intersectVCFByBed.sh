#! /bin/bash
# 2018-01-23
# bash sh -v vcf -b bed  > file
bed=''
vcf=''
bdt='/share/apps/bin/bedtools'
gf='/share/apps/reference/hg19/bedtools.genome.file'


while getopts "v:b:" arg ## arg is option
do
    case $arg in
        b)
            bed="$OPTARG"
            ;;
        v)
            vcf="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

# check options
if [[ ! -f "$vcf" || ! -f "$bed" ]];then
    echo "Please set vcf file path by -v and set bed file path by -b option"
    exit 1
fi

# ./aa.bb.cc  ---> aa
tmp="`echo $vcf | awk -F '/' '{print $NF}' `" | cut -f 1 -d '.' 

cat $vcf | grep '#' > .$tmp.bedtools.intersect
$bdt intersect -a $vcf -b $bed -wa -sorted -g $gf >> .$tmp.bedtools.intersect
cat .$tmp.bedtools.intersect && rm .$tmp.bedtools.intersect





