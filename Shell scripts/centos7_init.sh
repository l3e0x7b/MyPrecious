#!/bin/bash

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
# 5) Yum Repo Configuration  6) EPEL Repo Configuration #
# 7) SELinux Configuration   8) Time Configuration      #
# 9) Tools installation      10) VIM Configuration      #
# *Tasks Check               *Reboot                    #
#########################################################${fg_suffix}" && echo

read -n 1 -p "Press any key to start: "

# exec 3>&1
# exec 1>${log_file}
exec 4>&2
exec 2>${log_file}

func_hostname () {
	echo && echo -e "${cyan_fg_prefix}#################### Hostname Configuration ####################${fg_suffix}" && echo

	hostname="localhost.localdomain"
	grep "${hostname}" /etc/hostname &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}Hostname is ${hostname}${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Hostname will be set to \"${hostname}\"...${fg_suffix}"
		hostnamectl set-hostname ${hostname}
	fi
}

func_network () {
	echo && echo -e "${cyan_fg_prefix}#################### Network Configuration ####################${fg_suffix}" && echo

	nic=$(ls /sys/class/net/ | grep "en\|eth" | head -n1)
	grep -i "^ONBOOT=no" /etc/sysconfig/network-scripts/ifcfg-${nic} &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${magenta_fg_prefix}Network will be set to start on system boot...${fg_suffix}" && echo
		sed -i "s/^ONBOOT=no/ONBOOT=yes/i" /etc/sysconfig/network-scripts/ifcfg-${nic}
	else
		echo -e "${yello_fg_prefix}Network already configured${skip_flag}${fg_suffix}"
	fi
}

func_timezone() {
	echo && echo -e "${cyan_fg_prefix}#################### Timezone Configuration ####################${fg_suffix}" && echo

	timezone="Asia/Shanghai"
	timezone_old=`timedatectl | grep "Time zone" | awk '{print $3}'`
	if [ "${timezone_old}" = "${timezone}" ]; then
		echo -e "${yello_fg_prefix}Current timezone is \"${timezone}\"${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Timezone will be set to \"${timezone}\"...${fg_suffix}"
		timedatectl set-timezone Asia/Shanghai
	fi
}

func_sshd() {
	echo && echo -e "${cyan_fg_prefix}#################### SSHD Configuration ####################${fg_suffix}" && echo

	grep -i "^UseDNS no" /etc/ssh/sshd_config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}SSHD already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}The sshd option \"UseDNS\" will be set to \"no\"...${fg_suffix}"
		sed -i "s/^#UseDNS yes/UseDNS no/i" /etc/ssh/sshd_config
	fi
}

func_epel() {
	echo && echo -e "${cyan_fg_prefix}#################### EPEL Repo Configuration ####################${fg_suffix}" && echo

	ls /etc/yum.repos.d | grep -i "epel" &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}EPEL repo already installed${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Installing EPEL Repo...${fg_suffix}" && echo
		curl -so /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

		yum clean all
		yum makecache
	fi
}

func_yum() {
	echo && echo -e "${cyan_fg_prefix}#################### Yum Repo Configuration ####################${fg_suffix}" && echo

	grep -i "aliyun" /etc/yum.repos.d/CentOS-Base.repo &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}Yum repo already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}The default repo will be replaced by Aliyun Repo...${fg_suffix}"

		mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
		curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

		yum clean all
		yum makecache
	fi
}

