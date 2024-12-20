#!/bin/bash


: ' This Script evaluate students tasks
   - Check static 	--DONE
   - Check repos  	--DONE
   - Create autofs 	--DONE
   - check root pw 	--DONE
   - check chrony  	--DONE
   - check group   	--DONE
   - check Users   	--DONE
   - check groupinstall	--DONE
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
   
   sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
   sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
   systemctl restart sshd &>/dev/null
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
       echo -e "\nNetwork interface $1 exists.\n"
       echo -e "Running Validation\n"
       echo -e "------------------------------------------\n"
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
grp="admins"
check_grp() {

      if [ `getent group admins` ];then
        echo -e "\e[32mGroup: Pass\e[0m\n"
      else
        echo -e "\e[31mGroup: Fail\e[0m\n"
      fi
}

check_users(){

    users=("harry" "natasha" "sarah")

    all_users_exist=true

    for user in "${users[@]}"; do
      if ! id "$user" &>/dev/null; then
        #echo "User $user does not exist."
        all_users_exist=false
      fi
    done

    if [ "$all_users_exist" = true ]; then
        echo -e "\e[32mUSERS: Pass\e[0m\n"
    else
        echo -e "\e[31mUSERS: Fail\e[0m\n"
    fi
}


check_grp_membership(){
    grp="admins"
    users=("harry" "natasha")

    grp_members=true

    for user in "${users[@]}"; do
      if ! id -nG "$user" | grep -qw "$grp" &>/dev/null; then
        grp_members=false
      fi
    done

    if [ "$grp_members" = true ]; then
        echo -e "\e[32mGroup_membership: Pass\e[0m\n"
    else
        echo -e "\e[31mGroup_membership: Fail\e[0m\n"
    fi
}



check_usr_shell(){

    lg_shell=`grep sarah /etc/passwd|awk -F : '{ print $7 }'|awk -F / '{ print $NF }'`
    des_shell="nologin"
    if [ $lg_shell == $des_shell ];then
	echo -e "\e[32msarah_shell: PASS\e[0m\n"
    else
	echo -e "\e[31msarah_shell: Fail\e[0m\n"
    fi
}

chk_sudo(){
    grep "^%admins" /etc/sudoers &>/dev/null
    sudo_st=$?
    grep "^%admins" /etc/sudoers|grep "NOPASSWD" &>/dev/null
    sudo_st1=$?

    if [ $sudo_st -eq 0 ] && [ $sudo_st1 -eq 0 ];then
        echo -e "\e[32mSudo_Group: Pass\e[0m\n"
    else
        echo -e "\e[31mSudo_Group: Fail\e[0m\n"
    fi
}


check_umask(){

   des_umask="0002"
   current_umask=`su - natasha -c 'umask'`

   if [ $des_umask == $current_umask ];then
           echo -e "\e[32mUMASK: Pass\e[0m\n"
   else
           echo -e "\e[31mUMASK: Fail\e[0m\n"
   fi
}

check_special_perm(){

   dir="/tmp/admins"

    if [ -d "$dir" ]; then
    perm=$(stat -c "%A" "$dir")
    if [[ $perm == *"s"* ]]; then
        echo -e "\e[32mCollebration_DIR: Pass\e[0m\n"
    else
        echo -e "\e[31mCollebration_DIR: Fail\e[0m\n"
    fi
else
    echo -e "\e[31madmins_dir_exists: Fail\e[0m\n"
fi

}

check_special_perm2(){

   dir="/tmp/admins"

    if [ -d "$dir" ]; then
    perm=$(stat -c "%A" "$dir")
    #if [[ $perm == *"t"* ]] || [[ $perm == *"T"* ]]; then
     if [[ $perm == *"t"* ]] || [[ $perm == *"T"* ]];then
        echo -e "\e[32mstick_bit: Pass\e[0m\n"
    else
        echo -e "\e[31msticky_bit: Fail\e[0m\n"
    fi
else
    echo -e "\e[31madmins_dir_exists: Fail\e[0m\n"
fi

}

chk_max_days(){
   max_d=`grep '^PASS_MAX_DAYS' /etc/login.defs|awk '{print $2}'`

   if [ $max_d == "90" ];then
        echo -e "\e[32mmax_days: Pass\e[0m\n"
   else
        echo -e "\e[31mmax_days: Fail\e[0m\n"
   fi
}


chk_enforce_pw(){

    user_n="harry"
    chage -l "$user_n" |head -n1|grep -w 'password must be changed'&>/dev/null
    st=$?
    if [ $st -eq 0 ]; then
        echo -e "\e[32menforce_pw_change: Pass\e[0m\n"
    else
        echo -e "\e[31menforce_pw_change: Fail\e[0m\n"
    fi
}

