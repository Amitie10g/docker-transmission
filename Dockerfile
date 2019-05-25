FROM lsiobase/alpine:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GCSFUSE_VERSION=0.27.0
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Amitie10g"

# install packages
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
  ca-certificates \
  curl \
  dpkg \
  findutils \
  fuse \
  jq \
  openssl \
  p7zip \
  python \
#  rsync \
  tar \
  transmission-cli \
  transmission-daemon \
#  unrar \
  unzip && \
 echo "**** install third party themes ****" && \
 curl -o \
  /tmp/combustion.zip -L \
  "https://github.com/Secretmapper/combustion/archive/release.zip" && \
 unzip \
  /tmp/combustion.zip -d \
  / && \
 mkdir -p /tmp/twctemp && \
 TWCVERSION=$(curl -sX GET "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
  /tmp/twc.tar.gz -L \
  "https://github.com/ronggang/transmission-web-control/archive/${TWCVERSION}.tar.gz" && \
 tar xf \
  /tmp/twc.tar.gz -C \
  /tmp/twctemp --strip-components=1 && \
 mv /tmp/twctemp/src /transmission-web-control
 
# install gcsfuse
RUN curl -o \
  /tmp/gcsfuse.deb -L \
  "https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v${GCSFUSE_VERSION}/gcsfuse_${GCSFUSE_VERSION}_amd64.deb"
RUN touch /var/lib/dpkg/status
RUN dpkg --force-all -i /tmp/gcsfuse.deb

# cleanup
RUN echo "**** cleanup ****"
RUN apk del --purge dpkg
RUN /var/lib/dpkg/status
RUN rm -rf /tmp/*

# copy local files
COPY root/ /
COPY --from=builder usr/bin/gcsfuse /usr/bin/gcsfuse
COPY --from=builder sbin/mount.gcsfuse /sbin/mount.gcsfuse
COPY --from=builder sbin/mount.fuse.gcsfuse /sbin/mount.fuse.gcsfuse

WORKDIR /
# ports and volumes
EXPOSE 9091 51413
VOLUME /config /watch
