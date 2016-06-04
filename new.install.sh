#! /bin/bash
# install packages that essential while working
# accumulating always
# 装机必备？？哈

# multiple paralle gzip
apt-get install pigz

# tree package to see directory tree
apt-get install tree

# icdiff is more useful compared with diff. icdiff 的可视效果比diff好，不过比较大文件时，效率不高
# https://www.jefftk.com/icdiff
curl -s https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff | sudo tee /usr/local/bin/icdiff > /dev/null \
  && sudo chmod ugo+rx /usr/local/bin/icdiff



