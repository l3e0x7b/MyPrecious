# Install zabbix-agent in batches.

#!/bin/bash

hostname=$(cat /etc/hostname)
z_server='10.10.100.168'

# debian 9
wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-2+stretch_all.deb
dpkg -i zabbix-release_4.0-2+stretch_all.deb
apt update -y

apt install -y zabbix-agent

sed -i "s/^Server=.*/Server=${z_server}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=.*/ServerActive=${z_server}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname=.*/Hostname=${hostname}/" /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent.service
systemctl restart zabbix-agent.service



# centos 7
rpm -i https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

yum install -y zabbix-agent

sed -i "s/^Server=.*/Server=${z_server}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=.*/ServerActive=${z_server}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname=.*/Hostname=${hostname}/" /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent.service