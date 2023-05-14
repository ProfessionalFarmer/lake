#! /bin/bash

# https://www.biostars.org/p/477790/

annovarDir="/data0/Zhongxu/software/annovar"
fa="/data0/Zhongxu/BeeProject/ref/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
# must gtf
gtf="/data0/Zhongxu/BeeProject/ref/GCF_003254395.2_Amel_HAv3.1_genomic.gtf"
# used for -buildver in annovar
buildver="bee"
dbtype="refGene"

wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64.v369/gtfToGenePred
chmod +x gtfToGenePred 

if [ ! -d "${annovarDir}/${buildver}/" ];then
    mkdir "${annovarDir}/${buildver}"
    echo "Create directory: ${annovarDir}/${buildver}"
fi

# convert gff/gtf to genepred
./gtfToGenePred  -genePredExt $gtf ${annovarDir}/${buildver}/${buildver}_${dbtype}.txt

perl ${annovarDir}/retrieve_seq_from_fasta.pl --format refGene --seqfile $fa ${annovarDir}/${buildver}/${buildver}_${dbtype}.txt  --out ${annovarDir}/${buildver}/${buildver}_${dbtype}Mrna.fa

rm gtfToGenePred 


