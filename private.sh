#!/bin/bash
#Usages: $1 目标ip
#	    $2 主机名
#	    $3 临时ip
[ "$1" == "" ] && echo "Usages: $0  目标ip  主机名 临时ip" && exit
[ "$2" == "" ] && echo "Usages: $0  目标ip  主机名 临时ip" && exit
[ "$3" == "" ] && echo "Usages: $0  目标ip  主机名 临时ip" && exit
#touch /root/pcs.sh 
clear;clear
echo  '#!/bin/bash
one=$1
gate=${one%.*}.254
hostnamectl set-hostname "$2".tedu.cn
echo 1 | passwd --stdin root >/dev/null

geneth(){
one1=$1;	two1=$2;	eth=""
case $[one1+two1] in
196)
eth=0;;
194)
eth=1;;
202)
eth=2;;
203)
eth=3;;
esac

[ $eth -ne 0 ] && nmcli connection add type ethernet con-name eth$eth ifname eth$eth  > /dev/null
nmcli connection modify eth$eth ipv4.method manual ipv4.addresses $3/24  connection.autoconnect yes  > /dev/null
nmcli connection up eth$eth > /dev/null
}

geneth   ${one%%.*} `echo $one | awk -F. '"'"'{print $3}'"'"'` $one

rm -rf /etc/yum.repos.d/*
yum-config-manager --add http://$gate/rhel7  > /dev/null
echo "gpgcheck=0" >> /etc/yum.repos.d/${gate}*
yum clean all > /dev/null
yum repolist > /dev/null
#yum -y install gcc make pcre-devel openssl-devel httpd-tools
reboot

' > /root/pcs.sh
chmod 744 /root/pcs.sh


#yum -y install expect
expect << EOF
spawn scp -o StrictHostKeyChecking=no /root/pcs.sh $3:/root/

expect "password"  {send "123456\r"}
spawn ssh $3
expect "password"  {send "123456\r"}
expect "#"         {send "/root/pcs.sh $1 $2\r"}
expect "#"         {send "exit\r"}
EOF
