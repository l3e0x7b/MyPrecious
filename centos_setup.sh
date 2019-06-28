#!/bin/bash

echo && echo -e "${cyan_fg_prefix}############## Task List ##############
# Hostname Configuration              #
# Network Configuration               #
# DNS Configuration                   #
# Timezone Configuration              #
# SSHD Configuration                  #
# Yum Repo Configuration              #
# EPEL Repo Configuration             #
# Firewall Configuration              #
# SELinux Configuration               #
# Time Configuration                  #
# Envionment Configuration            #
# Add-ons installation                #
# VIM Configuration                   #
# Tasks Check*                        #
# Reboot*                             #
#######################################${fg_suffix}" && echo

date=$(date +%Y%m%d_%H%M%S)
red_fg_prefix="\e[31m"
green_fg_prefix="\e[32m"
yello_fg_prefix="\e[33m"
magenta_fg_prefix="\e[35m"
cyan_fg_prefix="\e[36m"
fg_suffix="\e[0m"
failed_flag="${red_fg_prefix}........................................[FAILED]${fg_suffix}"
ok_flag="${green_fg_prefix}........................................[OK]${fg_suffix}"
skip_flag="${yello_fg_prefix}........................................[SKIP]${fg_suffix}"

read -n 1 -p "The program is ready to configure your system(s), press any key to start: "

# exec 3>&1
# exec 1>/var/log/output_${date}.log
exec 4>&2
exec 2> /var/log/setup_err_${date}.log

func_hostname () {
	echo && echo -e "${cyan_fg_prefix}#################### Hostname Configuration ####################${fg_suffix}" && echo

	hostname="localhost.localdomain"

	if grep -q "${hostname}" /etc/hostname; then
		echo -e "${yello_fg_prefix}Hostname already set${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Hostname not set. It will be set to \"${hostname}\"...${fg_suffix}"

		hostnamectl set-hostname ${hostname}
		sed -i "s/\(localdomain4\).*/\1/" /etc/hosts
		sed -i "s/\(localdomain6\).*/\1/" /etc/hosts
	fi
}

func_network () {
	echo && echo -e "${cyan_fg_prefix}#################### Network Configuration ####################${fg_suffix}" && echo

	nic=$(ls /sys/class/net/ | head -n1)

	if ip address show ${nic} | grep -wq "inet"; then
		if grep -iq "^ONBOOT=no" /etc/sysconfig/network-scripts/ifcfg-${nic}; then
			sed -i "s/^ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-${nic}
		fi

		echo -e "${yello_fg_prefix}Networking already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Disabling NetworkManager, please wait...${fg_suffix}" && echo

		systemctl stop NetworkManager
		systemctl disable NetworkManager > /dev/null 2>&1

		echo -e "${magenta_fg_prefix}Bringing up networking...${fg_suffix}"
	
		sed -i "s/^ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-${nic}
	
		systemctl restart network
	fi
}

func_dns() {
	echo && echo -e "${cyan_fg_prefix}#################### DNS Configuration ####################${fg_suffix}" && echo

	dns1="223.5.5.5"
	dns2="114.114.114.114"

	if grep -q "nameserver" /etc/resolv.conf; then
		echo -e "${yello_fg_prefix}DNS already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}DNS will be set to ${dns1}, ${dns2}...${fg_suffix}"

		if grep -iq "^BOOTPROTO=dhcp" /etc/sysconfig/network-scripts/ifcfg-${nic}; then
			cat <<-EOF >> /etc/sysconfig/network-scripts/ifcfg-${nic}
			DNS1=${dns1}
			DNS2=${dns2}
EOF
		else
			cat <<-EOF >> /etc/resolv.conf
			nameserver=${dns1}
			nameserver=${dns2}
EOF
		fi

		systemctl restart network
	fi
}

func_timezone() {
	echo && echo -e "${cyan_fg_prefix}#################### Timezone Configuration ####################${fg_suffix}" && echo

	timezone="Asia/Shanghai"
	timezone_old=$(timedatectl | grep 'Time zone' | awk '{print $3}')

	if [ "${timezone_old}" = "${timezone}" ]; then
		echo -e "${yello_fg_prefix}Current timezone is \"${timezone}\"${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Timezone will be changed to \"${timezone}\"...${fg_suffix}"
		ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
	fi
}

