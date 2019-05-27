# Work in progress!!!

This branch is intended to add support for mounting [Google Cloud Storage](https://cloud.google.com/storage) buckets via [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse), using parts of the Dockerfile provided by [Ernest's docker-gcsfuse](https://github.com/chiaen/docker-gcsfuse).

I've uploaded the image to [Docker Hub](https://cloud.docker.com/u/amitie10g/repository/docker/amitie10g/docker-transmission). Tags available are:
* ``latest`` with the same packages defined in the original Dockerfile, plus ``fuse``.
* ``minimal`` with some packages removed, including the web interface, in order to save some megabytes.

## Differences between Master and gcsfuse branch

* ``/download`` volume is not longer exposed. Instead, it is mounted via FUSE **inside** the container
* The following files were modified:
  * ``Dockerfile``, to add instructions to build ``gcsfuse`` and ``mount.gcsfuse`` using the ``golang:alpine`` image.
  * ``root/etc/cont-init.d/20-config``, with instructions to update ``/etc/fstab`` and mounting the docker via ``mount.gcsfuse``

## Running

### Before begin
* ``<config path>`` and ``<watch path>`` refers to the local direcctories you want to expose.

* Get your [Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for your bucket, and upload to <config path>/gcsfuse-key.json. (if you're running the VM at Google Cloud, the key can be reteived as custom metadata).
 
* If you're running the VM at Google Cloud with **oslogin** enabled, you may obtain your user and group id by running ``$ id`` inside another VM with ``oslogin`` enabled (associated to the same Service account).
  
* Don't forget to set the right permissions for your bucket.

* ``scripts/docker-helper.sh`` is a script aimed to ease the container managenet.

* If you want to use the **docker-compose** way, edit ``scripts/docker-compose.yml`` as you need.

* ``scripts/startup.sh`` is a script intended to run at bootup (you may upload to the VM, or provide it externally). This will update ``docker-helper.sh`` and the Account service key, and will set the proper environment variables. Edit as you need.

* ``scripts/startup-gcloud.sh`` is a ready-to-use startup script to be used for VMs running at Google Cloud.

### Command line
* ``docker-helper start`` starts the container
* ``docker-helper shell `` give access to the container shell
* ``docker-helper stop`` stops the container
* ``docker-helper rm`` stops the container and remove the image
* ``docker-helper log`` shows the logs

### docker-compose style
```docker-compose up -d```

### Using the Container deployment feature at Google Cloud

* Select **Container-optimized OS** as boot image.
* Mark **Deploy a container image to this VM instance**, and,
  * Set ``amitie10g/docker-transmission`` as the container name (tags available are ``latest`` and ``minimal``).
  * Mark **Run as privileged** (needed for Linux prior to 4.18).
  * Fill the following envirnment variables:
    * ``PUID`` with your user ID (see above)
    * ``PGID`` with your group ID
    * ``BUCKET`` with your bucket name
    * ``TZ`` with the local time zone (or just set UTC)
  * Add the following Volume mounts (as directory):
    * ``/config/`` with your data directory.
    * ``/watch`` with your watch directory.
* At **Access scopes**, select "Allow full access to all Cloud APIs".
* At **Automation** (click in "Management, security, disks, networking, sole tenancy" to deploy):
  * Fill the **Startup script** with the contents of ``scripts/startup-gcloud.sh``.
  * Fill the following custom **Metadata**:
    * ``enable-oslogin`` as ``true`` (either at the VM or globally).
    * ``gcs-key`` with the Account service key.

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
