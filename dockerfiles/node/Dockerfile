FROM alpine:3

LABEL description="Customized Node.js docker image." \
  author="l3e0x7b, <lyq0x7b@foxmail.com>"

ARG TIMEZONE="Asia/Shanghai" \
  APK_REPO="mirrors.ustc.edu.cn"

RUN	sed -i "s/dl-cdn.alpinelinux.org/${APK_REPO}/g" /etc/apk/repositories && \
  apk add --no-cache --update tzdata nodejs npm && \
  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
  echo ${TIMEZONE} > /etc/timezone && \
  apk del tzdata && \
  npm config set registry https://registry.npm.taobao.org/
