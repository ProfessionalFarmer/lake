#! /bin/bash
# 转换VCF文件
# $1 vcf
# #2 rs.list
# output file name
# depend: convertVCF223andme.py searchStrInSpecificColomn.py   dbsnp_138.hg19.vcf  sortVCFByChrPos.sh

# VCF转为23andme
python ~/bin/convertVCF223andme.py --input $1 --output tmp.test.txt > tmp.test.txt
# 通过23andme文件中的rs位点查找
python ~/bin/searchStrInSpecificColomn.py -r $2 -c 1 -i tmp.test.txt > .tmp.1.txt
# 得到1文件中的rs位点，便于查找没有出现的rs位点
cut -f 1 .tmp.1.txt > .tmp.1.rs.txt
# 寻找不在1.txt中，但在23andme中的点
python ~/bin/searchStrInSpecificColomn.py -r .tmp.1.rs.txt -c 1 -i $2 -b | cut -f 1 > .tmp.2.rs.txt
# 寻找不在1.txt中，但在23andme中的点的参考基因型
python ~/bin/getRefGenotypeFromdbSNPVCFIn23andmeFormat.py -i /data/SG/Env/reference_data/dbsnp_138.hg19.vcf -o .dbsnp138
python ~/bin/searchStrInSpecificColomn.py -r .tmp.2.rs.txt -c 1 -i .dbsnp138 | awk '{print $1"\tchr"$2"\t"$3"\t"$4}'  > .tmp.2.txt
#合并
cat .tmp.1.txt .tmp.2.txt | sort -k 3,3n > tmp.sample.txt
rm .tmp.1.txt .tmp.2.txt 
bash ~/bin/sortVCFByChrPos.sh tmp.sample.txt  | sed "s#chr##g" | sort -k 2,2n -k 3,3n > $3
rm  tmp.sample.txt  .dbsnp138   tmp.test.txt


