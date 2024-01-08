# I2PD_YGGDRASIL_DOCKER

## Description

This project is a set of tools for building [I2PD](https://i2pd.website/) over [YGGDRASIL](https://yggdrasil-network.github.io/) docker images.
No clearnet for i2p, only yggdrasil!

At startup, the script searches YGGDRASIL public peers and chooses several best of them. 
Then it generates YGGDRASIL *PublicKey* and *PrivateKey* unless the keys not set in environment variables.

## Preparations

Before building and deploying i2pd_yggdrasil docker image, you need to run the script

> bash support/requirements.sh

## Building

You can build docker image by simply run script *make_i2pd_yggdrasil_docker_image.sh*. 

> bash support/make_docker_image.sh

Feel free to modify it with your own building arguments.

## Running

To run docker container just use docker-compose like this

> docker-compose -f src/docker-compose.yml up -d

## Deploy

To deploy built image to your host use script

> bash support/docker_deploy.sh

Note, this script takes parameters from *secrets/settings.json*, look *secrets/settings_pattern.json* for example.