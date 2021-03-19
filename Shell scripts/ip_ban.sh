#!/bin/bash
##
## Description: 获取 fail2ban 的 Banned IP list 并写入 /etc/hosts.allow。
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

for ip in $(fail2ban-client status sshd | grep 'Banned IP list' | cut -d: -f2 | xargs); do
    
    ! grep "${ip}" /etc/hosts.allow &> /dev/null && echo "sshd:${ip}:deny" >> /etc/hosts.allow  
done
