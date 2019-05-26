#!/bin/bash -e

# Local Environment variables (set manually if necessary)
PUID=<User ID>
PGID=<Group ID>
BUCKET=<Bucket>
CONF_PATH=<config path>
WATCH_PATH=<watch path>
BIN_PATH=<watch path>
SERVICE_ACCOUNT=<service account name>
PROJECT_ID=<project ID>
CONTAINER_NAME="transmission"
CONTAINER_IMAGE="amitie10g/docker-transmission:latest"
TZ="UTC"

# Create the directories
mkdir -p $CONF_PATH $WATCH_PATH $BIN_PATH
chown -R $PUID:$PGID $CONF_PATH $WATCH_PATH $BIN_PATH

# Update docker-helper.sh
curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Amitie10g/docker-transmission/gcsfuse/scripts/docker-helper.sh > $BIN_PATH/docker-helper.sh
chmod 755 $BIN_PATH/docker-helper.sh

# Save the variables to /etc/environment
{
echo "PUID=\"$PUID\""
echo "PGID=\"$PGID\""
echo "BUCKET=\"$BUCKET\""
echo "TZ=\"$TZ\""
echo "CONF_PATH=\"$CONF_PATH\""
echo "WATCH_PATH=\"$WATCH_PATH\""
echo "CONTAINER_NAME=\"$CONTAINER_NAME\""
echo "CONTAINER_IMAGE=\"$CONTAINER_IMAGE\""
echo "PATH=\"$PATH:$BIN_PATH/bin\""
} >> /etc/environment

# Download the key via gcloud, if available
if ! [ -x "$(command -v gcloud)" ]; then
	gcloud iam service-accounts keys create $CONF_PATH/gcs-key.json \
	--iam-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
fi
# If you want to inplement via Container deployment feature at Google Cloud, ommit the following
# Start the container, if the Service account key is found
if [ -f "$CONF_PATH/gcs-key.json" ]; then
	docker-helper start
	# Workarround for Container-optimized OS (comment above and uncomment bellow)
	#bash $BIN_PATH/docker-helper.sh start
else 
	ERROR="Please upload the Service Account Key to '\$HOME/config/gcs-key.json', then run 'docker-helper start'."
	echo "$ERROR" >&2
fi
