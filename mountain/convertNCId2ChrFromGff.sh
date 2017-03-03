#! /bin/bash
#

if [ -f ./.convert.tmp ];then
    rm ./.convert.tmp
fi

if [ -z "$1" ];then
    while read line; do
        echo "$line" >>  ./.convert.tmp
    done
else
    cp $1 ./.convert.tmp
fi


sed -i "s#NC_000001.10#chr1#g"   ./.convert.tmp
sed -i "s#NC_000002.11#chr2#g"   ./.convert.tmp
sed -i "s#NC_000003.11#chr3#g"   ./.convert.tmp
sed -i "s#NC_000004.11#chr4#g"   ./.convert.tmp
sed -i "s#NC_000005.9#chr5#g"    ./.convert.tmp
sed -i "s#NC_000006.11#chr6#g"   ./.convert.tmp
sed -i "s#NC_000007.13#chr7#g"   ./.convert.tmp
sed -i "s#NC_000008.10#chr8#g"   ./.convert.tmp
sed -i "s#NC_000009.11#chr9#g"   ./.convert.tmp
sed -i "s#NC_000010.10#chr10#g"  ./.convert.tmp
sed -i "s#NC_000011.9#chr11#g"   ./.convert.tmp
sed -i "s#NC_000012.11#chr12#g"  ./.convert.tmp
sed -i "s#NC_000013.10#chr13#g"  ./.convert.tmp
sed -i "s#NC_000014.8#chr14#g"   ./.convert.tmp
sed -i "s#NC_000015.9#chr15#g"   ./.convert.tmp
sed -i "s#NC_000016.9#chr16#g"   ./.convert.tmp
sed -i "s#NC_000017.10#chr17#g"  ./.convert.tmp
sed -i "s#NC_000018.9#chr18#g"   ./.convert.tmp
sed -i "s#NC_000019.9#chr19#g"   ./.convert.tmp
sed -i "s#NC_000020.10#chr20#g"  ./.convert.tmp
sed -i "s#NC_000021.8#chr21#g"   ./.convert.tmp
sed -i "s#NC_000022.10#chr22#g"  ./.convert.tmp
sed -i "s#NC_000023.10#chrX#g"   ./.convert.tmp
sed -i "s#NC_000024.9#chrY#g"    ./.convert.tmp
sed -i "s#NC_012920.1#chrM#g"    ./.convert.tmp


cat ./.convert.tmp | grep -Ev "^NW|^NT" 
rm ./.convert.tmp

