#!/bin/bash

# Local Environment variables
PUID=$(curl -f "http://metadata.google.internal/computeMetadata/v1/oslogin/users?pagesize=1" -H "Metadata-Flavor: Google" | python -c "import sys, json; print(json.load(sys.stdin)['loginProfiles'][0]['posixAccounts'][0]['uid'])")
PGID=$(curl -f "http://metadata.google.internal/computeMetadata/v1/oslogin/users?pagesize=1" -H "Metadata-Flavor: Google" | python -c "import sys, json; print(json.load(sys.stdin)['loginProfiles'][0]['posixAccounts'][0]['gid'])")
USER=$(curl -f "http://metadata.google.internal/computeMetadata/v1/oslogin/users?pagesize=1" -H "Metadata-Flavor: Google" | python -c "import sys, json; print(json.load(sys.stdin)['loginProfiles'][0]['posixAccounts'][0]['username'])")
LOCAL_HOME=$(curl -f "http://metadata.google.internal/computeMetadata/v1/oslogin/users?pagesize=1" -H "Metadata-Flavor: Google" | python -c "import sys, json; print(json.load(sys.stdin)['loginProfiles'][0]['posixAccounts'][0]['homeDirectory'])")

CONF_PATH=$LOCAL_HOME/config
WATCH_PATH=$LOCAL_HOME/watch

# Create the directories
mkdir -p $CONF_PATH $WATCH_PATH
chown -R $PUID:$PGID $LOCAL_HOME

# Install or update docker-helper.sh (optional)
curl -f "https://raw.githubusercontent.com/Amitie10g/docker-transmission/gcsfuse/scripts/docker-helper.sh > $LOCAL_HOME/docker-helper.sh" \
-H 'Cache-Control: no-cache' -o $LOCAL_HOME/docker-helper.sh
chmod 755 $LOCAL_HOME/docker-helper.sh

# Download the Settings from custom metadata
curl -f "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SETTINGS" \
-H "Metadata-Flavor: Google" -o $CONF_PATH/settings.json
chown $PUID:$PGID $CONF_PATH/settings.json

# Download the Account service key from custom metadata
curl -f "http://metadata.google.internal/computeMetadata/v1/instance/attributes/GCSKEY" \
-H "Metadata-Flavor: Google" -o $CONF_PATH/gcs-key.json

# Check if the Service account key has been found
if [ -f "$CONF_PATH/gcs-key.json" ]; then
	chown $PUID:$PGID $CONF_PATH/gcs-key.json
else
	ERROR="Please set the custom metadata gcs-key or upload the key to the VM."
	echo "$ERROR" >&2
fi
