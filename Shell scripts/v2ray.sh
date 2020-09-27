#!/bin/bash
## 安装/更新 v2ray，更新可配合 crontab 食用,如：
## 0 0 * * * /Path/to/v2ray.sh &> /dev/null

## 安装/更新
curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o /tmp/install-release.sh
curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh -o /tmp/install-dat-release.sh

bash /tmp/install-release.sh
bash /tmp/install-dat-release.sh

## 修改 systemd 服务执行权限为 root（默认为 nobody），若为全新安装则注释此部分内容，
## 旧脚本中使用的是 root 权限，若不修改可能导致无法通过 systemd 启动服务
if [[ -f /etc/systemd/system/v2ray.service ]]; then
	sed -i 's/^User=.*/User=root/' /etc/systemd/system/v2ray.service
fi

if [[ -f /etc/systemd/system/v2ray@.service ]]; then
	sed -i 's/^User=.*/User=root/' /etc/systemd/system/v2ray@.service
fi

systemctl daemon-reload

## 启动服务 & 清理
systemctl restart v2ray.service

rm -f /tmp/install-release.sh /tmp/install-dat-release.sh