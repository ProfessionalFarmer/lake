#! /bin/bash

sourcedir=$1
desdir=$2

echo -e "\n##########\n`date`: Start scp $1 $2\n"

# run expect
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
 "password:" {send "123456\r";exp_continue}
}
wait

send_user "scp work done\n"
EOF

echo -e "\n###########\n`date`: End scp $1 $2\n"