func_selinux() {
	echo && echo -e "${cyan_fg_prefix}#################### SELinux Configuration ####################${fg_suffix}" && echo

	grep "^SELINUX=disabled" /etc/selinux/config &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${yello_fg_prefix}SElinux already disabled${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Disabling SELinux...${fg_suffix}"
		sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	fi
}

func_ntp() {
	echo && echo -e "${cyan_fg_prefix}#################### Time Configuration ####################${fg_suffix}" && echo

	ntpdatestat=$(yum info ntpdate | grep "Repo" | awk '{print $3}')

	if [ "${ntpdatestat}" = "installed" ]; then
		echo -e "${yello_fg_prefix}Ntpdate already installed, synchronizing system time with cn.pool.ntp.org...${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Installing ntpdate and set time synchronization plan...${fg_suffix}" && echo
	
		yum install -y ntpdate
		ntpdate -u cn.pool.ntp.org

		echo "0 0 1 * * root /usr/sbin/ntpdate -u cn.pool.ntp.org 2>&1 /dev/null" >> /etc/crontab
		systemctl restart crond
	fi
}

func_tools() {
	echo && echo -e "${cyan_fg_prefix}#################### Tools installation ####################${fg_suffix}" && echo

	tools="git yum-utils yum-cron wget net-tools vim-enhanced bash-completion mlocate lrzsz tcpdump lsof"
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

	# separated by ";"
	groups="Development Tools"

	for group in ${groups}; do
		yum group list installed | grep "${group}" &> /dev/null
		if [[ $? -eq 0 ]]; then
			continue
		else
			echo "${group}" >> /tmp/groups.txt
		fi
	done

	if [[ -s /tmp/groups.txt ]]; then
		echo -e "${magenta_fg_prefix}Expected groups will be installed...${fg_suffix}" && echo

		for group in `cat /tmp/groups.txt`; do
			yum group install -y ${group}
		done
		
		rm -f /tmp/groups.txt &> /dev/null
	else
		echo -e "${yello_fg_prefix}All expected groups are installed${skip_flag}${fg_suffix}"
	fi
	IFS=$IFS_OLD
}

func_vim() {
	echo && echo -e "${cyan_fg_prefix}#################### VIM Configuration ####################${fg_suffix}" && echo

	IFS_OLD=$IFS
	IFS=';'

	# separated by ";"
	vim_conf_list="set nocompatible;set fileformats=unix,dos;set go=;syntax on;set number;set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1;set fileencoding=utf-8;set encoding=utf-8;set shortmess=atI;autocmd InsertEnter * se cul;autocmd InsertEnter * se nocul;set completeopt=preview,menu;set tabstop=4;set softtabstop=4;set shiftwidth=4;set noexpandtab;set ignorecase;set showmatch;set matchtime=0;set wildmenu;set hlsearch;set incsearch;set noerrorbells;set backspace=indent,eol,start"

	for vim_conf in ${vim_conf_list}; do
		grep -F "${vim_conf}" /etc/vimrc &> /dev/null

		if [[ $? -eq 0 ]]; then
			continue
		else
			echo "${vim_conf}" >> /tmp/vimrc
		fi
	done
	IFS=$IFS_OLD

	if [[ -s /tmp/vimrc ]]; then
		echo -e "${magenta_fg_prefix}Configuring vim...${fg_suffix}"
		cat /tmp/vimrc >> /etc/vimrc

		rm -f /tmp/vimrc
	else
		echo -e "${yello_fg_prefix}VIM already configured${skip_flag}${fg_suffix}"
	fi
}

func_check() {
	echo && echo -e "${cyan_fg_prefix}#################### Tasks Check ####################${fg_suffix}" && echo

	echo -e "${magenta_fg_prefix}[Check Hostname]${fg_suffix}"
	grep "${hostname}" /etc/hostname &> /dev/null
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
	timedatectl | grep "Asia/Shanghai" &> /dev/null
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
	yum list installed |grep ntpdate &> /dev/null
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
		yum group list installed | grep "${group}" &> /dev/null
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
		grep -F "${vim_conf}" /etc/vimrc &> /dev/null

		if [[ $? -eq 0 ]]; then
			echo -e "\t${green_fg_prefix}[${vim_conf}]${fg_suffix}${ok_flag}"
		else
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

	if [ "${reboot_ans}" = "Y" -o "${reboot_ans}" = "y" ]; then
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