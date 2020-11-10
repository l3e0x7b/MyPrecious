#!/bin/bash
##
## Description: Docker installation script for Linux.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

curl -sSL get.docker.com -o get-docker.sh
if [[ $? -eq 0 ]]; then
	sh get-docker.sh --mirror Aliyun

	if [[ $? -eq 0 ]]; then
		if [[ -f /etc/redhat-release ]]; then
			sysctl -p

			grep '1' /proc/sys/net/bridge/bridge-nf-call-iptables &> /dev/null
			if [[ $? -ne 0 ]]; then
				echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
			fi
			
			grep '1' /proc/sys/net/bridge/bridge-nf-call-ip6tables &> /dev/null
			if [[ $? -ne 0 ]]; then
				echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
			fi
			
			sysctl -p
		elif [[ -f /etc/debian_version ]]; then
			grep '^GRUB_CMDLINE_LINUX=' /etc/default/grub | grep 'cgroup_enable=memory swapaccount=1' &> /dev/null
			if [[ $? -ne 0 ]]; then
				sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory swapaccount=1"/' /etc/default/grub
				update-grub
			fi
		fi

		systemctl enable docker
		systemctl start docker

		cat <<-EOF > /etc/docker/daemon.json
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"log-driver": "json-file",
	"log-opts": {"max-size": "100m"},
	"storage-driver": "overlay2",
	"storage-opts": ["overlay2.override_kernel_check=true"],
	"registry-mirrors": [
		"https://tuyjisn6.mirror.aliyuncs.com",
		"https://hub-mirror.c.163.com"
	]
}
EOF

		systemctl daemon-reload
		systemctl restart docker

		rm -f get-docker.sh

		# install docker-compose
		dc_ver=`curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//'`
		curl -L https://github.com/docker/compose/releases/download/${dc_ver}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
		if [[ $? -eq 0 ]]; then
			chmod +x /usr/local/bin/docker-compose

			docker-compose version &> /dev/null
			if [[ $? -ne 0 ]]; then
				exit 4
			fi
		fi
	else
		exit 3
	fi
else
	exit 2
fi
