#!/bin/bash

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh --mirror Aliyun

systemctl enable docker
systemctl start docker

if [[ -f /etc/redhat-release ]]; then
	cat <<-EOF >> /etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
fi

sysctl -p

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