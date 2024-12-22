#!/bin/bash

check_bzip2_compression(){
  echo "Checking bzip2 compression".................
  file_n="/tmp/archive.tar"

  if file "$file_n" | grep -q "bzip2 compressed data"; then
    echo -e "\e[32mstick_bit: Pass\e[0m\n"
  else
    echo -e "\e[31mstick_bit: Fail\e[0m\n"
  fi
}

check_selinux(){
   echo "checking selinux"...................

   selinux_chk=`curl localhost:82 2>/dev/null`
   firewall-cmd --list-ports |grep '82' &>/dev/null
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

check_journal(){
  echo "checking preserve journal".....................

  journal_dir="/var/log/journal"
  if [ -d "$journal_dir" ] && [ "$(ls -A "$journal_dir")" ]; then
    echo -e "\e[32mpersistent_journal: Pass\e[0m\n"
  else
    echo -e "\e[31mpersistent_journal: Fail\e[0m\n"
  fi
}

check_tuned_profile(){
   echo "checking tuned profile"......................

   recommended_profile=$(tuned-adm recommend)
   current_profile=$(tuned-adm active | awk -F': ' '{print $2}')

   if [ "$current_profile" == "$recommended_profile" ]; then
     echo -e "\e[32mtuned_profile: PASS\e[0m\n"
   else
     echo -e "\e[31mtuned_profile: FAIL\e[0m\n"
   fi
}

check_cron(){

   echo "checking cron".........................
   grep -q "RHCSA9" /var/log/messages
   cron_st=$?


   if [ $cron_st -eq 0 ];then
        echo -e "\e[32mcron: PASS\e[0m\n"
   else
        echo -e "\e[31mcron: FAIL\e[0m\n"

   fi

}

