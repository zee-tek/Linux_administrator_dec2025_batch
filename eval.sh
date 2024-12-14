#!/bin/bash


: ' This Script evaluate students tasks
   - Check static
   - Check repos
   - Create autofs
   - check root pw
   - check chrony
  '


if [ `id -u` != 0 ];then
        echo ""
        echo -e "\e[31m Failed: Please Run this Script as root\e[0m\n"
        exit 1
fi



ip_test=`nmcli con show enp0s3|grep ipv4.method|awk '{print $2}'`
dnf repolist --enabled -q|egrep -v '^rhel|^repo'|grep -i app&>/dev/null
app_chk=$?
dnf repolist --enabled -q|egrep -v '^rhel|^repo'|grep -i base&>/dev/null
base_chk=$?
sed -i "/^pool.*/s/^/# /" /etc/chrony.conf &>/dev/null
chronyc sources -v |grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}'
chrony_chk=$?

echo "Checking Ip"....................

if [ $ip_test == "manual" ];then
     
	echo "PASS"
else
	echo "FAIL"
fi

echo "Checking Repositories"...............

if [ $app_chk -eq 0 ];then

  echo "Pass"

else

 echo "Fail"

fi

if [ $base_chk -eq 0 ];then

  echo "Pass"

else

 echo "Fail"

fi

echo "Check Chrony"....................


systemctl restart chronyd &>/dev/null

if [ $chrony_chk -eq 0 ];then

  echo "Pass"

else

 echo "Fail"

fi

 
