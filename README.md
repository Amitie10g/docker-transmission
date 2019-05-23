# Work in progress!!!

This branch is intended to add support for mounting [Google Cloud Storage](https://cloud.google.com/storage) buckets via [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse), using parts of the Dockerfile provided by [Ernest's docker-gcsfuse](https://github.com/chiaen/docker-gcsfuse).

I've uploaded the image to Docker Hub.

## Caveats

* ``gcsfuse`` refuses to mount with ``no such file or directory`` when providing a mount point. I opened a [thread at Server Fault](https://serverfault.com/questions/968292/no-such-file-or-directory-when-mounting-built-using-the-golangalpine-docker) while I'm still researching for a solution.
* I got an Error 403 when accessing to the web interface from the host-side (http://127.0.0.1:9091). I found a workarround by using the IP range corresponding to the network used by Docker. This does not happen with the vanilla image.

## Differences between Master and gcsfuse branch

* Dockerfile were modified to add instruccion to build gcsfuse
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

### Build the image locally from repo (if you want to make changes)
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

``<config path>`` and ``<watch path>`` refers to the local direcctory where you want to expose.

* Create ``<config path>/config/gcsfuse-key.json`` with the [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

* Create ``<config path>/config/bucket`` with the GCS bucket name.

* Run ``id -u`` and ``id -g`` to get the user and group who owns the directories you want to expose.

* ``run.sh`` is a simple snippet to manage the container. Edit as you need.

* If you want to use the docker-compose way, copy ``docker-compose.yml.orig`` to ``docker-compose.yml`` and edit as you need.

### Command line
``./run``

### docker-compose style
```docker-compose up -d```

Follow the original [README.md](https://github.com/linuxserver/docker-transmission/blob/master/README.md) file for instructions for running.
