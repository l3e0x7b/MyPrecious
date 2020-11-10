#!/bin/bash
##
## Description: Brook installation/Upgrade script for Linux.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

BROOK_BIN="/usr/bin/brook"
BROOK_PORT="10004"
BROOK_PWD="2Ghlmcl"
BROOK_LOG="/var/log/brook.log"
BROOK_VER_NEW=`curl -s https://api.github.com/repos/txthinking/brook/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//'`

func_inst () {
	curl -L https://github.com/txthinking/brook/releases/download/${BROOK_VER_NEW}/brook_linux_amd64 -o ${BROOK_BIN}

	if [[ $? -eq 0 ]]; then
		chmod +x ${BROOK_BIN}
		func_start
	else
		echo "Install/update brook failed."
	fi
}

func_update () {
	BROOK_VER="v`${BROOK_BIN} -v | awk '{print $3}'`"

	if [[ ${BROOK_VER} -ne ${BROOK_VER_NEW} ]]; then
		pgrep brook &> /dev/null

		if [[ $? -eq 0 ]]; then
			pkill -9 brook
		fi

		func_inst
	else
		echo "Brook is up to date."
	fi
}

func_usage () {
	echo "Usage: brook.sh [command]"
	echo -e "The default command is 'install'\n"
	echo "Commands:"
	echo -e "  install\n  update\n  start\n  stop\n  restart"
}

func_start () {
	pgrep brook &> /dev/null

	if [[ $? -eq 0 ]]; then
		echo "Brook server is already running."
	else
		nohup ${BROOK_BIN} -d server -l :${BROOK_PORT} -p ${BROOK_PWD} &>> ${BROOK_LOG} &

		pgrep brook &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo "Brook server is running."
		else
			echo "Start brook server failed."
		fi
	fi
}

func_stop () {
	pgrep brook &> /dev/null

	if [[ $? -eq 0 ]]; then
		pkill -9 brook

		pgrep brook &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo "Stop brook server failed."
		else
			echo "Brook server is stopped."
		fi
	else
		echo "Brook server is not running."
	fi
}

func_restart () {
	pgrep brook &> /dev/null

	if [[ $? -eq 0 ]]; then
		pkill -9 brook

		pgrep brook &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo "Stop brook server failed."
		else
			func_start
		fi
	else
		func_start
	fi
}

case $1 in
	install|'')
		if [[ ! -f ${BROOK_BIN} ]]; then
			func_inst
		else
			echo "Brook is already installed."
		fi
		;;
	update)
		if [[ ! -f ${BROOK_BIN} ]]; then
			echo "Brook is not installed, please run 'brook.sh install' to install it first."
		else
			func_update
		fi
		;;
	start)
		func_start
		;;
	stop)
		func_stop
		;;
	restart)
		func_restart
		;;
	help)
		func_usage
		;;
	*)
		echo -e "invalid command -- '$1'\n"
		func_usage
		;;
esac
