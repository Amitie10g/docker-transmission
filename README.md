# Work in progress!!!

This branch is intended to add support for mounting [Google Cloud Storage](https://cloud.google.com/storage) buckets via [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse), using parts of the Dockerfile provided by [Ernest's docker-gcsfuse](https://github.com/chiaen/docker-gcsfuse).

I've uploaded the image to [Docker Hub](https://cloud.docker.com/u/amitie10g/repository/docker/amitie10g/docker-transmission).

## Caveats

* I got an Error 403 when accessing to the web interface from the host-side (http://127.0.0.1:9091). I found a workarround by using the IP range corresponding to the network used by Docker. This does not happen with the vanilla image.

## Differences between Master and gcsfuse branch

* ``/download`` volume is not longer exposed. Instead, it is mounted via FUSE **inside** the container
* The following files were modified:
** Dockerfile
** root/etc/cont-init.d/20-config

## Running

### Before begin
* ``<config path>`` and ``<watch path>`` refers to the local direcctory where you want to expose.

* Get your [Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for your bucket (don't forget to set the right permissions), and upload to <config path>/gcsfuse-key.json.

* Run ``id -u`` and ``id -g`` to get the user and group who owns the directories you want to expose.

* ``run.sh`` is a simple snippet to manage the container. Edit as you need.

* If you want to use the **docker-compose** way, copy ``docker-compose.yml.orig`` to ``docker-compose.yml`` and edit as you need.

### Command line
* ``./run`` starts the container
* ``./run shell `` give access to the container shell
* ``./run stop`` stops the container
* ``./run rm`` stops the container and remove the image
* ``./run log`` shows the logs

### docker-compose style
```docker-compose up -d```

## Building locally

```
git clone --branch gcsfuse https://github.com/Amitie10g/docker-transmission.git
cd docker-transmission
docker build \
  --no-cache \
  --pull \
  --compress \
  -t amitie10g/transmission:latest .
```

Follow the original [README.md](https://github.com/linuxserver/docker-transmission/blob/master/README.md) file for instructions for running.
