#!/bin/bash
##
## Description: Automatically update geo* files for v2ray/xray.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

ver=$(curl -s https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//')
dir='/usr/local/share/xray'

for file in geoip.dat geosite.dat; do
    if curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/"${ver}"/${file} -o /tmp/${file}; then
        mv -f /tmp/${file} ${dir}

        systemctl restart xray.service
    fi
done
