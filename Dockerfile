# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION} AS builder_i2pd
ARG I2PD_VERSION=2.49.0
ARG I2PD_COMPILER=gcc
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get update &&\
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get install -y $I2PD_COMPILER
RUN DEBIAN_FRONTEND=noninteractive\ 
    apt-get install -y \
    git \
    make \
    cmake \
    debhelper
RUN DEBIAN_FRONTEND=noninteractive\ 
    apt-get install -y \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libssl-dev \
    zlib1g-dev
RUN DEBIAN_FRONTEND=noninteractive\ 
    apt-get install -y \ 
    libminiupnpc-dev
WORKDIR /BUILD_I2PD/
RUN git clone --depth 1 --branch $I2PD_VERSION https://github.com/PurpleI2P/i2pd.git
WORKDIR /BUILD_I2PD/i2pd/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DWITH_AESNI=ON -DWITH_UPNP=ON .
RUN make

FROM ubuntu:${UBUNTU_VERSION} as builder_yggdrasil
ARG YGGDRASIL_VERSION=v0.4.7
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get update &&\
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get install -y git golang
WORKDIR /BUILD_YGGDRASIL/
RUN git clone --depth 1 --branch $YGGDRASIL_VERSION https://github.com/yggdrasil-network/yggdrasil-go.git
ENV CGO_ENABLED=0
WORKDIR /BUILD_YGGDRASIL/yggdrasil-go
# add genkeys to build
RUN sed -i -e 's/yggdrasil yggdrasilctl/yggdrasil yggdrasilctl genkeys/g' build
RUN ./build

FROM ubuntu:${UBUNTU_VERSION}
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update &&\
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive \ 
    apt-get install -y \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libssl3 \
    zlib1g
RUN DEBIAN_FRONTEND=noninteractive \ 
    apt-get install -y \ 
    libminiupnpc17 \
    git python3 python3-pip iputils-ping
# ==== UTILS ====
WORKDIR /UTILS/
RUN git config --global advice.detachedHead false
#   script to get strong yggdrasil address (https://yggdrasil-network.github.io/configuration.html#generating-stronger-addresses-and-prefixes)
RUN git clone --depth 1 --branch v0 https://github.com/oldnick85/yggdrasil_get_keys.git /UTILS/yggdrasil_get_keys
RUN python3 -m pip install -r /UTILS/yggdrasil_get_keys/requirements.txt
#   script to find yggdrasil public peers
RUN git clone --depth 1 --branch v3 https://github.com/oldnick85/yggdrasil_find_public_peers.git /UTILS/yggdrasil_find_public_peers
RUN python3 -m pip install -r /UTILS/yggdrasil_find_public_peers/requirements.txt
#   save peers to use in case of unavailable repository
RUN python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json"
# ==== I2P ====
#   Ports Used by I2P
#   Webconsole
EXPOSE 7070
#   HTTP Proxy
EXPOSE 4444
#   SOCKS Proxy
EXPOSE 4447
#   SAM Bridge (TCP)
EXPOSE 7656
#   BOB Bridge
EXPOSE 2827
#   I2CP
EXPOSE 7654
#   I2PControl
EXPOSE 7650
#   Port to listen for connections
EXPOSE 10765
WORKDIR /I2PD/
COPY --from=builder_i2pd /BUILD_I2PD/i2pd/build/i2pd .
COPY --from=builder_i2pd /BUILD_I2PD/i2pd/contrib/certificates ./certificates
COPY i2pd.conf .
RUN ulimit -n 4096
# ==== YGGDRASIL ====
#   Ports used by YGGDRASIL
#   Listen
EXPOSE 10654
#   Default yggdrasil port
EXPOSE 9001
WORKDIR /YGGDRASIL/
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasil .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasilctl .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/genkeys .
COPY yggdrasil.conf .
WORKDIR /
COPY entrypoint.sh .
CMD ["bash", "/entrypoint.sh"]