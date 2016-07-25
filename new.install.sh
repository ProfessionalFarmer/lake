#! /bin/bash
# install packages that essential while working
# accumulating always
# 装机必备？？哈

if [ ! -d "~/software" ];then
    mkdir "~/software"
fi

# 2016-07-22
# bedops
cd ~/softawre/
mkdir bedops
cd bedops
wget -c https://github.com/bedops/bedops/releases/download/v2.4.19/bedops_linux_x86_64-v2.4.19.tar.bz2
tar jxvf bedops_linux_i386-v2.4.19.tar.bz2
# convert gff to bed
# ./gff2bed < ~/ref/ref_GRCh37.p5_top_level.gff3


#2016-07-21
# bcftools  http://samtools.github.io/bcftools/ 
#The most up to date (development) version of BCFtools and SAMtools can be obtained from github using these commands:
git clone --branch=develop git://github.com/samtools/htslib.git
git clone --branch=develop git://github.com/samtools/bcftools.git
git clone --branch=develop git://github.com/samtools/samtools.git
cd bcftools; make
cd ../samtools; make
#The clone command above is used to create a local copy of the remote repository and needs to be run only once. Whenever the latest snapshot from github is needed, use instead the pull command:
cd htslib; git pull
cd ../bcftools; git pull
make clean
make
cd ../samtools; git pull
make


#2016-07-15
#install useq
cd ~/software
git clone https://github.com/HuntsmanCancerInstitute/USeq.git
cd USeq
mkdir Classes
ant
# usage
#java -Xmx10G -jar /home/zzx/software/USeq/Releases/USeq_9.0.2.beta/Apps/VCFComparator -a project.NIST.hc.snps.indels.vcf -c ./NIST7035.filter.revised.vcf -g -e -p /home/zzx/test/compare/  -b shared_sure_sure.bed

#2016-06-27
# install bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz -P ~/software
tar -zxvf ~/software/bedtools-2.25.0.tar.gz
cd ~/software/bedtools2
make
ln -s ~/software/bedtools2/bin/bedtools ~/bin/bedtools
# or apt-get install bedtools

#Axel是命令行下的多线程下载工具，支持断点续传，速度通常情况下是Wget的几倍。
#下载地址：http://wilmer.gaast.net/main.php/axel.html
sudo apt-get install axel
# usage: axel -n 7 -p -o ./ url

#2016-06-16
# isntall ggplot2
sudo R
install.packages("ggplot2")
# if package is not available, run the following command line
#install.packages("lubridate", dependencies=TRUE, repos='http://cran.rstudio.com/')
# or sudo apt-get install r-cran-ggplot2
# or update R version  sudo apt-get update && sudo apt-get install r-base r-base-dev

# update date R base version 更新R版本
version=`lsb_release -c -s`
sudo echo "deb http://mirrors.aliyun.com/CRAN/bin/linux/ubuntu/ $version/" >>/etc/apt/sources.list
# Fetch the secure APT key from server
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
# Feed it to apt-key
gpg -a --export E084DAB9 | sudo apt-key add -
# 
sudo apt-get update
sudo apt-get install r-base


# 2016-06-15
# http://www.zlib.net/pigz/  A parallel implementation of gzip for modern multi-processor, multi-core machines
wget -P ~/software/ http://zlib.net/pigz/pigz-2.3.3.tar.gz
tar -xvzf ~/software/pigz-2.3.3.tar.gz
sed  -i.bak 's#-lpthread -lm#-lpthread -lm -lz#'  ~/software/pigz-2.3.3/Makefile
cd ~/software/pigz-2.3.3
make
echo -e "\nalias gzip='~/software/pigz-2.3.3/pigz'"  > ~/.bashrc
source ~/.bashrc

# file manager文件管理器，方便查看文件
sudo apt-get install ranger

# more powful than top command, interactive process viewer 
sudo apt-get install htop

# 2016-06-14
# website browser 
sudo apt-get install w3m

# 2016-06-04
# multiple paralle gzip
sudo apt-get install pigz

# tree package to see directory tree
sudo apt-get install tree

# icdiff is more useful compared with diff. icdiff 的可视效果比diff好，不过比较大文件时，效率不高
# https://www.jefftk.com/icdiff
curl -s https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff | sudo tee /usr/local/bin/icdiff > /dev/null && sudo chmod ugo+rx /usr/local/bin/icdiff







