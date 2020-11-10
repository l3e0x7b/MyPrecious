#!/bin/bash
## Description: 安装/更新 v2ray，更新可配合 crontab 食用,如：
##              0 0 * * * /Path/to/v2ray.sh &> /dev/null
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##


if [[ ! -f /usr/local/bin/v2ray ]]; then    ## 安装
	curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o /tmp/install-release.sh
	curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh -o /tmp/install-dat-release.sh

	bash /tmp/install-release.sh
	bash /tmp/install-dat-release.sh

	## 现在 v2ray 服务默认使用的是 nobody，当使用证书时，或从旧脚本迁移后，可能出现权限
	## 不够服务无法启动的问题，可以直接修改 v2ray.service 的执行权限为 root（也可以参考
	## 官方的方法修改：
	## https://github.com/v2fly/fhs-install-v2ray/wiki/Migrate-from-the-old-script-to-this-zh-Hans-CN
	## https://github.com/v2fly/fhs-install-v2ray/wiki/Insufficient-permissions-when-using-certificates-zh-Hans-CN）
	if [[ -f /etc/systemd/system/v2ray.service ]]; then
		sed -i 's/^User=.*/User=root/' /etc/systemd/system/v2ray.service
	fi
	
	if [[ -f /etc/systemd/system/v2ray@.service ]]; then
		sed -i 's/^User=.*/User=root/' /etc/systemd/system/v2ray@.service
	fi

	# 日志目录权限也要改
	chown -R root:root /var/log/v2ray

	systemctl daemon-reload

	## 启动服务 & 清理
	systemctl restart v2ray.service
	rm -f /tmp/install-release.sh /tmp/install-dat-release.sh
else    ## 仅更新
	curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o /tmp/install-release.sh
	curl -LRJ https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh -o /tmp/install-dat-release.sh

	bash /tmp/install-release.sh
	bash /tmp/install-dat-release.sh

	systemctl restart v2ray.service
	rm -f /tmp/install-release.sh /tmp/install-dat-release.sh
fi
