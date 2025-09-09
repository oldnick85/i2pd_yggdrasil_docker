#!/bin/bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y gcc
sudo apt-get install -y \
    git \
    make \
    cmake \
    debhelper
sudo apt-get install -y \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libssl-dev \
    zlib1g-dev
sudo apt-get install -y \ 
    libminiupnpc-dev
mkdir /tmp/BUILD_I2PD/
cd /tmp/BUILD_I2PD/
git clone --depth 1 --branch 2.58.0 https://github.com/PurpleI2P/i2pd.git
cd /tmp/BUILD_I2PD/i2pd/build
cmake -DCMAKE_BUILD_TYPE=Release -DWITH_AESNI=ON -DWITH_UPNP=ON .
make

sudo apt-get install -y golang
mkdir /tmp/BUILD_YGGDRASIL/
cd /tmp/BUILD_YGGDRASIL/
git clone --depth 1 --branch $YGGDRASIL_VERSION https://github.com/yggdrasil-network/yggdrasil-go.git
ENV CGO_ENABLED=0
cd /tmp/BUILD_YGGDRASIL/yggdrasil-go
sed -i -e 's/yggdrasil yggdrasilctl/yggdrasil yggdrasilctl genkeys/g' build
./build

sudo apt-get install -y \ 
    libminiupnpc17 \
    git python3 python3-pip iputils-ping
mkdir /opt/I2PD/
cd /opt/I2PD/
cp /opt/BUILD_I2PD/i2pd/build/i2pd .
cp /opt/BUILD_I2PD/i2pd/contrib/certificates ./certificates
cp /tmp/i2pd_yggdrasil_docker/i2pd.conf .
ulimit -n 4096

mkdir /opt/YGGDRASIL/
cd /opt/YGGDRASIL/
cp /tmp/BUILD_YGGDRASIL/yggdrasil-go/yggdrasil .
cp /tmp/BUILD_YGGDRASIL/yggdrasil-go/yggdrasilctl .
cp /tmp/BUILD_YGGDRASIL/yggdrasil-go/genkeys .
cp /tmp/i2pd_yggdrasil_docker/yggdrasil.conf .