func_sshd() {
	echo && echo -e "${cyan_fg_prefix}#################### SSHD Configuration ####################${fg_suffix}" && echo

	if grep -iq "^UseDNS no" /etc/ssh/sshd_config; then
		echo -e "${yello_fg_prefix}SSHD already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Configuring sshd, please wait...${fg_suffix}"
		sed -i "s/^#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
	fi
}

func_yum() {
	echo && echo -e "${cyan_fg_prefix}#################### Yum Repo Configuration ####################${fg_suffix}" && echo

	if grep -iq "163.com" /etc/yum.repos.d/CentOS-Base.repo; then
		echo -e "${yello_fg_prefix}Yum repo already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}The default repo will be replaced by NetEase Repo, please wait...${fg_suffix}"

		mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
		curl -Sso /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
	fi
}

func_epel() {
	echo && echo -e "${cyan_fg_prefix}#################### EPEL Repo Configuration ####################${fg_suffix}" && echo

	if ls /etc/yum.repos.d | grep -iq "epel"; then
		echo -e "${yello_fg_prefix}EPEL repo already installed${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Installing EPEL repo...${fg_suffix}" && echo

		# yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		curl -Sso /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

		yum clean all
		yum makecache
		yum update -y
	fi
}

func_firewall() {
	echo && echo -e "${cyan_fg_prefix}#################### Firewall Configuration ####################${fg_suffix}" && echo

	fwstat=$(systemctl status firewalld | grep "Active" | awk '{print $2}')
	iptstat=$(systemctl status iptables | grep "Active" | awk '{print $2}')

	if [ "${fwstat}" = "inactive" -a "${iptstat}" = "active" ]; then
		echo -e "${yello_fg_prefix}Firewall already configured${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Configuring firewall, please wait...${fg_suffix}" && echo

		systemctl stop firewalld
		systemctl disable firewalld > /dev/null 2>&1
		yum install -y iptables-services
		systemctl enable iptables > /dev/null 2>&1
		systemctl start iptables

		sed -i "s/-A INPUT -j REJECT --reject-with icmp-host-prohibited/#-A INPUT -j REJECT --reject-with icmp-host-prohibited/" /etc/sysconfig/iptables
		sed -i "s/-A FORWARD -j REJECT --reject-with icmp-host-prohibited/#-A FORWARD -j REJECT --reject-with icmp-host-prohibited/" /etc/sysconfig/iptables

		systemctl restart iptables
	fi
}

func_selinux() {
	echo && echo -e "${cyan_fg_prefix}#################### SELinux Configuration ####################${fg_suffix}" && echo

	if getenforce | grep -q "Disabled"; then
		echo -e "${yello_fg_prefix}SElinux already disabled${skip_flag}${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Disabling SELinux...${fg_suffix}"

		setenforce 0
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	fi
}

func_ntp() {
	echo && echo -e "${cyan_fg_prefix}#################### Time Configuration ####################${fg_suffix}" && echo

	ntpdatestat=$(yum info ntpdate | grep "Repo" | awk '{print $3}')

	if [ "${ntpdatestat}" = "installed" ]; then
		echo -e "${yello_fg_prefix}Ntpdate already installed, start synchronizing system time with cn.pool.ntp.org...${fg_suffix}"
	else
		echo -e "${magenta_fg_prefix}Start synchronizing system time with cn.pool.ntp.org...${fg_suffix}" && echo
	
		yum install -y ntpdate
		ntpdate -u cn.pool.ntp.org

		echo "0 0 1 * * root /usr/sbin/ntpdate -u cn.pool.ntp.org 2>&1 /dev/null" >> /etc/crontab
		systemctl restart crond
	fi
}

func_env() {
	echo && echo -e "${cyan_fg_prefix}#################### Envionment Configuration ####################${fg_suffix}" && echo

	echo -e "${yello_fg_prefix}${skip_flag}${fg_suffix}"
}

func_addons() {
	echo && echo -e "${cyan_fg_prefix}#################### Add-ons installation ####################${fg_suffix}" && echo

	IFS_OLD=$IFS
	IFS=$';'

	tool_list="yum-utils;yum-cron;wget;net-tools;vim-enhanced;bash-completion;mlocate;lrzsz"

	for tool in ${tool_list}
	do
		if yum list installed | grep -iq ${tool}; then
			echo -e "${yello_fg_prefix}${tool} already installed${skip_flag}${fg_suffix}" && echo
			
		else
			echo -e "${magenta_fg_prefix}${tool} will be installed...${fg_suffix}" && echo

			yum install -y ${tool}
		fi
	done

	if yum groups list | grep -A1 "Installed Groups" | grep -iq "Development Tools"; then
		echo -e "${yello_fg_prefix}Development Tools already installed${skip_flag}${fg_suffix}" && echo
	else
		echo -e "${magenta_fg_prefix}Development Tools will be installed...${fg_suffix}" && echo

		yum groupinstall -y "Development Tools"
	fi

	IFS=$IFS_OLD
}

