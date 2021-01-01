#!/usr/bin/env bash

set -e

docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

IFS=',' read -ra tags <<< "${TAGS}"

for tag in "${tags[@]}"; do
    make release TAG="${tag}";
done