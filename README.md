# Work in progress!!!

This branch is intended to add support for mounting [Google Cloud Storage](https://cloud.google.com/storage) buckets via [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse), using parts of the Dockerfile provided by [Ernest's docker-gcsfuse](https://github.com/chiaen/docker-gcsfuse).

## Caveats

* ``gcsfuse`` is unable to mount. I'm researching why.  

## Differences between Master and gcsfuse branch

* Dockerfile were modified to add instruccion to build gcsfuse
* ``EXPOSE`` and ``VOLUME`` statements has been removed from Dockerfile in order to expose the port from ``docker-compose.yml``)
* Config files were added to boot with GCS bucket mounted
* ``/download`` volume is not longer exposed. Instead, it is mounted via FUSE inside the container

## Building locally

### Pre-requisites
* git
* docker.io
* docker-compose

```
apt-get install git docker.io docker-compose
```

### Building from git repo
```
git clone --branch gcsfuse https://github.com/Amitie10g/docker-transmission.git
cd docker-transmission
docker build \
  --no-cache \
  --pull \
  --compress \
  -t amitie10g/transmission:latest .
```
## Running (docker-composte style)

* Copy ``docker-compose.yml.orig`` to ``docker-compose.yml.orig`` and edit it :
  * Replace ``<config path>`` with the local directories you want to expose
  * Replace the UID and GID (run ``id -u $(whoami)`` and ``id -g $(whoami)`` to get them).

* Create ``<config path>/config/gcsfuse-key.json`` with the [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

* Create ``<config path>/config/bucket`` with the GCS bucket name

* run ``docker-compose up -d``

The full instructions and stuff is available in the original [README.md](https://github.com/linuxserver/docker-transmission/blob/master/README.md) file.
