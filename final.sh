#!/bin/bash


source final-eval.sh

while true; do

	read -p "Please select question (all or 1-19 or q to quit): " question
	echo ""
	case $question in
		1)
			check_pw
			;;
		2)
			check_IP
			;;
		3)
			check_repos
			;;
		4)
			check_chrony
			;;
		5)
			validate_autofs
			;;
		6)
			check_grp
			check_users
			check_grp_membership
			check_usr_shell
			chk_sudo
			check_umask
			;;
		7)
			check_special_perm
			check_special_perm2
			;;
		8)
			chk_max_days
			;;
		9)
			chk_enforce_pw
			chk_acc_exp
			;;
		10)


			chk_grp_pkg
			;;
		11)
			check_selinux
			;;
		12)
			check_bzip2_compression
			;;
		13)
			check_cron
			;;
		14)
			check_tuned_profile
			;;
		15)
			check_journal
			;;
		16)
			swap_check
			;;
		17)

			check_lvm1
			;;
		18)
			check_lvm2
			;;
		19)

			check_lvm3
			;;
		20)
			check_lvm4
			;;

		all)
			check_pw
			check_IP
			check_repos
			check_chrony
			validate_autofs
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
			chk_grp_pkg
			check_selinux
			check_bzip2_compression
			check_cron
			check_tuned_profile
			check_journal
			swap_check
			check_lvm
			;;
		q)
			break
			;;


	    *)
		    echo "You Did not Select valid Question number"
	esac
done

#AUTHOR: ZEESHAN ALI (MOON)
