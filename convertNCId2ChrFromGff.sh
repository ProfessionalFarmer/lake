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


sed -i "s#NC_000001.10#Chr1#g"   ./.convert.tmp
sed -i "s#NC_000002.11#Chr2#g"   ./.convert.tmp
sed -i "s#NC_000003.11#Chr3#g"   ./.convert.tmp
sed -i "s#NC_000004.11#Chr4#g"   ./.convert.tmp
sed -i "s#NC_000005.9#Chr5#g"    ./.convert.tmp
sed -i "s#NC_000006.11#Chr6#g"   ./.convert.tmp
sed -i "s#NC_000007.13#Chr7#g"   ./.convert.tmp
sed -i "s#NC_000008.10#Chr8#g"   ./.convert.tmp
sed -i "s#NC_000009.11#Chr9#g"   ./.convert.tmp
sed -i "s#NC_000010.10#Chr10#g"  ./.convert.tmp
sed -i "s#NC_000011.9#Chr11#g"   ./.convert.tmp
sed -i "s#NC_000012.11#Chr12#g"  ./.convert.tmp
sed -i "s#NC_000013.10#Chr13#g"  ./.convert.tmp
sed -i "s#NC_000014.8#Chr14#g"   ./.convert.tmp
sed -i "s#NC_000015.9#Chr15#g"   ./.convert.tmp
sed -i "s#NC_000016.9#Chr16#g"   ./.convert.tmp
sed -i "s#NC_000017.10#Chr17#g"  ./.convert.tmp
sed -i "s#NC_000018.9#Chr18#g"   ./.convert.tmp
sed -i "s#NC_000019.9#Chr19#g"   ./.convert.tmp
sed -i "s#NC_000020.10#Chr20#g"  ./.convert.tmp
sed -i "s#NC_000021.8#Chr21#g"   ./.convert.tmp
sed -i "s#NC_000022.10#Chr22#g"  ./.convert.tmp
sed -i "s#NC_000023.10#ChrX#g"   ./.convert.tmp
sed -i "s#NC_000024.9#ChrY#g"    ./.convert.tmp
sed -i "s#NC_012920.1#ChrM#g"    ./.convert.tmp


cat ./.convert.tmp | grep -Ev "^NW|^NT" 
rm ./.convert.tmp

