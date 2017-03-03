#! /bin/bash

sourcedir=$1
desdir=$2
# if password is not the default one, use $3 to specify your password
passwd=''

if [ -z "$3" ];then
    passwd='123456'
else
    passwd=$3
fi

echo -e "\n##########\n`date`: Start scp $1 $2\n"

# run expect
# expect can get variable by $
/usr/bin/expect <<EOF
#设置超时时间为1秒
set timeout -1
#set sourcedir [lindex $argv 0]  
#set desdir [lindex $argv 1]  

spawn scp -r $sourcedir $desdir
expect {
 #如果上一句输出"(yes/no)?"的话就自动输入yes，然后继续
 "(yes/no)?" {send "yes\r";exp_continue}
 #如果上一句输出"password"的话就自动输入密码,然后继续
 "password:" {send "$passwd\r";exp_continue}
}
#等待进程退出
wait

send_user "scp work done\n"
EOF

echo -e "\n###########\n`date`: End scp $1 $2\n"


