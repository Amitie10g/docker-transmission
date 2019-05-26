# Work in progress!!!

This branch is intended to add support for mounting [Google Cloud Storage](https://cloud.google.com/storage) buckets via [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse), using parts of the Dockerfile provided by [Ernest's docker-gcsfuse](https://github.com/chiaen/docker-gcsfuse).

I've uploaded the image to [Docker Hub](https://cloud.docker.com/u/amitie10g/repository/docker/amitie10g/docker-transmission).

## Differences between Master and gcsfuse branch

* ``/download`` volume is not longer exposed. Instead, it is mounted via FUSE **inside** the container
* The following files were modified:
  * Dockerfile
  * root/etc/cont-init.d/20-config

## Running

### Before begin
* ``<config path>`` and ``<watch path>`` refers to the local direcctory where you want to expose.

* Get your [Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for your bucket, and upload to <config path>/gcsfuse-key.json.
  
* Don't forget to set the right permissions for your bucket.

* Run ``id -u`` and ``id -g`` to get the user and group who owns the directories you want to expose.

* ``scripts/docker-helper.sh`` is a script aimed to ease the container managenet.

* ``scripts/startup.sh`` is a script intended to run at bootup (you may upload to the VM, or provide it externally). This will update ``docker-helper.sh`` and set the proper envirnment variables. Edit as you need.

* If you want to use the **docker-compose** way, edit ``scripts/docker-compose.yml`` as you need.

### Command line
* ``docker-helper start`` starts the container
* ``docker-helper  shell `` give access to the container shell
* ``docker-helper  stop`` stops the container
* ``docker-helper  rm`` stops the container and remove the image
* ``docker-helper  log`` shows the logs

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
