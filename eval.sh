#!/bin/bash


: ' This Script evaluate students tasks
   - Check static --DONE
   - Check repos  --DONE
   - Create autofs --DONE
   - check root pw --DONE
   - check chrony  --DONE
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
        echo -e "\e[32mPass\e[0m\n"
      else
        echo -e "\e[31mFail\e[0m\n"
      fi
   else
     echo -e '"\e[31msshpass" package not installed, Please install it first\e[0m\n'
     echo -e "\e[31mexit 1\e[0m\n"
   fi
}

###############################################################################
check_interface() {
    if ip link show "$1" > /dev/null 2>&1; then
       echo -e "Network interface $1 exists."
       return 0
    else
       echo -e "\e[31mNetwork interface $1 does not exist. Please try again.\e[0m\n"
       return 1
    fi
}

# Prompt the user for the network interface name
while true; do
    read -p "Please Enter your network card name (e.g., enp0s3, ens): " n_card
    check_interface "$n_card" && break
done
################################################################################
user_name="user1"
validate_autofs() {
        su - $user_name -c "touch /rhome/$user_name/uniq1" &>/dev/null
        file_st=$?
        df -h|grep $user_name &>/dev/null
        mn_st=$?

        if [ $file_st -eq 0 ]&&[ $mn_st -eq 0 ];then
                echo -e "\e[32mPass\e[0m\n"
        else
                echo -e "\e[31mFail\e[0m\n"
        fi
}
	
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
     
	echo -e "\e[32mPASS\e[0m\n"
else
	echo -e "\e[31mFAIL\e[0m\n"
fi


echo "Checking Root PW"....................
      check_pw
echo "Checking Repositories"...............

if [ $app_chk -eq 0 ];then

  echo -e "\e[32mPass\e[0m\n"

else

 echo -e "\e[31mFail\e[0m\n"

fi

if [ $base_chk -eq 0 ];then

  echo -e "\e[32mPass\e[0m\n"

else

 echo -e "\e[31mFail\e[0m\n"

fi

echo "Checking Autofs".................
      validate_autofs

echo "Check Chrony"....................


systemctl restart chronyd &>/dev/null

if [ $chrony_chk -eq 0 ];then

  echo -e "\e[32mPass\e[0m\n"

else

 echo -e "\e[31mFail\e[0m\n"

fi

 
