#! /bin/bash
# install packages that essential while working
# accumulating always
# 装机必备？？哈

if [ ! -d "~/software" ];then
    mkdir "~/software"
fi

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

# more power than top command 
sudo apt-get install htop

# 2016-06-14
# browser website
sudo apt-get install w3m

# 2016-06-04
# multiple paralle gzip
sudo apt-get install pigz

# tree package to see directory tree
sudo apt-get install tree

# icdiff is more useful compared with diff. icdiff 的可视效果比diff好，不过比较大文件时，效率不高
# https://www.jefftk.com/icdiff
curl -s https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff | sudo tee /usr/local/bin/icdiff > /dev/null && sudo chmod ugo+rx /usr/local/bin/icdiff