chk_acc_exp(){

   des_exp_d=45
   chg_d=`chage -l "harry" | grep "Account expires" | awk -F ':' '{print $NF}'|sed 's/^ *//;s/ *$//'`
   if [ `date -d +${des_exp_d}days +%Y-%m-%d` == `date -d "$chg_d" +"%Y-%m-%d"` ];then 
	   echo -e "\e[32macc_exp: Pass\e[0m\n"
   else 
	   echo -e "\e[31macc_exp: Pass\e[0m\n"
   fi


}
################################################################################
chk_grp_pkg(){

   dnf grouplist --installed|grep -w "RPM Development Tools" &>/dev/null
   pk_e=$?
   
   if [ $pk_e -eq 0 ];then
	   echo -e "\e[32mgrp_pkg_install: Pass\e[0m\n"
   else
	   echo -e "\e[31mgrp_pkg_install: Fail\e[0m\n"
   fi


}
################################################################################
check_bzip2_compression(){

  file_n="/tmp/archive.tar"

  if file "$file_n" | grep -q "bzip2 compressed data"; then
    echo -e "\e[32mstick_bit: Pass\e[0m\n"
  else
    echo -e "\e[31mstick_bit: Pass\e[0m\n"
  fi
}
################################################################################
check_selinux(){
   selinux_chk=`curl localhost:82 2>/dev/null`
   firewall-cmd --list-ports |grep '85' &>/dev/null
   selinux_port=$?
   if [ "$selinux_chk" == "Practicing RHCSA9" ];then
	 echo -e "\e[32m Pass: Selinux is good, WebSite hosting on VM is accessible \e[0m\n"
   else
	 echo -e "\e[31m Fail: Selinux WebSite hosting on VM is not accessible \e[0m\n"
   fi

   if [ $selinux_port -eq 0 ];then
	 echo -e "\e[32m Pass: Selinux webserver Port is good. \e[0m\n"
   else
	 echo -e "\e[31m Fail: Selinux webserver Port is not good. \e[0m\n"
   fi
}
################################################################################
check_journal(){

  journal_dir="/var/log/journal"
  if [ -d "$journal_dir" ] && [ "$(ls -A "$journal_dir")" ]; then
    echo -e "\e[32mpersistent_journal: Pass\e[0m\n"
  else
    echo -e "\e[31mpersistent_journal: Fail\e[0m\n"
  fi
}
################################################################################
check_tuned_profile(){
   recommended_profile=$(tuned-adm recommend)
   current_profile=$(tuned-adm active | awk -F': ' '{print $2}')

   if [ "$current_profile" == "$recommended_profile" ]; then
     echo -e "\e[32mtuned_profile: PASS\e[0m\n"
   else
     echo -e "\e[31mtuned_profile: FAIL\e[0m\n"
   fi
}
################################################################################
check_cron(){


   crontab -l -u harry |grep -q '\*/1 \* \* \* \* /bin/echo hi'
   cron_st=$?


   if [ $cron_st -eq 0 ];then
        echo -e "\e[32mcron: PASS\e[0m\n"
   else
        echo -e "\e[31mcron: FAIL\e[0m\n"

   fi
   
}

################################################################################
swap_check(){

   swapon -s |egrep -q 'sdb1|vdb1'
   swp_st=$?
   swp_disk=$(swapon -s |egrep 'sdb1|vdb1' 2>/dev/null|awk -F '/' '{print $3}'|awk '{print $1}')
   add_size="512"


   if [ $swp_st -eq 0 ];then
      echo -e "swp_disk_chk: Pass"
      sw_sdb1=$(swapon -s|grep ${swp_disk}|awk '{printf $3/1023}'|awk -F "." '{print $1}')
      if [ "$sw_sdb1" == "$add_size" ]; then
          echo "swap_size_chk: Pass"
      else
          echo "swap_size_chk: Fail"
      fi
   else
          echo -e "swp_disk_chk: Fail"
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


echo "Checking Root PW"..........
      check_pw
echo "Checking Repositories"..........

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

echo "Check USERS and GROUP".................

         check_grp
         check_users
         check_grp_membership
	 check_usr_shell
	 chk_sudo
	 check_umask
	 check_special_perm
	 check_special_perm2
	 chk_max_days
	 chk_enforce_pw
	 chk_acc_exp

echo "Check Group Software Install"..........

         chk_grp_pkg

#echo "Check bzip2 Compressions"..........

#         check_bzip2_compression

#echo "check website is accessible"..........
#          check_selinux

#echo "check persistent journal"..........
#           check_journal

#echo "check tuned profile"..........
#           check_tuned_profile

#echo "check cron job"..........
#	    check_cron
#echo "check swap"..........
#        swap_check
