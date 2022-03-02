#!/bin/bash

xray_ver=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//')
xray_path='/usr/local/bin'
dat_ver=$(curl -s https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | grep "tag_name" | sed 's/^.*: "//;s/",.*$//')
dat_path='/usr/local/share/xray'

if curl -sL https://github.com/XTLS/Xray-core/releases/download/"${xray_ver}"/Xray-linux-64.zip -o /tmp/Xray-linux-64.zip; then
        unzip -q -d /tmp /tmp/Xray-linux-64.zip xray
        mv /tmp/xray ${xray_path}
        chmod +x ${xray_path}/xray
        systemctl restart xray.service
        rm -f /tmp/Xray-linux-64.zip
fi

for file in geoip.dat geosite.dat; do
    if curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/"${dat_ver}"/${file} -o /tmp/${file}; then
        mv -f /tmp/${file} ${dat_path}
        systemctl restart xray.service
    fi
done
