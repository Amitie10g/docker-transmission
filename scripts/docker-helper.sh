#!/bin/bash

# Set default values for variables
if [ -z $CONF_PATH ]
then
    CONF_PATH="$HOME/config"
fi

# Set default values for variables
if [ -z $LOCAL_HOME ]
then
    LOCAL_HOME="/root"
fi

if [ -z $WATCH_PATH ]
then
    WATCH_PATH="$HOME/watch"
fi

if [ -z $CONTAINER_NAME ]
then
    CONTAINER_NAME="transmission"
    #CONTAINER_NAME=$(docker -lq)
fi

if [ -z $CONTAINER_IMAGE ]
then
    CONTAINER_IMAGE="amitie10g/docker-transmission:latest"
fi

if [ -z $TZ ]
then
      TZ="UTC"
fi

if [ -z $CONTAINER_SHELL ]
then
    CONTAINER_SHELL="/bin/bash"
fi

# If $PRIVILEGED is set to false, change to null
if [ "$PRIVILEGED" != false ]
then
    PRIVILEGED="--privileged"
else
	PRIVILEGED=
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
        echo "Retriveing $CONTAINER_IMAGE..."
        docker image pull $CONTAINER_IMAGE
    ;;
  
    stop)
        echo "Removing $CONTAINER_IMAGE..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    ;;
    
    rm|delete)
        echo "Stoping $CONTAINER_NAME and removing $CONTAINER_IMAGE..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        docker image rm $CONTAINER_IMAGE
    ;;
    
    shell)
        echo "Opening shell for $CONTAINER_NAME..."
        docker exec -i -t $CONTAINER_NAME $CONTAINER_SHELL
    ;;
    
    log|logs)
        echo "Showing logs for $CONTAINER_NAME..."
        docker logs --details $CONTAINER_NAME
    ;;

    start)
        docker run -t -i -d \
            --name=$CONTAINER_NAME \
            -e PUID=$PUID \
            -e PGID=$PGID \
	    -e LOCAL_HOME=$LOCAL_HOME \
            -e TZ=$TZ \
            -e CLIENT_ID=$CLIENT_ID \
	    -e CLIENT_SECRET=$CLIENT_SECRET \
	    -e VERIFICATION_CODE=$VERIFICATION_CODE \
	    -e MOUNT_OPTS=$MOUNT_OPTS \
            -e TRANSMISSION_WEB_HOME=/combustion-release/ \
            -p 9091:9091 \
            -p 51413:51413 \
            -p 51413:51413/udp \
            --device=/dev/fuse \
            --restart unless-stopped \
            $PRIVILEGED \
            $CONTAINER_IMAGE
    ;;

    *)
    echo -e "\033[1mUsage:\033[0m docker-helper command
\033[1mAlternate container:\033[0m env CONTAINER_NAME=<container name> docker-helper command
\033[1mCommands:\033[0m
  \033[1mstart\033[0m    starts the container (pull the image from remote registry)
  \033[1mstop\033[0m    stops the container
  \033[1mrm\033[0m    stops the container and remove the associated image
  \033[1mshell\033[0m    gives access to the container shell (/bin/bash by default)
  \033[1mpull\033[0m    pulls the image to the remote registry
  \033[1mbuild\033[0m    pulls the source code from repo
  
\033[1mEnvirnment variables:\033[0m
  \033[1m\$CONF_PATH\033[0m        Configuration directory        \$HOME/config
  \033[1m\$WATCH_PATH\033[0m        The Configuration directory    \$HOME/watch
  \033[1m\$CONTAINER_NAME\033[0m    The Container name        transmission
  \033[1m\$CONTAINER_IMAGE\033[0m    The Container image        amitie10g/docker-transmission"
  ;;
esac
