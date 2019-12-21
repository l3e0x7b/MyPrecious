#!/bin/bash
##
## Description: An initialization script for CentOS 6 Minimal.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

clear
date=`date +%Y%m%d%H%M%S`
log_file="/var/log/init_err_${date}.log"
red_fg_prefix="\e[31m"
green_fg_prefix="\e[32m"
yello_fg_prefix="\e[33m"
magenta_fg_prefix="\e[35m"
cyan_fg_prefix="\e[36m"
fg_suffix="\e[0m"
failed_flag="${red_fg_prefix}....................[FAILED]${fg_suffix}"
ok_flag="${green_fg_prefix}....................[OK]${fg_suffix}"
skip_flag="${yello_fg_prefix}....................[SKIP]${fg_suffix}"

echo "Testing network connection..."
ping -c 4 223.5.5.5 &> /dev/null
if [[ $? -ne 0 ]]; then
	echo "Can not connect to Internet, please check network connection."
	exit
fi

echo && echo -e "${cyan_fg_prefix}####################### Task List #######################
# 1) Hostname Configuration  2) Network Configuration   #
# 3) Timezone Configuration  4) SSHD Configuration      #
# 5) EPEL Repo Configuration 6) Yum Repo Configuration  #
# 7) SELinux Configuration   8) Time Configuration      #
# 9) Tools installation      10) Vim Configuration      #
# *Tasks Check               *Reboot                    #
#########################################################${fg_suffix}" && echo

read -n 1 -p "Press any key to start: "

# exec 3>&1
# exec 1>${log_file}
exec 4>&2
exec 2>${log_file}

func_hostname () {
	echo && echo -e "${cyan_fg_prefix}#################### Hostname Configuration ####################${fg_suffix}" && echo

	hostname="localhost.localdomain"	# Can be replaced by whatever you like.

	grep "HOSTNAME" /etc/sysconfig/network | grep "${hostname}" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}Hostname is ${hostname}${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Hostname will be set to \"${hostname}\"...${fg_suffix}"
		hostname ${hostname}
		sed -i "s/^HOSTNAME=.*/HOSTNAME=${hostname}/" /etc/sysconfig/network
	fi
}

func_network () {
	echo && echo -e "${cyan_fg_prefix}#################### Network Configuration ####################${fg_suffix}" && echo

	nic=$(ls /sys/class/net/ | grep "em\|eth" | head -n1)

	grep -i "^ONBOOT=no" /etc/sysconfig/network-scripts/ifcfg-${nic} &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${magenta_fg_prefix}Network will be set to start on system boot...${fg_suffix}" && echo
		sed -i "s/^ONBOOT=no/ONBOOT=yes/i" /etc/sysconfig/network-scripts/ifcfg-${nic}
	else
		echo -e "${yello_fg_prefix}Network is configured${skip_flag}${fg_suffix}"
	fi
}

func_timezone() {
	echo && echo -e "${cyan_fg_prefix}#################### Timezone Configuration ####################${fg_suffix}" && echo

	timezone="Asia/Shanghai"	# Can be replaced by any other time zone if needed.
	ntimezone="+0800"	# Should be matched with 'timezone'.

	date +%z | grep "${ntimezone}" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}Current numeric time zone is \"{ntimezone}\"${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Time zone will be set to \"${timezone}\"...${fg_suffix}"
		ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
		sed -i "s/^ZONE=.*/ZONE=${timezone}/" /etc/sysconfig/clock
	fi
}

func_sshd() {
	echo && echo -e "${cyan_fg_prefix}#################### SSHD Configuration ####################${fg_suffix}" && echo

	grep -i "^UseDNS no" /etc/ssh/sshd_config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}SSHD is configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}The SSHD option \"UseDNS\" will be set to \"no\"...${fg_suffix}"
		sed -i "s/^#UseDNS yes/UseDNS no/i" /etc/ssh/sshd_config
		service sshd restart
	fi
}

func_epel() {
	echo && echo -e "${cyan_fg_prefix}#################### EPEL Repo Configuration ####################${fg_suffix}" && echo

	ls /etc/yum.repos.d | grep -i "epel" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}EPEL repo is installed${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Installing EPEL Repo...${fg_suffix}" && echo
		curl -so /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo

		yum clean all
		yum makecache
	fi
}

func_yum() {
	echo && echo -e "${cyan_fg_prefix}#################### Yum Repo Configuration ####################${fg_suffix}" && echo

	grep "aliyun" /etc/yum.repos.d/CentOS-Base.repo &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}Yum repo is configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}The default repo will be replaced by Aliyun Repo...${fg_suffix}"

		mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
		curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

		yum clean all
		yum makecache
	fi
}

