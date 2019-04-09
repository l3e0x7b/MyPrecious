#!/bin/bash

echo && echo -e "\e[1;36;40m############## Task List ##############
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
#######################################\e[0m" && echo

date=$(date +%Y%m%d_%H%M%S)
ok_flag="\e[1;32;40m........................................[OK]\e[0m"
failed_flag="\e[1;31;40m........................................[FAILED]\e[0m"
skip_flag="\e[1;33;40m........................................[SKIP]\e[0m"

read -n 1 -p "The program is ready to configure your system(s), press any key to start: "

# exec 3>&1
# exec 1>/var/log/output_${date}.log
exec 4>&2
exec 2> /var/log/setup_err_${date}.log

func_hostname () {
	echo && echo -e "\e[1;36;40m####################Hostname Configuration####################\e[0m" && echo

	hostname="localhost.localdomain"

	if grep -q "${hostname}" /etc/hostname; then
		echo -e "\e[1;33;40mHostname already set${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mHostname not set. It will be set to \"${hostname}\"...\e[0m"

		hostnamectl set-hostname ${hostname}
		sed -i "s/\(localdomain4\).*/\1/" /etc/hosts
		sed -i "s/\(localdomain6\).*/\1/" /etc/hosts
	fi
}

func_network () {
	echo && echo -e "\e[1;36;40m####################Network Configuration####################\e[0m" && echo

	nic=$(ls /sys/class/net/ | head -n1)

	if ip address show ${nic} | grep -wq "inet"; then
		if grep -iq "^ONBOOT=no" /etc/sysconfig/network-scripts/ifcfg-${nic}; then
			sed -i "s/^ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-${nic}
		fi

		echo -e "\e[1;33;40mNetworking already configured${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mDisabling NetworkManager, please wait...\e[0m" && echo

		systemctl stop NetworkManager
		systemctl disable NetworkManager > /dev/null 2>&1

		echo -e "\e[1;35;40mBringing up networking...\e[0m"
	
		sed -i "s/^ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-${nic}
	
		systemctl restart network
	fi
}

func_dns() {
	echo && echo -e "\e[1;36;40m####################DNS Configuration####################\e[0m" && echo

	dns1="223.5.5.5"
	dns2="114.114.114.114"

	if grep -q "nameserver" /etc/resolv.conf; then
		echo -e "\e[1;33;40mDNS already configured${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mDNS will be set to ${dns1}, ${dns2}...\e[0m"

		if grep -iq "^BOOTPROTO=dhcp" /etc/sysconfig/network-scripts/ifcfg-${nic}; then
			cat <<EOF >> /etc/sysconfig/network-scripts/ifcfg-${nic}
			DNS1=${dns1}
			DNS2=${dns2}
EOF
		else
			cat <<EOF >> /etc/resolv.conf
			nameserver=${dns1}
			nameserver=${dns2}
EOF
		fi

		systemctl restart network
	fi
}

func_timezone() {
	echo && echo -e "\e[1;36;40m####################Timezone Configuration####################\e[0m" && echo

	timezone="Asia/Shanghai"
	timezone_old=$(timedatectl | grep 'Time zone' | awk '{print $3}')

	if [ "${timezone_old}" = "${timezone}" ]; then
		echo -e "\e[1;33;40mCurrent timezone is \"${timezone}\"${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mTimezone will be changed to \"${timezone}\"...\e[0m"
		ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
	fi
}

func_sshd() {
	echo && echo -e "\e[1;36;40m####################SSHD Configuration####################\e[0m" && echo

	if grep -iq "^UseDNS no" /etc/ssh/sshd_config; then
		echo -e "\e[1;33;40mSSHD already configured${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mConfiguring sshd, please wait...\e[0m"
		sed -i "s/^#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
	fi
}

func_yum() {
	echo && echo -e "\e[1;36;40m####################Yum Repo Configuration####################\e[0m" && echo

	if grep -iq "163.com" /etc/yum.repos.d/CentOS-Base.repo; then
		echo -e "\e[1;33;40mYum repo already configured${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mThe default repo will be replaced by NetEase Repo, please wait...\e[0m"

		mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
		curl -Sso /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
	fi
}

func_epel() {
	echo && echo -e "\e[1;36;40m####################EPEL Repo Configuration####################\e[0m" && echo

	if ls /etc/yum.repos.d | grep -iq "epel"; then
		echo -e "\e[1;33;40mEPEL repo already installed${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mInstalling EPEL repo...\e[0m" && echo

		# yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		curl -Sso /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

		yum clean all
		yum makecache
		yum update -y
	fi
}

func_firewall() {
	echo && echo -e "\e[1;36;40m####################Firewall Configuration####################\e[0m" && echo

	fwstat=$(systemctl status firewalld | grep "Active" | awk '{print $2}')
	iptstat=$(systemctl status iptables | grep "Active" | awk '{print $2}')

	if [ "${fwstat}" = "inactive" -a "${iptstat}" = "active" ]; then
		echo -e "\e[1;33;40mFirewall already configured${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mConfiguring firewall, please wait...\e[0m" && echo

		systemctl stop firewalld
		systemctl disable firewalld > /dev/null 2>&1
		yum install -y iptables-services
		systemctl enable iptables > /dev/null 2>&1
		systemctl start iptables

		# sed -i "s/-A INPUT -j REJECT --reject-with icmp-host-prohibited/#-A INPUT -j REJECT --reject-with icmp-host-prohibited/" /etc/sysconfig/iptables
		# sed -i "s/-A FORWARD -j REJECT --reject-with icmp-host-prohibited/#-A FORWARD -j REJECT --reject-with icmp-host-prohibited/" /etc/sysconfig/iptables

		# systemctl restart iptables
	fi
}

