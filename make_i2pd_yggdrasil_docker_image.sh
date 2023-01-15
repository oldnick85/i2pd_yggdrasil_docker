#!/bin/bash
docker build \
    --build-arg UBUNTU_VERSION=22.04 \
    --build-arg I2PD_VERSION=2.45.1 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.4.7 \
    --tag i2pd_yggdrasil:latest \
    .
