#!/bin/bash
TAG_VERSION=$(git describe --tags || echo "unknown")
docker build --file="src/Dockerfile" \
    --build-arg UBUNTU_VERSION=23.10 \
    --build-arg I2PD_VERSION=2.52.0 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.5.5 \
    --tag i2pd_yggdrasil:${TAG_VERSION} \
    --tag i2pd_yggdrasil:latest \
    .