func_vim() {
	IFS_OLD=$IFS
	IFS=$';'

	vim_conf_list="set nocompatible;set fileformats=unix,dos;set go=;syntax on;set number;set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1;set fileencoding=utf-8;set encoding=utf-8;set shortmess=atI;autocmd InsertEnter * se cul;autocmd InsertEnter * se nocul;set completeopt=preview,menu;set tabstop=4;set softtabstop=4;set shiftwidth=4;set noexpandtab;set ignorecase;set showmatch;set matchtime=0;set wildmenu;set hlsearch;set incsearch;set noerrorbells;set backspace=indent,eol,start"

	i=0
	for vim_conf in ${vim_conf_list}
	do
		grep -q "${vim_conf}" /etc/vimrc

		if [ $? -ne 0 ]; then
			if [ ${i} -eq 0  ]; then
				echo -e "${magenta_fg_prefix}Configuring vim, please wait...${fg_suffix}"
			fi

			echo "${vim_conf}" >> /etc/vimrc
			i=1
		fi
	done

	IFS=$IFS_OLD
}

func_check() {
	echo && echo -e "${cyan_fg_prefix}#################### Tasks Check ####################${fg_suffix}" && echo

	echo -e "${magenta_fg_prefix}[Check Hostname]${fg_suffix}"
	if grep -q "${hostname}" /etc/hostname; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Network]${fg_suffix}"
	nwstat=$(systemctl status network | grep "Active" | awk '{print $2}')
	netflag=$(ip address show ${nic} | grep -wq "inet";echo $?)
	
	if [ ${netflag} -eq 0 -a "${nwstat}" = "active" ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check DNS]${fg_suffix}"
	if grep -q "nameserver" /etc/resolv.conf; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Timezone]${fg_suffix}"
	if timedatectl | grep -q "Asia/Shanghai"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check SSHD]${fg_suffix}"
	if grep -q "^UseDNS no" /etc/ssh/sshd_config; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Firewall]${fg_suffix}"

	fwstat=$(systemctl status firewalld | grep "Active" | awk '{print $2}')
	iptstat=$(systemctl status iptables | grep "Active" | awk '{print $2}')
	
	if [ "${fwstat}" = "inactive" -a "${iptstat}" = "active" ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check SELinux]${fg_suffix}"
	if grep -q "^SELINUX=disabled" /etc/selinux/config; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check NTP]${fg_suffix}"
	if ntpdate -u cn.pool.ntp.org | grep -q "adjust time server"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Env]${fg_suffix}"
	echo -e "${skip_flag}"

	echo -e "${magenta_fg_prefix}[Check Yum]${fg_suffix}"
	if grep -q "163" /etc/yum.repos.d/CentOS-Base.repo; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check EPEL]${fg_suffix}"
	if [ -f /etc/yum.repos.d/epel.repo ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Add-ons]${fg_suffix}"
	if yum list installed | grep -q "yum-utils"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "${magenta_fg_prefix}[Check Vim]${fg_suffix}"
	if grep -q "fileformats" /etc/vimrc; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo
}

func_reboot() {
	echo -e "${cyan_fg_prefix}################################################################################${fg_suffix}" && echo
	echo -e "${magenta_fg_prefix}Errors has been saved in [/var/log/setup_err_${date}.log].${fg_suffix}" && echo

	read -p "All tasks completed! Reboot immediately(recommended)[Y/y] or later[Enter]? " reboot_ans

	if [ "${reboot_ans}" = "Y" -o "${reboot_ans}" = "y" ]; then
		echo && echo -e "${magenta_fg_prefix}Now reboot...${fg_suffix}"
		reboot
	else
		echo && echo -e "${magenta_fg_prefix}Program will now exit...${fg_suffix}"
	fi
}

func_hostname
func_network
func_dns
func_timezone
func_sshd
func_yum
func_epel
func_firewall
func_selinux
func_ntp
func_env
func_addons
func_vim
func_check

# exec 1>&3
# exec 3>&-
exec 2>&4
exec 4>&-

func_reboot