func_selinux() {
	echo && echo -e "${cyan_fg_prefix}#################### SELinux Configuration ####################${fg_suffix}" && echo

	grep "^SELINUX=disabled" /etc/selinux/config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}SElinux is disabled${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Disabling SELinux...${fg_suffix}"
		setenforce 0
		sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	fi
}

func_ntp() {
	echo && echo -e "${cyan_fg_prefix}#################### Time Configuration ####################${fg_suffix}" && echo

	yum list installed | grep "ntpdate" &> /dev/null
	if [[ $? -eq 0 ]]; then
		grep "ntpdate" /etc/crontab &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo -e "${yello_fg_prefix}Ntpdate is installed, synchronizing system time with cn.pool.ntp.org...${fg_suffix}"
			ntpdate -u cn.pool.ntp.org
		else
			echo -e "${magenta_fg_prefix}Ntpdate is installed, setting time synchronization plan...${fg_suffix}"
			echo "0 0 1 * * root /usr/sbin/ntpdate -su cn.pool.ntp.org 2>&1 /dev/null" >> /etc/crontab
			service crond restart
		fi
	else
		echo -e "${magenta_fg_prefix}Installing ntpdate and set time synchronization plan...${fg_suffix}" && echo
	
		yum update -y && yum install -y ntpdate
		ntpdate -u cn.pool.ntp.org

		echo "0 0 1 * * root /usr/sbin/ntpdate -su cn.pool.ntp.org 2>&1 /dev/null" >> /etc/crontab
		service crond restart
	fi
}

func_tools() {
	echo && echo -e "${cyan_fg_prefix}#################### Tools installation ####################${fg_suffix}" && echo

	# Add/delete as needed
	tools="man git yum-utils yum-cron wget net-tools vim-enhanced bash-completion mlocate lrzsz tcpdump lsof"

	for tool in ${tools}; do
		yum list installed | grep "${tool}" &> /dev/null
		if [[ $? -eq 0 ]]; then
			continue
		else
			echo "${tool}" >> /tmp/tools.txt
		fi
	done

	if [[ -s /tmp/tools.txt ]]; then
		ntools=`cat /tmp/tools.txt | xargs`
		echo -e "${magenta_fg_prefix}Expected tools will be installed...${fg_suffix}" && echo
		yum update -y && yum install -y ${ntools}

		rm -f /tmp/tools.txt &> /dev/null
	else
		echo -e "${yello_fg_prefix}All expected tools are installed${skip_flag}${fg_suffix}"
	fi

	IFS_OLD=$IFS
	IFS=$'\n'';'

	# Add/delete as needed, separated by ';'.
	groups="Development tools"

	for group in ${groups}; do
		yum grouplist ${group} | grep "Installed" &> /dev/null
		if [[ $? -eq 0 ]]; then
			continue
		else
			echo "${group}" >> /tmp/groups.txt
		fi
	done

	if [[ -s /tmp/groups.txt ]]; then
		echo -e "${magenta_fg_prefix}Expected groups will be installed...${fg_suffix}" && echo

		for group in `cat /tmp/groups.txt`; do
			yum groupinstall -y ${group}
		done
		
		rm -f /tmp/groups.txt &> /dev/null
	else
		echo -e "${yello_fg_prefix}All expected groups are installed${skip_flag}${fg_suffix}"
	fi
	IFS=$IFS_OLD
}

func_vim() {
	echo && echo -e "${cyan_fg_prefix}#################### Vim Configuration ####################${fg_suffix}" && echo

	IFS_OLD=$IFS
	IFS=';'

	# Add/delete as needed, separated by ';'.
	vim_conf_list="set nocompatible;set fileformats=unix,dos;set go=;syntax on;set number;set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1;set fileencoding=utf-8;set encoding=utf-8;set shortmess=atI;autocmd InsertEnter * se cul;autocmd InsertEnter * se nocul;set completeopt=preview,menu;set tabstop=4;set softtabstop=4;set shiftwidth=4;set noexpandtab;set ignorecase;set showmatch;set matchtime=0;set wildmenu;set hlsearch;set incsearch;set noerrorbells;set backspace=indent,eol,start"

	vim_conf_list=`echo "${vim_conf_list}" | sed 's/\\*/\\\*/g'`

	for vim_conf in ${vim_conf_list}; do
		grep "^\s*${vim_conf}" /etc/vimrc &> /dev/null

		if [[ $? -eq 0 ]]; then
			continue
		else
			echo "${vim_conf}" | sed 's/\\\*/*/' >> /tmp/vimrc
		fi
	done
	IFS=$IFS_OLD

	if [[ -s /tmp/vimrc ]]; then
		echo -e "${magenta_fg_prefix}Configuring Vim...${fg_suffix}"
		cat /tmp/vimrc >> /etc/vimrc

		rm -f /tmp/vimrc
	else
		echo -e "${yello_fg_prefix}Vim is configured${skip_flag}${fg_suffix}"
	fi
}