func_selinux() {
	echo && echo -e "\e[1;36;40m####################SELinux Configuration####################\e[0m" && echo

	if getenforce | grep -q "Disabled"; then
		echo -e "\e[1;33;40mSElinux already disabled${skip_flag}\e[0m"
	else
		echo -e "\e[1;35;40mDisabling SELinux...\e[0m"

		setenforce 0
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	fi
}

func_ntp() {
	echo && echo -e "\e[1;36;40m####################Time Configuration####################\e[0m" && echo

	ntpdatestat=$(yum info ntpdate | grep "Repo" | awk '{print $3}')

	if [ "${ntpdatestat}" = "installed" ]; then
		echo -e "\e[1;33;40mNtpdate already installed, start synchronizing system time with cn.pool.ntp.org...\e[0m"
	else
		echo -e "\e[1;35;40mStart synchronizing system time with cn.pool.ntp.org...\e[0m" && echo
	
		yum install -y ntpdate
		ntpdate -u cn.pool.ntp.org

		echo "0 0 1 * * root /usr/sbin/ntpdate -u cn.pool.ntp.org 2>&1 /dev/null" >> /etc/crontab
		systemctl restart crond
	fi
}

func_env() {
	echo && echo -e "\e[1;36;40m####################Envionment Configuration####################\e[0m" && echo

	echo -e "\e[1;33;40m${skip_flag}\e[0m"
}

func_addons() {
	echo && echo -e "\e[1;36;40m####################Add-ons installation####################\e[0m" && echo

	IFS_OLD=$IFS
	IFS=$';'

	tool_list="yum-utils;yum-cron;wget;net-tools;vim-enhanced;bash-completion;mlocate;lrzsz"

	for tool in ${tool_list}
	do
		if yum list installed | grep -iq ${tool}; then
			echo -e "\e[1;33;40m${tool} already installed${skip_flag}\e[0m" && echo
			
		else
			echo -e "\e[1;35;40m${tool} will be installed...\e[0m" && echo

			yum install -y ${tool}
		fi
	done

	if yum groups list | grep -A1 "Installed Groups" | grep -iq "Development Tools"; then
		echo -e "\e[1;33;40mDevelopment Tools already installed${skip_flag}\e[0m" && echo
	else
		echo -e "\e[1;35;40mDevelopment Tools will be installed...\e[0m" && echo

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
				echo -e "\e[1;35;40mConfiguring vim, please wait...\e[0m"
			fi

			echo "${vim_conf}" >> /etc/vimrc
			i=1
		fi
	done

	IFS=$IFS_OLD
}

func_check() {
	echo && echo -e "\e[1;36;40m####################Tasks Check####################\e[0m" && echo

	echo -e "\e[1;35;40m[Check Hostname]\e[0m"
	if grep -q "${hostname}" /etc/hostname; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Network]\e[0m"
	nwstat=$(systemctl status network | grep "Active" | awk '{print $2}')
	netflag=$(ip address show ${nic} | grep -wq "inet";echo $?)
	
	if [ ${netflag} -eq 0 -a "${nwstat}" = "active" ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check DNS]\e[0m"
	if grep -q "nameserver" /etc/resolv.conf; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Timezone]\e[0m"
	if timedatectl | grep -q "Asia/Shanghai"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check SSHD]\e[0m"
	if grep -q "^UseDNS no" /etc/ssh/sshd_config; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Firewall]\e[0m"

	fwstat=$(systemctl status firewalld | grep "Active" | awk '{print $2}')
	iptstat=$(systemctl status iptables | grep "Active" | awk '{print $2}')
	
	if [ "${fwstat}" = "inactive" -a "${iptstat}" = "active" ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check SELinux]\e[0m"
	if grep -q "^SELINUX=disabled" /etc/selinux/config; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check NTP]\e[0m"
	if ntpdate -u cn.pool.ntp.org | grep -q "adjust time server"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Env]\e[0m"
	echo -e "${skip_flag}"

	echo -e "\e[1;35;40m[Check Yum]\e[0m"
	if grep -q "163" /etc/yum.repos.d/CentOS-Base.repo; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check EPEL]\e[0m"
	if [ -f /etc/yum.repos.d/epel.repo ]; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Add-ons]\e[0m"
	if yum list installed | grep -q "yum-utils"; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo -e "\e[1;35;40m[Check Vim]\e[0m"
	if grep -q "fileformats" /etc/vimrc; then
		echo -e "${ok_flag}"
	else
		echo -e "${failed_flag}"
	fi

	echo
}

func_reboot() {
	echo -e "\e[1;36;40m################################################################################\e[0m" && echo
	echo -e "\e[1;35;40mErrors has been saved in [/var/log/setup_err_${date}.log].\e[0m" && echo

	read -p "All tasks completed! Reboot immediately(recommended)[Y/y] or later[Enter]? " reboot_ans

	if [ "${reboot_ans}" = "Y" -o "${reboot_ans}" = "y" ]; then
		echo && echo -e "\e[1;35;40mNow reboot...\e[0m"
		reboot
	else
		echo && echo -e "\e[1;35;40mProgram will now exit...\e[0m"
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
