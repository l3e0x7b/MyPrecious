#!/bin/bash
##
## Description: Docker installation script for Debian.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

apt update && apt -y install apt-transport-https ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update && apt -y install docker-ce docker-ce-cli docker-ce-rootless-extras

if docker info; then
  cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-opts": {"max-size": "100m"},
  "storage-driver": "overlay2",
  "registry-mirrors": [
    "https://tuyjisn6.mirror.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ],
  "insecure-registries": ["127.0.0.1"]
}
EOF

  systemctl daemon-reload
  systemctl restart docker.service
else
  echo "Failed to install docker." && exit
fi