func_check() {
	echo && echo -e "${cyan_fg_prefix}#################### Tasks Check ####################${fg_suffix}" && echo

	echo -e "${magenta_fg_prefix}[Check Hostname]${fg_suffix}"
	grep "${hostname}" /etc/sysconfig/network &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check Network]${fg_suffix}"
	grep -i "^ONBOOT=yes" /etc/sysconfig/network-scripts/ifcfg-${nic} &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check Timezone]${fg_suffix}"
	date +%z | grep "+0800" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check SSHD]${fg_suffix}"
	grep "^UseDNS no" /etc/ssh/sshd_config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check EPEL]${fg_suffix}"
	ls /etc/yum.repos.d | grep -i "epel" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check Yum]${fg_suffix}"
	grep "aliyun" /etc/yum.repos.d/CentOS-Base.repo &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check SELinux]${fg_suffix}"
	grep "^SELINUX=disabled" /etc/selinux/config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check NTP]${fg_suffix}"
	yum list installed | grep ntpdate &> /dev/null
	if [[ $? -eq 0 ]]; then
		grep "ntpdate" /etc/crontab &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo -e "${ok_flag}"
		else
			echo -e "${failed_flag}"
		fi
	else
		echo -e "${failed_flag}"
	fi

	##############################

	echo -e "${magenta_fg_prefix}[Check Tools]${fg_suffix}"
	for tool in ${tools}; do
		yum list installed | grep "${tool}" &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo -e "\t${green_fg_prefix}[${tool}]${fg_suffix}${ok_flag}"
		else
			echo -e "\t${red_fg_prefix}[${tool}]${fg_suffix}${failed_flag}"
		fi
	done

	IFS_OLD=$IFS
	IFS=';'
	for group in ${groups}; do
		yum grouplist ${group} | grep "Installed" &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo -e "\t${green_fg_prefix}[${group}]${fg_suffix}${ok_flag}"
		else
			echo -e "\t${red_fg_prefix}[${group}]${fg_suffix}${failed_flag}"
		fi
	done
	IFS=$IFS_OLD

	##############################

	echo -e "${magenta_fg_prefix}[Check Vim]${fg_suffix}"
	IFS_OLD=$IFS
	IFS=';'

	for vim_conf in ${vim_conf_list}; do
		grep "^\s*${vim_conf}" /etc/vimrc &> /dev/null

		if [[ $? -eq 0 ]]; then
			vim_conf=`echo "${vim_conf}" | sed 's/\\\\\*/*/'`
			echo -e "\t${green_fg_prefix}[${vim_conf}]${fg_suffix}${ok_flag}"
		else
			vim_conf=`echo "${vim_conf}" | sed 's/\\\\\*/*/'`
			echo -e "\t${red_fg_prefix}[${vim_conf}]${fg_suffix}${failed_flag}"
		fi
	done
	IFS=$IFS_OLD

	echo
}

func_reboot() {
	echo -e "${cyan_fg_prefix}################################################################################${fg_suffix}" && echo
	echo -e "${magenta_fg_prefix}Errors has been saved to [/var/log/init_err_${date}.log].${fg_suffix}" && echo

	read -p "All tasks completed! Reboot immediately(recommended)[Y/y] or later[Enter]? " reboot_ans

	if [[ ${reboot_ans} = "Y" || ${reboot_ans} = "y" ]]; then
		echo && echo -e "${magenta_fg_prefix}Now reboot...${fg_suffix}"
		reboot
	else
		echo && echo -e "${magenta_fg_prefix}Now exit...${fg_suffix}"
	fi
}

func_hostname
func_network
func_timezone
func_sshd
func_epel
func_yum
func_selinux
func_ntp
func_tools
func_vim
func_check

# exec 1>&3
# exec 3>&-
exec 2>&4
exec 4>&-

func_reboot