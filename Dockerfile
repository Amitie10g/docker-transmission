FROM lsiobase/alpine:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN echo "**** install packages ****"
RUN  apk add --no-cache \
        ca-certificates \
        curl \
        findutils \
        fuse \
        jq \
        openssl \
        p7zip \
        python \
        rsync \
        tar \
        transmission-cli \
        transmission-daemon \
        unrar \
        unzip
RUN echo "**** install third party themes ****"
RUN curl -o \
        /tmp/combustion.zip -L \
        "https://github.com/Secretmapper/combustion/archive/release.zip"
RUN unzip \
        /tmp/combustion.zip -d /
RUN mkdir -p /tmp/twctemp
RUN TWCVERSION=$(curl -sX GET "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]')
RUN curl -o \
        /tmp/twc.tar.gz -L \
        "https://github.com/ronggang/transmission-web-control/archive/${TWCVERSION}.tar.gz"
RUN tar xf \
        /tmp/twc.tar.gz -C \
        /tmp/twctemp --strip-components=1
RUN mv /tmp/twctemp/src /transmission-web-control

RUN echo "**** install gcsfuse ****"
RUN mkdir /tmp/gcsfuse
RUN cd /tmp/gcsfuse
RUN curl -o \
        /tmp/gcsfuse/gcsfuse_0.27.0_amd64.deb -L \
        "https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v0.27.0/gcsfuse_0.27.0_amd64.deb"
RUN ar x gcsfuse_0.27.0_amd64.deb
RUN tar -zxvf data.tar.gz
RUN mv /tmp/gcsfuse/sbin/mount.gcsfuse /tmp/gcsfuse/sbin/mount.fuse.gcsfuse /sbin/
RUN mv /tmp/gcsfuse/usr/bin/gcsfuse /usr/bin/

RUN echo "**** cleanup ****"
RUN rm -rf /tmp/*

# copy local files
COPY root/ /
WORKDIR /
# ports and volumes
EXPOSE 9091 51413
VOLUME /config /watch
