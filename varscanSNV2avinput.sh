#! /bin/bash
# Created  on: 20160117
# Modified on: 20160119


if [ "$1"x = "-h"x ];then
    echo "
Usage: script -i <INPUT> -o <OUTPATH> -f <FILTERTAG>

Description: This script will convert file from varscan to annovar format.
             Support stdin and stdout.
	     
	     Please note the filter tag. Default Germline will be filterd. 
"
   exit
fi

#filter="Germline|_hap|Un_g|_random"
filter="asdf"
in=""
out=""

while getopts "i:o:f:" arg ## arg is option
do
    case $arg in 
        i) 
	    in="$OPTARG" # arguments stored in $OPTARG
	    ;;
	o)
	    out="$OPTARG"
	    ;;
	f)
	    filter="$OPTARG"	
	    ;;
	?)
	    echo "unkonw argument"
	    exit 1
	esac
done


if [ -z "$in" ];then
    if [ -z "$out" ];then
        while read line;do
	   echo "$line" | grep -Ev "$filter|^#" | awk -F "\t" '$1!~/^chrom/ { \
		if (match($4,"-")!=0)       {sub("-","",$4); l=length($4); print $1"\t"$2+1"\t"$2+l"\t"$4"\t-\t"$13"\t"$11} \
		else if (match($4,"\+")!=0) {sub("\+","",$4);l=length($4); print $1"\t"$2"\t"$2"\t-\t"$4"\t"$13"\t"$11} \
		else {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$13"\t"$11} \
		}'
	done
    else
	if [ -f "$out" ];then
	    rm "$out"
	fi                                                             
	while read line;do                                                              
            echo "$line" | grep -Ev "$filter|^#" | awk -F "\t" '$1!~/^chrom/ { \
                if (match($4,"-")!=0)       {sub("-","",$4); l=length($4); print $1"\t"$2+1"\t"$2+l"\t"$4"\t-\t"$13"\t"$11} \
                else if (match($4,"\+")!=0) {sub("\+","",$4);l=length($4); print $1"\t"$2"\t"$2"\t-\t"$4"\t"$13"\t"$11} \
                else {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$13"\t"$11} \
                }'  >> "$out"
        done
    fi
else
    if [ -z "$out" ];then                                                                                                           
        cat "$in" | grep -Ev "$filter|^#" | awk -F "\t" '$1!~/^chrom/ { \
                if (match($4,"-")!=0)       {sub("-","",$4); l=length($4); print $1"\t"$2+1"\t"$2+l"\t"$4"\t-\t"$13"\t"$11} \
                else if (match($4,"\+")!=0) {sub("\+","",$4);l=length($4); print $1"\t"$2"\t"$2"\t-\t"$4"\t"$13"\t"$11} \
		else {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$13"\t"$11} \
		}'   
    else
        cat "$in" | grep -Ev "$filter|^#" | awk  -F "\t" '$1!~/^chrom/ { \
                if (match($4,"-")!=0)       {sub("-","",$4); l=length($4); print $1"\t"$2+1"\t"$2+l"\t"$4"\t-\t"$13"\t"$11} \
                else if (match($4,"\+")!=0) {sub("\+","",$4);l=length($4); print $1"\t"$2"\t"$2"\t-\t"$4"\t"$13"\t"$11} \
                else {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$13"\t"$11} \
                }'   > "$out"
    fi
fi


