#!/bin/bash -e

# Docker helper - a simple shell script for managing a single docker image.
#
# Author: Davod
#
# Released to the Public domain (CC0)
#
# To the extent possible under law, the person who associated CC0 with
# Docker helper has waived all copyright and related or neighboring
# rights to Docker helper.

# Set options
while getopts b:c:w:n:i:s: option
do
case "${option}"
in
b) BUCKET=${OPTARG};;
c) CONF_PATH=${OPTARG};;
w) WATCH_PATH=${OPTARG};;
n) CONTAINER_NAME=${OPTARG};;
i) CONTAINER_IMAGE=${OPTARG};;
s) CONTAINER_SHELL=${OPTARG};;
esac
done

# Set default values for variables
if [ -z "$BUCKET" ]
then
	echo "You must provide a valid Bucket name."
	exit
fi

if [ -z "$CONF_PATH" ]
then
	CONF_PATH="$HOME/config"
fi

if [ -z "$WATCH_PATH" ]
then
	WATCH_PATH="$HOME/watch"
fi

if [ -z "$CONTAINER_NAME" ]
then
	CONTAINER_NAME="transmission"
fi

if [ -z "$CONTAINER_IMAGE" ]
then
	CONTAINER_IMAGE="Amitie10g/docker-transmission:latest"
fi

if [ -z "$TZ" ]
then
      TZ="UTC"
fi

if [ -z "$CONTAINER_SHELL" ]
then
	CONTAINER_SHELL="/bin/bash"
fi

case $1 in
	build)
		if [ ! -d "docker-transmission" ]; then
			git clone --branch gcsfuse https://github.com/Amitie10g/docker-transmission.git
		fi
		cd docker-transmission
		docker build \
		--no-cache \
		--pull \
		--compress \
		-t $CONTAINER_IMAGE .
	;;

	pull)
		docker image pull $CONTAINER_IMAGE
    ;;
  
	stop)
		docker stop $CONTAINER_NAME
		docker rm $CONTAINER_NAME
	;;
    
	rm|delete)
		docker stop $CONTAINER_NAME
		docker rm $CONTAINER_NAME
		docker image rm $CONTAINER_IMAGE
    ;;
    
	shell)
		docker exec -i -t $CONTAINER_NAME $CONTAINER_SHELL
    ;;
    
	log|logs)
		docker logs --details $CONTAINER_NAME
    ;;

	start)
		docker run -t -i -d \
			--name=$CONTAINER_NAME \
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
			--ipv6 \
			$CONTAINER_IMAGE
	;;
	*)
	echo -e "\n\033[1mUsage:\033[0m
\033[1mCommands:\033[0m
  \033[1mstart\033[0m	starts the container (pull the image from remote registry)
  \033[1mstop\033[0m	stops the container
  \033[1mrm\033[0m	stops the container and remove the associated image
  \033[1mshell\033[0m	gives access to the container shell (/bin/bash by default)
  \033[1mpull\033[0m	pulls the image to the remote registry
  \033[1mbuild\033[0m	pulls the source code from repo
  
\033[1mParameters:\033[0m
Parameters can be provided via command line or envirnment variables.
  \033[1mParam	Envirnment variable	Description			Default value\033[0m
  \033[1m-c\033[0m	\$CONF_PATH		Configuration directory		\$HOME/config
  \033[1m-w\033[0m	\$WATCH_PATH		The Configuration directory	\$HOME/watch
  \033[1m-n\033[0m	\$CONTAINER_NAME		The Container name		transmission
  \033[1m-i\033[0m	\$CONTAINER_IMAGE	The Container image		amitie10g/docker-transmission\n"
  ;;
esac
