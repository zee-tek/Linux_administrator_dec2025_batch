#!/bin/bash


if [ `id -u` != 0 ];then
	echo ""
	echo -e "\e[31m Failed: Please Run this Script as root\e[0m\n"
	exit 1
fi

echo "RUNNING TASK 1 ......................."
dnf remove httpd-core httpd -y -q &>/dev/null
echo "RUNNING TASK 2 ......................."

dnf install httpd-core httpd -y -q &>/dev/null

echo "RUNNING TASK 3 ......................."
systemctl start httpd &>/dev/null

echo "RUNNING TASK 4 ......................."

sed -i 's/^List.*/Listen 82/' /etc/httpd/conf/httpd.conf

echo "RUNNING TASK 5 ......................."
rm -rf /web1 &>/dev/null
mkdir /web1


echo "RUNNING TASK 6 ......................."
sed -i 's/\(^DocumentRoot.*\)/DocumentRoot "\/web1"/' /etc/httpd/conf/httpd.conf

echo "RUNNING TASK 7 ......................."
sed -i '0,/<Directory "\/var\/www">/s|<Directory "/var/www">|<Directory "/web1">|' /etc/httpd/conf/httpd.conf


echo "RUNNING TASK 8 ......................."
systemctl restart httpd &>/dev/null

echo "RUNNING TASK 9 ......................."
userdel -r linda &>/dev/null
useradd linda &>/dev/null
echo "redhat" |passwd --stdin linda &>/dev/null

echo "RUNNING TASK 10 ......................"
rm -rf  /tmp/admins &>/dev/null
rm -rf /tmp/archive.tar
rm -rf /home/linda/web /tmp/files &>/dev/null
mkdir -p /home/linda/web/html
rm -rf /tmp/files
rm -rf /var/tmp/linda
mkdir /var/tmp/linda
mkdir /tmp/files
rm -rf /var/tmp/boo_logs
rm -rf /var/tmp/string_output

echo "RUNNING TASK 10 ......................"
crontab -ru natasha &>/dev/null
userdel -r harry
userdel -r natasha
userdel -r sarah
groupdel admins
systemctl restart tuned
tuned-adm profile network-latency
systemctl restart tuned
systemctl disable tuned --now
rm -rf /var/log/journal
echo >/var/log/messages
echo "RUNNING TASK 10 ......................"
repo_dir=/etc/yum.repos.d/
find "$repo_dir" -type f -name "*.repo" -not -name "redhat.repo" -exec rm -f {} \; &>/dev/null
file=/etc/chrony.conf
sed -i '/^server/d' "$file"
dnf remove -q autofs -y &>/dev/null
s_file=/etc/sudoers
sed -i '/^%admins/d' "$file"
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 99999/' /etc/login.defs &>/dev/null

echo "RUNNING Final Task ..................."
echo "Practicing RHCSA9" > /web1/index.html
echo "Hello From myweb1 Container" >/home/linda/web/html/index.html
dnf groupremove -q "RPM Development Tools" -y &>/dev/null
echo -e "RUNNING TASK1.............."
subscription-manager repos --disable=rhel* &>/dev/null

#dnf remove chrony -q -y &>/dev/null
echo -e "RUNNING TASK3.............."
declare -A users
users=( ["user1"]=4001 ["user2"]=4002 ["user3"]=4003 )
userdel -r user1 &>/dev/null
userdel -r user2 &>/dev/null
userdel -r user3 &>/dev/null

for user in "${!users[@]}"; do
    uid=${users[$user]}
    useradd -u $uid -b /rhome -M $user >/dev/null
    #if [ $? -eq 0 ]; then
    #    echo "User $user with UID $uid created successfully."
    #else
    #    echo "Failed to create user $user with UID $uid."
    #fi
done

echo
echo -e "Exam Environment Setup Completed!\n"

echo -e "Rebooting System.................."
echo `openssl rand -base64 14`|passwd --stdin root &>/dev/null

#echo "/fake /fake_dir xfs defaults 0 0" >>/etc/fstab

shutdown -r now

