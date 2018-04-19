#! /bin/bash
# this only works for file not for directory

user='anonymous'
passwd=''
file=''
host=''

while getopts "f:u:p:h:" arg ## arg is option
do
    case $arg in 
        f) 
            file="$OPTARG" # arguments stored in $OPTARG
            ;;
	h) 
            host="$OPTARG" # arguments stored in $OPTARG
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

# lftp sftp://HZMDK_LYD:HZ20md17K#L11yd13@genomicscn.wuxinextcode.cn:22 -e 'mirror --verbose --use-pget-n=2 -c /data/s1021e03005_LYD_20180319_3samples'
# lftp sftp://$user:$passwd@$host:22 -e 'mirror --verbose --use-pget-n=2 -c $dir'

# run expect
# expect can get variable by $
/usr/bin/expect <<EOF
#设置超时时间为1秒
set timeout -1
#set sourcedir [lindex $argv 0]  
#set desdir [lindex $argv 1]  

spawn sftp $user@$host
expect {
 #如果上一句输出"Password: ""的话就自动输入密码，然后继续
 "* password: " {send "$passwd\r";exp_continue}
 #如果上一句输出"password"的话就自动输入密码,然后继续
 "sftp>" {send "get -r $file\r";exp_continue}
}
#等待进程退出
wait
expect "sftp>";
send "bye \r"'

send_user "sftp work done\n"
EOF

