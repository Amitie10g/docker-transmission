#!/bin/bash -e

# Startup script for updating docker-helper and set envirnment variables
#
# Author: Davod
#
# Released to the Public domain (CC0)
#
# To the extent possible under law, the person who associated CC0 with
# Docker helper has waived all copyright and related or neighboring
# rights to Docker helper.

# Update docker-helper.sh
curl https://github.com/Amitie10g/docker-transmission/blob/gcsfuse/scripts/docker-helper.sh --output /bin/docker-helper.sh
chmod 755 /bin/docker-helper.sh

# Local Environment variables (edit as you need)
PUID=<User ID>
PGID=<Group ID>
BUCKET=<Bucket>
TZ="UTC"
CONF_PATH=<config path>
WATCH_PATH=<watch path>
CONTAINER_NAME="transmission"
CONTAINER_IMAGE="amitie10g/docker-transmission:latest"

# Create the directories
mkdir -p $CONF_PATH $WATCH_PATH

# Save the variables to /etc/environment
echo "PUID=\"$PUID\"" >> /etc/environment
echo "PGID=\"$PGID\"" >> /etc/environment
echo "BUCKET=\"$BUCKET\"" >> /etc/environment
echo "TZ=\"$TZ\"" >> /etc/environment
echo "CONF_PATH=\"$CONF_PATH\"" >> /etc/environment
echo "WATCH_PATH=\"$WATCH_PATH\"" >> /etc/environment
echo "CONTAINER_NAME=\"$CONTAINER_NAME\"" >> /etc/environment
echo "CONTAINER_IMAGE=\"$CONTAINER_IMAGE\"" >> /etc/environment

if [ -f "CONF_PATH/gcs-key.json" ]; then
  docker-helper start
else 
  ERROR="Please upload the Service Account Key to '\$HOME/config/gcs-key.json', then run 'docker-helper start'.\n"
  echo $ERROR
  echo $ERROR >&2
fi
