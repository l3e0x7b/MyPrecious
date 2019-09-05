#!/bin/bash
# 获取 fail2ban 的 Banned IP list 并写入 /etc/hosts.allow

for ip in `fail2ban-client status sshd | grep 'Banned IP list' | cut -d: -f2 | xargs`; do
	grep ${ip} /etc/hosts.allow &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo "sshd:${ip}:deny" >> /etc/hosts.allow
	fi
done
