#!/bin/bash

# Local Envirnment variables (fill)
PUID= 
PGID= 
BUCKET=
CONF_PATH=
WATCH_PATH=
TZ=UTC
NAME=transmission
IMAGE=amitie10g/docker-transmission:latest

case $1 in
  build)
    git clone --branch gcsfuse https://github.com/Amitie10g/docker-transmission.git
    cd docker-transmission
    docker build \
      --no-cache \
      --pull \
      --compress \
      -t $IMAGE .
    ;;

  pull)
    docker image pull $IMAGE
    ;;
  
  stop)
    docker stop $NAME
    docker rm $NAME
    ;;
    
  rm|delete)
    docker stop $NAME
    docker rm $NAME
    docker image rm $IMAGE
    ;;
    
  shell)
    docker exec -i -t $NAME /bin/bash
    ;;
    
  log|logs)
    docker logs --details $NAME
    ;;

  *)
    docker run -t -i -d \
      --name=$NAME \
      -e PUID=$PUID \
      -e PGID=$PGID \
      -e TZ=$TZ \
      -e BUCKET=$BUCKET \
      -e TRANSMISSION_WEB_HOME=/combustion-release/ \
      -p 9091:9091 \
      -p 51413:51413 \
      -p 51413:51413/udp \
      -v $CONF_PATH:/config \
      -v $WATCH_PATH:/watch \
      --device=/dev/fuse \
      --restart unless-stopped \
      --privileged \
      $IMAGE
    ;;
esac
