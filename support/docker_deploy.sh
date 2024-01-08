#!/bin/bash
echo "Deploy i2pd yggdrasil"
host=$(cat secrets/settings.json | jq -r .deploy.host)
user=$(cat secrets/settings.json | jq -r .deploy.user)
path=$(cat secrets/settings.json | jq -r .deploy.path)
echo "    stop docker container"
ssh -l ${user} ${host} "cd ${path} ; docker-compose down"
echo "    upload docker images"
ssh ${user}@${host} "mkdir -p ${path}"
docker save i2pd_yggdrasil:latest | bzip2 | pv | ssh ${user}@${host} docker load
echo "    upload docker compose"
scp src/docker-compose.yml ${user}@${host}:${path}
echo "    start docker container"
ssh -l ${user} ${host} "cd ${path} ; docker-compose up -d"
echo "    all done"
