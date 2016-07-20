#! /bin/bash
# https://bio.kuleuven.be/eeb/lbeg/software

amy_tree="/home/zzx/software/amytree/AMY-tree_v2.0.pl"
tree_file="/home/zzx/software/amytree/UpdatedTree_v2.1.txt"
conversion_file="/home/zzx/software/amytree/MutationConversion_v2.1.txt"
y_fa="/home/zzx/ref/chrY.fa"
get_status="/home/zzx/software/amytree/getStatusReference.pl"
quality_control_file="/home/zzx/software/amytree/qualityControl_v2.0.txt"

if [ ! -f "$1" ];then
    echo "Please set a vcf path for \$1"
    exit 1
fi

if [ ! -d "$2" ];then
    mkdir  $2
fi

# temp file   $2/chrY.convert   $2/status.Y.txt
echo "`date`: convert VCF file"
cat $1 | grep -Ev "^#" | grep "chrY" | awk '{print $1"\t"$2"\t"$4"\t"$5"\t"$3}' |  sed "s#\.#x#g" > $2/chrY.convert

echo "`date`: get status"
perl ${get_status}  ${y_fa}  $2/chrY.convert  hg19 $2/status.Y.txt

echo "`date`: working"
perl $amy_tree  $2/chrY.convert  ${2}/  ${tree_file}  ${conversion_file} ${y_fa}  $2/status.Y.txt ${quality_control_file}  hg19

rm $2/chrY.convert   $2/.status.Y.txt

echo "`date`: Done"



