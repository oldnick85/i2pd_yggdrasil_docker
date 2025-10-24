# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04

# I2P build stage
FROM ubuntu:${UBUNTU_VERSION} AS builder_i2pd
ARG I2PD_VERSION=2.58.0
ARG I2PD_COMPILER=gcc

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        $I2PD_COMPILER \
        git make cmake debhelper \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libssl-dev \
        zlib1g-dev \
        libminiupnpc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /BUILD_I2PD/
RUN git config --global advice.detachedHead false && \
    git clone --depth 1 --branch $I2PD_VERSION https://github.com/PurpleI2P/i2pd.git

WORKDIR /BUILD_I2PD/i2pd/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DWITH_AESNI=ON -DWITH_UPNP=ON . && \
    make -j$(nproc)

# Yggdrasil build stage
FROM ubuntu:${UBUNTU_VERSION} as builder_yggdrasil
ARG YGGDRASIL_VERSION=v0.5.12

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y git golang && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /BUILD_YGGDRASIL/
RUN git config --global advice.detachedHead false && \
    git clone --depth 1 --branch $YGGDRASIL_VERSION https://github.com/yggdrasil-network/yggdrasil-go.git

ENV CGO_ENABLED=0
WORKDIR /BUILD_YGGDRASIL/yggdrasil-go
# Add genkeys to build and build binaries
RUN sed -i 's/yggdrasil yggdrasilctl/yggdrasil yggdrasilctl genkeys/g' build && \
    ./build

# Utility scripts for enhanced Yggdrasil functionality
RUN git clone --depth 1 --branch v0 https://github.com/oldnick85/yggdrasil_get_keys.git /UTILS/yggdrasil_get_keys && \
    git clone --depth 1 --branch v4 https://github.com/oldnick85/yggdrasil_find_public_peers.git /UTILS/yggdrasil_find_public_peers && \
    rm -rf /UTILS/yggdrasil_get_keys/.git /UTILS/yggdrasil_find_public_peers/.git

# Final runtime image
FROM ubuntu:${UBUNTU_VERSION}
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libssl3 \
        zlib1g \
        libminiupnpc17 \
        git \
        python3 \
        python3-pip \
        iputils-ping \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates

# ==== UTILS ====
WORKDIR /UTILS/
COPY --from=builder_yggdrasil /UTILS/ /UTILS/

# Install Python dependencies securely
RUN python3 -m pip install --no-cache-dir --break-system-packages \
    -r /UTILS/yggdrasil_get_keys/requirements.txt \
    -r /UTILS/yggdrasil_find_public_peers/requirements.txt

# Cache public peers during build for fallback
RUN python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json" || true

# ==== I2P CONFIGURATION ====
# I2P Service Ports
# Web console
EXPOSE 7070
# HTTP proxy
EXPOSE 4444
# SOCKS proxy
EXPOSE 4447
# SAM bridge
EXPOSE 7656
# BOB bridge
EXPOSE 2827
# I2CP
EXPOSE 7654
# I2PControl
EXPOSE 7650
# Main listener
EXPOSE 10765

WORKDIR /I2PD/
COPY --from=builder_i2pd /BUILD_I2PD/i2pd/build/i2pd .
COPY --from=builder_i2pd /BUILD_I2PD/i2pd/contrib/certificates ./certificates
COPY ./i2pd.conf .

# Increase file descriptor limit for better performance
RUN ulimit -n 4096

# ==== YGGDRASIL CONFIGURATION ====
# Yggdrasil listener
EXPOSE 10654

WORKDIR /YGGDRASIL/
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasil .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasilctl .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/genkeys .
COPY ./yggdrasil.conf .

# ==== FINAL SETUP ====
WORKDIR /
COPY ./entrypoint.sh .
RUN chmod +x /entrypoint.sh

# Health check to ensure services are running
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD bash -c 'pgrep i2pd && pgrep yggdrasil'

CMD ["bash", "/entrypoint.sh"]