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
* docker-compose (optional)

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
## Running

### Before begin

``<config path>`` and ``<watch path>`` refers to the local diredctory where you want to expose.

* Create ``<config path>/config/gcsfuse-key.json`` with the [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

* Create ``<config path>/config/bucket`` with the GCS bucket name

Follow the original [README.md](https://github.com/linuxserver/docker-transmission/blob/master/README.md) file for instructions for running.
