# I2PD_YGGDRASIL_DOCKER

## Description

This project is a set of tools for building [I2PD](https://i2pd.website/) over [YGGDRASIL](https://yggdrasil-network.github.io/) docker images.
No clearnet for i2p, only yggdrasil!

At startup, the script searches YGGDRASIL public peers and chooses several best of them. 
Then it generates YGGDRASIL *PublicKey* and *PrivateKey* unless the keys not set in environment variables.

## Building

You can build docker image by simply run script *make_i2pd_yggdrasil_docker_image.sh*. 

> bash make_i2pd_yggdrasil_docker_image.sh

Feel free to modify it with your own building arguments.

## Running

To run docker container just run script *run_i2pd_yggdrasil_docker_image.sh*

> bash run_i2pd_yggdrasil_docker_image.sh

## Deploy

To deploy built image to your host just execute this from command line

> docker save i2pd_yggdrasil:latest | bzip2 | pv | ssh user@host docker load

> scp run_i2pd_yggdrasil_docker_image.sh user@host:.