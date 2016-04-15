#! /bin/bash
# Author: Jason
# Time: 20160216
# This script will merge a trio family samples' vcf file
# Merge sequence: child, father, mother
## software
#  require vcftools, and tabix and bgzip of htslib in samtools

bgzip="/usr/bin/bgzip"
tabix="/usr/bin/tabix"
vcf_merge="/usr/local/bin/vcf-merge"

f=""
m=""
c=""

while getopts "f:m:c:h" arg ## arg is option
do
    case $arg in 
        f) 
            f="$OPTARG" # arguments stored in $OPTARG
            ;;
        m)
            m="$OPTARG"
            ;;
        c)
            c="$OPTARG"
            ;;
        h)
            echo "-f father.vcf -m mother.vcf -c child.vcf"
	    exit 0
	    ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done


if [ -z "$f" ];then
    echo "Please set father's vcf file by -f option"
    exit 1
fi

if [ -z "$m" ];then
    echo "Please set mother's vcf file by -m option"
    exit 1
fi

if [ -z "$c" ];then
    echo "Please set child's vcf file by -c option"
    exit 1
fi

if [ ! -f "$f" ] || [ ! -f "$c" ] || [ ! -f "$m" ]; then
    echo "Please set file path correctly"
    exit 1
fi


$bgzip -c "$f" > "$f.gz"
$bgzip -c "$m" > "$m.gz"
$bgzip -c "$c" > "$c.gz"
$tabix -f "$f.gz"
$tabix -f "$m.gz"
$tabix -f "$c.gz"
${vcf_merge} "$c.gz" "$f.gz" "$m.gz" 
rm "$f.gz"* "$m.gz"* "$c.gz"*

echo "`date`: Done" >&2



