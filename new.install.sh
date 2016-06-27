#! /bin/bash
# install packages that essential while working
# accumulating always
# 装机必备？？哈

if [ ! -d "~/software" ];then
    mkdir "~/software"
fi

#2016-06-27
# install bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz -P ~/software
tar -zxvf ~/software/bedtools-2.25.0.tar.gz
cd ~/software/bedtools2
make
ln -s ~/software/bedtools2/bin/bedtools ~/bin/bedtools
# or apt-get install bedtools



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







