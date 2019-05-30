#!/bin/bash

# Local Environment variables
PUID= 
PGID= 
LOCAL_HOME= 
BUCKET= 
SERVICE_ACCOUNT=
PROJECT_ID=
CONTAINER_NAME="transmission"
CONTAINER_IMAGE="amitie10g/transmission:latest"
TZ="UTC"

# Don't modify the following
CONF_PATH=$LOCAL_HOME/config
WATCH_PATH=$LOCAL_HOME/watch
COMPLETE_PATH=$LOCAL_HOME/downloads/complete
INCOMPLETE_PATH=$LOCAL_HOME/downloads/incomplete

# Uncomment if you have Linux 4.18 or above, as --privileged is not longer needed
#PRIVILEGED=false

# Create the directories
mkdir -p $CONF_PATH $WATCH_PATH $COMPLETE_PATH $INCOMPLETE_PATH
chown -R $LOCAL_HOME

# Install or update docker-helper.sh (optional)
curl -fSs "https://raw.githubusercontent.com/Amitie10g/docker-transmission/gcsfuse/scripts/docker-helper.sh \
-H 'Cache-Control: no-cache' -o $HOME/docker-helper.sh
chmod 755 $HOME/docker-helper.sh

# Save the variables to /etc/environment
{
echo "PUID=\"$PUID\""
echo "PGID=\"$PGID\""
echo "LOCAL_HOME=\"$LOCAL_HOME\""
echo "BUCKET=\"$BUCKET\""
echo "TZ=\"$TZ\""
echo "CONF_PATH=\"$CONF_PATH\""
echo "WATCH_PATH=\"$WATCH_PATH\""
echo "COMPLETE_PATH=\"$COMPLETE_PATH\""
echo "INCOMPLETE_PATH=\"$INCOMPLETE_PATH\""
echo "CONTAINER_NAME=\"$CONTAINER_NAME\""
echo "CONTAINER_IMAGE=\"$CONTAINER_IMAGE\""
echo "PATH=\"$PATH:$BIN_PATH/bin\""
} >> /etc/environment

# Remove duplicated entries
awk '!a[$0]++' /etc/environment > /tmp/environment
mv /tmp/environment /etc/environment

# Uncomment if you want to download the key via gcloud, if available and already logged in
#if [ ! -x "$(command -v gcloud)" ]; then
#	gcloud iam service-accounts keys create $CONF_PATH/gcs-key.json \
#	--iam-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
#fi

if [ -f "$CONF_PATH/gcs-key.json" ]; then
	chown -R $PUID:$PGID $CONF_PATH/gcs-key.json
	# Start the container using docker-helper. If you're using docker-compose or the
	# Container deployment at Google Cloud, you may comment the following
	bash $HOME/docker-helper start
else
	ERROR="Please upload the Service Account Key to '\$HOME/config/gcs-key.json', then run 'docker-helper start'."
	echo "$ERROR" >&2
fi
