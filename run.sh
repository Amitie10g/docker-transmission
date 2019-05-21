#!/bin/bash

# Envirnment variables (set manually if necessary)
PUID=$(id -u)
PGID=$(id -g)
TZ=$(date +%Z)
CONF_PATH=./config
WATCH_PATH=./watch
NAME=transmission
IMAGE=amitie10g/docker-transmission

case $1 in
	build)
		git clone --branch gcsfuse https://github.com/Amitie10g/docker-transmission.git
		cd docker-transmission
		docker build \
			--no-cache \
			--pull \
			--compress \
			-t $IMAGE:latest .
		;;

	pull)
		docker pull $IMAGE
		;;
	
	stop)
		docker stop $NAME
		docker rm $NAME
		;;
		
	rm|delete)
		docker image rm $IMAGE
		;;
		
	shell)
		docker exec -i -t $NAME /bin/bash
		;;
		
	log|logs)
		docker logs --details $NAME
		;;

	*)
		docker create \
		  --name=$NAME \
		  -e PUID=$PUID \
		  -e PGID=$PGID \
		  -e TZ=UTC \
		  -e TRANSMISSION_WEB_HOME=/combustion-release/ \
		  -p 9091:9091 \
		  -p 51413:51413 \
		  -p 51413:51413/udp \
		  -v $CONF_PATH:/config \
		  -v $WATCH_PATH:/watch \
		  --restart unless-stopped \
		  $IMAGE
		  
		docker start transmission
		;;
esac
