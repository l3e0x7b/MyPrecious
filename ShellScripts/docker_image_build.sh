#!/bin/bash
##
## Description: A simple script for building docker images
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

set -e

# docker build --no-cache --rm -t $(NAME):$(TAG) --build-arg $(BUILD_ARG) .

NAME="foo"

echo "> Input TAG for container image to build:"
echo -e "> e.g., 1.0.0, latest, 1.0.0 latest, latest 1.0.0\n"

read -e -r -p "Tag: " TAG

if [[ ${TAG} = "" ]]; then
  echo -e "\n> Error: tag cannot be blank."
elif [[ ${TAG} = "latest" ]]; then
  docker build --no-cache --rm -t ${NAME}:latest .
elif [[ ${TAG} =~ "latest" ]]; then
  TAG=$(echo "${TAG}" | sed 's/latest\| //g')

  docker build --no-cache --rm -t ${NAME}:"${TAG}" -t ${NAME}:latest .
else
  docker build --no-cache --rm -t ${NAME}:"${TAG}" .
fi
