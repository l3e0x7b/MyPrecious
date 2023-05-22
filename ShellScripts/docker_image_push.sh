#!/bin/bash
##
## Description: A simple script for pushing docker images to registry
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

set -e

NAME="foo"

REG_URL="harbor.example.com"
REG_USER="user"
REG_TOKEN="password"

#read -s -r -p "Harbor admin password: " REPO_PWD
#echo "${REPO_PWD}" | docker login ${REG_URL} -u ${REG_USER} --password-stdin
docker login -u ${REG_USER} -p ${REG_TOKEN} ${REG_URL}

echo -e "\n> Input TAG for container image to push:"
echo -e "> e.g., 1.0.0, latest, 1.0.0 latest, latest 1.0.0\n"

read -e -r -p "Tag: " TAG

if [[ ${TAG} = "" ]]; then
  echo -e "\n> Error: tag cannot be blank."
elif [[ ${TAG} = "latest" ]]; then
  docker tag ${NAME}:latest ${REG_URL}/library/${NAME}:latest
  docker push ${REG_URL}/library/${NAME}:latest
elif [[ ${TAG} =~ "latest" ]]; then
  TAG=$(echo "${TAG}" | sed 's/latest\| //g')

  docker tag ${NAME}:"${TAG}" ${REG_URL}/library/${NAME}:"${TAG}"
  docker tag ${NAME}:latest ${REG_URL}/library/${NAME}:latest

  docker push ${REG_URL}/library/${NAME}:"${TAG}"
  docker push ${REG_URL}/library/${NAME}:latest
else
  docker tag ${NAME}:"${TAG}" ${REG_URL}/library/${NAME}:"${TAG}"
  docker push ${REG_URL}/library/${NAME}:"${TAG}"
fi
