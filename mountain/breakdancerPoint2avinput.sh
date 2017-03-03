#! /bin/bash

if [ "$1"x = "-h"x ];then
    echo "i
Usage: script -i <INPUT> -f <FilterScore>

Description: This script will convert file from breakdancer to annovar input format.
             Support stdin and stdout.
	     Output to stdout, not a file.
             
"
   exit
fi

filter="0"
in=""

while getopts "i:f:" arg ## arg is option
do
    case $arg in 
        i) 
            in="$OPTARG" # arguments stored in $OPTARG
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
    while read line;do
	 echo "$line" | grep -Ev "^#" | awk -F "\t" -vscore="$filter" '{ if ($9>Score) {print $1"\t"$2"\t"$2"\tA\tA\n"$4"\t"$5"\t"$5"\tA\tA"} }'
    done
else                                                                                                          
         cat "$in"    | grep -Ev "^#" | awk -F "\t" -vscore="$filter" '{ if ($9>Score) {print $1"\t"$2"\t"$2"\tA\tA\n"$4"\t"$5"\t"$5"\tA\tA"} }'
fi

