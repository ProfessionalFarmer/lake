#! /bin/bash
#
# Input and ouput file path are required
# Default filter score: 70
#

in=$1
out=$2
filterScore=70
if [ ! -z $3 ];then
    filterScore=$3
fi
# echo "generate cfg file"
/data/SG/Env/software_installed/breakdancer/perl/bam2cfg.pl ${in} > "${in}.cfg"
# echo "-y: filter by score"
/data/SG/Env/software_installed/breakdancer/build/bin/breakdancer-max -y "$filterScore ${in}.cfg" > ${out}

#cat ${out} | grep -Ev "^#" | awk -vScore="$filterScore" '{ if ($9>Score) { print $0} }' > "${out}.filter${filterScore}-sv.sv"
