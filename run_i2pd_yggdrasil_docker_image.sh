#!/bin/bash
docker run --rm -d \
    --device=/dev/net/tun \
    -p 2827:2827 -p 4444:4444 -p 4447:4447 -p 7070:7070 -p 7650:7650 -p 7654:7654 -p 7656:7656 -p 10765:10765 \
    -p 10654:10654 -p 9001:9001 \
    --cap-add=NET_ADMIN --privileged \
    i2pd_yggdrasil:latest