FROM alpine

LABEL description="Node.js 精简版镜像" \
	author="l3e0x7b, <lyq0x7b@foxmail.com>"

RUN apk add --no-cache --update nodejs nodejs-npm && \
	npm config set registry https://registry.npm.taobao.org/
