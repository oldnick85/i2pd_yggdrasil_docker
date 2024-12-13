#!/bin/bash
TAG_VERSION=$(git describe --tags || echo "unknown")
docker build --file="src/Dockerfile" \
    --build-arg UBUNTU_VERSION=24.04 \
    --build-arg I2PD_VERSION=2.54.0 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.5.11 \
    --tag i2pd_yggdrasil:${TAG_VERSION} \
    --tag i2pd_yggdrasil:latest \
    .
