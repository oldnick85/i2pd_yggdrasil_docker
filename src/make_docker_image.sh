#!/bin/bash
set -e  # Exit on error

# Get version from git tags or use default
TAG_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo "Building I2P over Yggdrasil Docker image..."
echo "Version: $TAG_VERSION"
echo "Commit: $COMMIT_HASH"

# Build the Docker image with build args and tags
docker build --file="Dockerfile" \
    --build-arg UBUNTU_VERSION=24.04 \
    --build-arg I2PD_VERSION=2.58.0 \
    --build-arg I2PD_COMPILER=gcc \
    --build-arg YGGDRASIL_VERSION=v0.5.12 \
    --label "org.label-schema.version=$TAG_VERSION" \
    --label "org.label-schema.vcs-ref=$COMMIT_HASH" \
    --label "org.label-schema.build-date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --tag i2pd_yggdrasil:${TAG_VERSION} \
    --tag i2pd_yggdrasil:latest \
    .

echo "Build completed successfully!"
echo "Images: i2pd_yggdrasil:${TAG_VERSION}, i2pd_yggdrasil:latest"