#!/bin/bash
# Install V2Ray, and run upgrade weekly.

echo "bash <(curl -L -s https://install.direct/go.sh)" > /opt/v2ray_inst.sh
echo "0 0 * * 5 root /bin/bash /opt/v2ray_inst.sh &> /var/log/v2ray/install.log" >> /etc/crontab

/bin/bash /opt/v2ray_inst.sh

systemctl restart crond &> /dev/null
