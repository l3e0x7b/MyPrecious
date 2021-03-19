#!/bin/bash
##
## Description: Brook installation/Upgrade script for Linux.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

brook_bin="/usr/bin/brook"
brook_port="10004"
brook_pwd="2Ghlmcl"
brook_log="/var/log/brook.log"
brook_ver_new=$(curl -s https://api.github.com/repos/txthinking/brook/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//')

install () {
	if curl -L https://github.com/txthinking/brook/releases/download/"${brook_ver_new}"/brook_linux_amd64 -o ${brook_bin}; then
		chmod +x ${brook_bin}
		start
	else
		echo "Install/update brook failed."
	fi
}

update () {
	brook_ver="v$(${brook_bin} -v | awk '{print $3}')"

	if [[ ${brook_ver} -ne ${brook_ver_new} ]]; then

		pgrep brook &> /dev/null && pkill -9 brook

		install
	else
		echo "Brook is up to date."
	fi
}

usage () {
	echo "Usage: brook.sh [command]"
	echo -e "The default command is 'install'\n"
	echo "Commands:"
	echo -e "  install\n  update\n  start\n  stop\n  restart"
}

start () {
	if pgrep brook &> /dev/null; then
		echo "Brook server is already running."
	else
		nohup ${brook_bin} -d server -l :${brook_port} -p ${brook_pwd} &>> ${brook_log} &
		
		if pgrep brook &> /dev/null; then
			echo "Brook server is running."
		else
			echo "Start brook server failed."
		fi
	fi
}

stop () {
	if pgrep brook &> /dev/null; then
		pkill -9 brook

		if pgrep brook &> /dev/null; then
			echo "Stop brook server failed."
		else
			echo "Brook server is stopped."
		fi
	else
		echo "Brook server is not running."
	fi
}

restart () {
	if pgrep brook &> /dev/null; then
		pkill -9 brook

		if pgrep brook &> /dev/null; then
			echo "Stop brook server failed."
		else
			start
		fi
	else
		start
	fi
}

case $1 in
	install|'')
		if [[ ! -f ${brook_bin} ]]; then
			install
		else
			echo "Brook is already installed."
		fi
		;;
	update)
		if [[ ! -f ${brook_bin} ]]; then
			echo "Brook is not installed, please run 'brook.sh install' to install it first."
		else
			update
		fi
		;;
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	help)
		usage
		;;
	*)
		echo -e "invalid command -- '$1'\n"
		usage
		;;
esac
