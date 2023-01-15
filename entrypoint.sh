#!/bin/bash
sysctl net.ipv6.conf.all.disable_ipv6=0 || true
/YGGDRASIL/yggdrasil -useconffile /YGGDRASIL/yggdrasil.conf &
sleep 1m
/I2PD/i2pd --datadir /I2PD --conf /I2PD/i2pd.conf &
wait -n
exit $?
