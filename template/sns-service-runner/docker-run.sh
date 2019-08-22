#/bin/bash

function CheckNetwork() {
  DOCKER_NETWORK_IDS=$(docker network ls | grep 'nodehome-net' | awk '{print $2}')
  if [ -z "$DOCKER_NETWORK_IDS" -o "$DOCKER_NETWORK_IDS" == " " ]; then
    docker network create --attachable --driver bridge nodehome-net
  fi
}

if [ $# -lt 1 ]; then
  echo "Usage : $0 <start/stop>"
fi

if [ "$1" == "start" ];  then
  CheckNetwork
  docker-compose -f docker-compose.yaml up -d
elif [ "$1" == "stop" ];  then
  docker-compose -f docker-compose.yaml down
fi
