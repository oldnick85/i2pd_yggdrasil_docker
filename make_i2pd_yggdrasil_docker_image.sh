#!/bin/bash
TAG_VERSION=$(git describe --tags || echo "unknown")
docker build \
    --build-arg UBUNTU_VERSION=22.04 \
    --build-arg I2PD_VERSION=2.47.0 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.4.7 \
    --tag i2pd_yggdrasil:${TAG_VERSION} \
    --tag i2pd_yggdrasil:latest \
    .
