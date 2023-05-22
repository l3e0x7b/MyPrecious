FROM debian:buster

LABEL description="Customized Debian Buster docker image." \
	author="l3e0x7b, <lyq0x7b@foxmail.com>"

ARG TIMEZONE="Asia/Shanghai" \
  APT_REPO="mirrors.ustc.edu.cn"

SHELL ["/bin/bash", "-c"]

RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo ${TIMEZONE} > /etc/timezone && \
  cat <<EOF > /etc/apt/sources.list
deb https://mirrors.ustc.edu.cn/debian/ buster main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ buster-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ buster-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ buster-backports main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ buster/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ buster/updates main contrib non-free
EOF
