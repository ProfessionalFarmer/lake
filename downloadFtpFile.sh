#! /bin/bash

user='anonymous'
passwd=''
file=''

while getopts "f:u:p:" arg ## arg is option
do
    case $arg in 
        f) 
            file="$OPTARG" # arguments stored in $OPTARG
            ;;
        u)
            user="$OPTARG"
            ;;
        p)
            passwd="$OPTARG"
	    ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z "$file" ];then
    echo "please set file path in ftp server"
    exit 1
fi 

# -m download subdirectory
# -nH no hostname directory generate
# -T wait time 
# -r recursive 
# -np do not download parent folder
# --cut-dirs do not create many dir 
# --level

wget -r --cut-dirs 4 -m -nH -np -P ./ -T 10 "ftp://$user:$passwd@$file" 



