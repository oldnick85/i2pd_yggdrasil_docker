#!/bin/bash
TAG_VERSION=$(git describe --tags || echo "unknown")
docker build \
    --build-arg UBUNTU_VERSION=23.10 \
    --build-arg I2PD_VERSION=2.50.1 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.5.4 \
    --tag i2pd_yggdrasil:${TAG_VERSION} \
    --tag i2pd_yggdrasil:latest \
    .
