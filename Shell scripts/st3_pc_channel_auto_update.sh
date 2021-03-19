#!/bin/bash
##
## Description: 定时推送最新 Sublime Text 3 package-control channel 文件到 GitHub。
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

script_path='/opt'      # 此脚本所在路径
repo='/opt/MyPrecious'      # GitHub 仓库路径

cd ${repo} || exit
git pull

curl -Ssl https://packagecontrol.io/channel_v3.json -o Files/channel_v3.json

git add Files/channel_v3.json
git commit -m "Update Files/channel_v3.json"
git push origin main

if ! grep channel_v3 /etc/crontab &> /dev/null; then
    echo "0 0 * * * root ${script_path}/st3_pc_channel_auto_update.sh &> /dev/null" >> /etc/crontab

    systemctl restart cron || systemctl restart crond
fi
