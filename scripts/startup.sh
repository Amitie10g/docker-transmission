#!/bin/bash

# Local Environment variables
PUID=
PGID=
LOCAL_HOME=
MOUNT_OPTS=
CLIENT_ID=
CLIENT_SECRET=
VERIFICATION_CODE=
REMOTE_DIR=
TEAMDRIVE=
CONTAINER_NAME="transmission"
CONTAINER_IMAGE="amitie10g/docker-transmission:gdrive-ocamlfuse"
TZ="UTC"

# Don't modify the following
CONF_PATH=$LOCAL_HOME/config
WATCH_PATH=$LOCAL_HOME/watch
INCOMPLETE_PATH=$LOCAL_HOME/downloads/incomplete

# Create the directories
mkdir -p $CONF_PATH $WATCH_PATH $INCOMPLETE_PATH
chown -R $PUID:$PGID $LOCAL_HOME

# Uncomment if you have Linux 4.18 or above, as --privileged is not longer needed
#PRIVILEGED=false

# Install or update docker-helper.sh (optional)
curl -f "https://github.com/Amitie10g/docker-transmission/raw/gdrive-ocamlfuse/scripts/docker-helper.sh \
-H 'Cache-Control: no-cache' -o $LOCAL_HOME/docker-helper.sh
chmod 755 $LOCAL_HOME/docker-helper.sh

# Save the variables to /etc/environment
{
echo "PUID=\"$PUID\""
echo "PGID=\"$PGID\""
echo "LOCAL_HOME=\"$LOCAL_HOME\""
echo "MOUNT_OPTS=\"$MOUNT_OPTS\""
echo "CLIENT_ID=\"$CLIENT_ID\""
echo "CLIENT_SECRET=\"$CLIENT_SECRET\""
echo "VERIFICATION_CODE=\"$VERIFICATION_CODE\""
echo "REMOTE_DIR=\"$REMOTE_DIR\""
echo "TEAMDRIVE=\"$TEAMDRIVE\""
echo "TZ=\"$TZ\""
echo "CONF_PATH=\"$CONF_PATH\""
echo "WATCH_PATH=\"$WATCH_PATH\""
echo "CONTAINER_NAME=\"$CONTAINER_NAME\""
echo "CONTAINER_IMAGE=\"$CONTAINER_IMAGE\""
echo "PATH=\"$PATH:$BIN_PATH/bin\""
} >> /etc/environment

# Remove duplicated entries
awk '!a[$0]++' /etc/environment > /tmp/environment
mv /tmp/environment /etc/environment

# Uncomment if you want to download the key via gcloud, if available at the host side and already logged in
#if [ ! -x "$(command -v gcloud)" ]; then
#	gcloud iam service-accounts keys create $CONF_PATH/gcs-key.json \
#	--iam-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
#fi

if [ -f "$CONF_PATH/gcs-key.json" ]; then
	chown -R $PUID:$PGID $CONF_PATH/gcs-key.json
	# Start the container using docker-helper. If you're using docker-compose or the
	# Container deployment at Google Cloud, you may comment the following
	docker-helper start
else
	ERROR="Please upload the Service Account Key to '\$HOME/config/gcs-key.json', then run 'docker-helper start'."
	echo "$ERROR" >&2
fi
