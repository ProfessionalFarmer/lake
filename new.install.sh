#! /bin/bash
# install packages that essential while working
# accumulating always
# 装机必备？？哈

# browser website
sudo apt-get install w3m

# 2016-06-14
# multiple paralle gzip
sudo apt-get install pigz

# tree package to see directory tree
sudo apt-get install tree

# icdiff is more useful compared with diff. icdiff 的可视效果比diff好，不过比较大文件时，效率不高
# https://www.jefftk.com/icdiff
curl -s https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff | sudo tee /usr/local/bin/icdiff > /dev/null && sudo chmod ugo+rx /usr/local/bin/icdiff

# file manager文件管理器，方便查看文件
sudo apt-get install ranger

# more power than top command 
sudo apt-get install htop






