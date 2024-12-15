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
        echo -e "\e[31mFailed: Please Run this Script as root\e[0m\n"
        exit 1
fi
###############################################################################
dnf install sshpass -q -y &>/dev/null
pkg_ecode=$?

check_pw() {

   if [ $pkg_ecode -eq 0 ];then
      sshpass -p 'redhat' ssh -o StrictHostKeyChecking=no root@localhost 'pwd>/dev/null' &>/dev/null
      if [ $? -eq 0 ];then
        echo "Pass"
      else
        echo "Fail"
      fi
   else
     echo '"sshpass" package not installed, Please install it first'
     echo "exit 1"
   fi
}

###############################################################################
check_interface() {
    if ip link show "$1" > /dev/null 2>&1; then
       echo "Network interface $1 exists."
       return 0
    else
       echo "Network interface $1 does not exist. Please try again."
       return 1
    fi
}

# Prompt the user for the network interface name
while true; do
    read -p "Please Enter your network card name (e.g., enp0s3, ens): " n_card
    check_interface "$n_card" && break
done


################################################################################
ip_test=`nmcli con show $n_card|grep ipv4.method|awk '{print $2}'`
dnf repolist --enabled -q|egrep -v '^rhel|^repo'|grep -i app&>/dev/null
app_chk=$?
dnf repolist --enabled -q|egrep -v '^rhel|^repo'|grep -i base&>/dev/null
base_chk=$?
sed -i "/^pool.*/s/^/# /" /etc/chrony.conf &>/dev/null
chronyc sources -v |grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' >/dev/null
chrony_chk=$?

echo "Checking Ip"....................

if [ $ip_test == "manual" ];then
     
	echo "PASS"
else
	echo "FAIL"
fi


echo "Checking Root PW"....................
      check_pw
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

 
