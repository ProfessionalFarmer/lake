#! /bin/bash
# Author: zzx
# Created on: 20160822 Modifyied on: 20160823

oncodb="/home/zzx/software/oncotator/oncotator_v1_ds_Jan262014"
oncodir="/home/zzx/software/oncotator"

vcf=""
maf=""
tumor_name=""
normal_name="normal"

# more option should be added
while getopts "i:o:t:n" arg ## arg is option
do
    case $arg in 
        i) 
            vcf="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            maf="$OPTARG"
            ;;
        t)  
            tumor_name="$OPTARG"
            ;;
        n)  
            normal_name="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$vcf" ] || [ -z "$tumor_name" ] || [ -z "$maf" ];then
    echo -e '-i option for vcf; \n-t option for tumor sample name; \n-o option for maf output path; \n-n option for normal sample name'
    exit 1
fi


source $oncodir/env/bin/activate
# WGS = whole genome sequencing, WXS = whole exome sequencing
oncotator --input_format=VCF --db-dir=$oncodb \
 --output_format=TCGAMAF --tx-mode=EFFECT --collapse-number-annotations \
 --annotate-default='Sequencer:Illumina HiSeq' \
 --annotate-manual='Sequence_Source:WGS' \
 --annotate-manual="Tumor_Sample_Barcode:${tumor_name}" \
 --annotate-manual="Matched_Norm_Sample_Barcode:$normal_name" \
 $vcf $maf hg19

deactivate



<<BLOCK
安装oncotator
安装python virtualenv
curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-14.0.6.tar.gz
tar -xvzf virtualenv-14.0.6.tar.gz 
cd virtualenv-14.0.6/
python setup.py install --prefix=~/pypackages/
cd ..
rm -rf virtualenv-14.0.6*

安装oncotator依赖
mkdir ~/software/oncotator/env
git clone  https://github.com/broadinstitute/oncotator.git
cd oncotator
bash scripts/create_oncotator_venv.sh -e ~/software/oncotator/env

下载注释数据文件
wget -c http://www.broadinstitute.org/~lichtens/oncobeta/oncotator_v1_ds_Jan262015.tar.gz
tar -xvzf  oncotator_v1_ds_Jan262015.tar.gz

安装oncotator
source ~/software/oncotator/env/bin/activate
python setup.py install
deactivate 
BLOCK


