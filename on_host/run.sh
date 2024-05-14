#!/bin/bash
git config --global advice.detachedHead false
git clone --depth 1 --branch v0 https://github.com/oldnick85/yggdrasil_get_keys.git /tmp/yggdrasil_get_keys
python3 -m pip install -r /tmp/yggdrasil_get_keys/requirements.txt
python3 /tmp/yggdrasil_get_keys/yggdrasil_get_keys.py \
    --genkeys="/opt/YGGDRASIL/genkeys" \
    --yggdrasil-conf="/opt/YGGDRASIL/yggdrasil.conf" \
    --timeout=60 \
    --environment
rm -rf /tmp/yggdrasil_get_keys
git clone --depth 1 --branch v3 https://github.com/oldnick85/yggdrasil_find_public_peers.git /tmp/yggdrasil_find_public_peers
python3 -m pip install -r /tmp/yggdrasil_find_public_peers/requirements.txt
python3 /tmp/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="/opt/YGGDRASIL/yggdrasil.conf" \
    --parallel=4 \
    --pings=10 \
    --best=5 \
    --ping-interval=0.5
rm -rf yggdrasil_find_public_peers
sysctl net.ipv6.conf.all.disable_ipv6=0 || true
/opt/YGGDRASIL/yggdrasil -useconffile /opt/YGGDRASIL/yggdrasil.conf &
sleep 1m
/opt/I2PD/i2pd --datadir /opt/I2PD --conf /opt/I2PD/i2pd.conf &
wait -n
exit $?    