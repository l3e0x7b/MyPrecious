#!/bin/bash
## 定时推送最新 Sublime Text 3 package-control channel 文件到 github，配合 crontab 食用,如：
## 0 0 * * * /Path/to/st3_pc_channel_auto_update.sh &> /dev/null

repo='/opt/MyPrecious'

cd ${repo}
git pull

curl -Ssl https://packagecontrol.io/channel_v3.json -o Files/channel_v3.json

git add Files/channel_v3.json
git commit -m "Update Files/channel_v3.json"
git push origin master