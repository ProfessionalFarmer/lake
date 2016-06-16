#! /bin/bash
# uniq 命令，不能同时重复和非重复


if [ -f "./.line.repeat.num.tmp" ];then
    rm "./.line.repeat.num.tmp"
fi

while read line; do
   echo -e "$line" >> "./.line.repeat.num.tmp"
done

cat "./.line.repeat.num.tmp" | awk '{a[$0]++}\
	END{for (i in a )\
	    print a[i]"\t"i
	}' | sort -n -r -k 1

rm "./.line.repeat.num.tmp"


