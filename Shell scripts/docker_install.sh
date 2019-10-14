#!/bin/bash

curl -fsSL get.docker.com -o get-docker.sh
if [[ $? -eq 0 ]]; then
	sh get-docker.sh --mirror Aliyun

	systemctl enable docker
	systemctl start docker

	if [[ -f /etc/redhat-release ]]; then
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

	# install docker-compose
	curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

	rm -f get-docker.sh
else
	exit 2
fi
