#!/bin/bash

source min-eval.sh

if [ `id -u` != 0 ];then
        echo ""
        echo -e "\e[31mFailed: Please Run this Script as root\e[0m\n"
        exit 1
fi


check_bzip2_compression

check_journal

check_tuned_profile

check_cron

