FROM alpine

LABEL description="Customized Node.js docker image." \
	author="l3e0x7b, <lyq0x7b@foxmail.com>"
  
ARG TIMEZONE="Asia/Shanghai" \
  APK_REPO="mirrors.ustc.edu.cn"

RUN apk add --no-cache --update tzdata nodejs nodejs-npm && \
  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
  echo ${TIMEZONE} > /etc/timezone && \
  apk del tzdata && \
	sed -i "s/dl-cdn.alpinelinux.org/${APK_REPO}/g" /etc/apk/repositories && \
	npm config set registry https://registry.npm.taobao.org/
