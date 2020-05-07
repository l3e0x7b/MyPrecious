#!/bin/bash

curl -fsSL get.docker.com -o get-docker.sh
if [[ $? -eq 0 ]]; then
	sh get-docker.sh --mirror Aliyun

	if [[ $? -eq 0 ]]; then
		systemctl enable docker
		systemctl start docker

		if [[ -f /etc/redhat-release ]]; then
			sysctl -p

			docker info | grep "WARNING: bridge-nf-call-iptables is disabled" &> /dev/null
			if [[ $? -eq 0 ]]; then
				echo "net.bridge.bridge-nf-call-iptables = 1"
			fi
			
			docker info | grep "WARNING: bridge-nf-call-ip6tables is disabled" &> /dev/null
			if [[ $? -eq 0 ]]; then
				echo "net.bridge.bridge-nf-call-ip6tables = 1"
			fi
			
			sysctl -p
		fi

		cat <<-EOF > /etc/docker/daemon.json
{
	"registry-mirrors": [
		"https://dockerhub.azk8s.cn",
		"https://reg-mirror.qiniu.com"
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
