#!/bin/bash
# https://gist.github.com/lclementi/9423594
# 
 
 
dir=`mktemp -d`
cd $dir
yumdownloader --resolve --enablerepo base,update kernel
 
dist=`rocks report distro`
version=`rocks report version`
contrib=$dist/contrib/$version/x86_64/RPMS/
cp * $contrib
cd $dist
rocks create distro
yum clean all
yum install kernel
echo --
echo -- Now you need to reboot your Frontend
echo --
echo 
echo --
echo --
echo -- After the reboot re-install all your nodes with:
echo -- rocks run host compute /boot/kickstart/cluster-kickstart-pxe
echo --
