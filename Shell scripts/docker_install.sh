#!/bin/bash

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
		"https://dockerhub.azk8s.cn",
		"https://tuyjisn6.mirror.aliyuncs.com",
		"https://hub-mirror.c.163.com"
	]
}
EOF

		systemctl daemon-reload
		systemctl restart docker

		rm -f get-docker.sh

		# install docker-compose
		dc_ver=`curl -s https://docs.docker.com/compose/install/ | grep -A1 "The instructions below outline installation" | sed '1d;s/.*<strong>v//;s/<\/strong>.*$//'`
		curl -L https://github.com/docker/compose/releases/download/${dc_ver}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
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
