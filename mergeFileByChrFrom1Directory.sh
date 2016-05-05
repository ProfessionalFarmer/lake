#! /bin/bash
# Create on: 20160429
# -d directory -o out -h no header

dir=""
header="1"
out=""
tmpfile=".merge.tmp"


chr_order="chrM\nchr1\nchr2\nchr3\nchr4\nchr5\nchr6\nchr7\nchr8\nchr9\nchr10\nchr11\nchr12\nchr13\nchr14\nchr15\nchr16\nchr17\nchr18\nchr19\nchr20\nchr21\nchr22\nchrX\nchrY"

while getopts "d:o:h" arg ## arg is option
do
    case $arg in 
        d) 
            $dir="$OPTARG" # arguments stored in $OPTARG
            ;;
        h)
            header=""
            echo "Please not: you have set -h option, which means your file does not have header"
            ;;
        o)
            out=""
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$dir" ];then
    echo "Please set input directory"
    exit 1
fi

if [ -f $tmpfile ];then
    rm $tmpfile
fi

if [ ! -z "$header" ];then
    head -1 `bash -c "ls ${dir}/*.chr1.* | head -1"` > $tmpfile
fi


echo -e $chr_order | while read line
do
    chr_path=`bash -c "ls ${dir}/*.$line.* | head -1"`
    if [ ! -z "$header" ];then
        cat $chr_path   >>  $tmpfile
    fi
done

if [ -z "$out" ];then
    cat $tmpfile  && rm $tmpfile
else
    mv $tmpfile $out
fi





