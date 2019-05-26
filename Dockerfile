FROM golang:alpine AS builder
ARG GCSFUSE_VERSION=0.27.0
RUN apk --update --no-cache add git fuse fuse-dev;
RUN go get -d github.com/googlecloudplatform/gcsfuse
RUN go install github.com/googlecloudplatform/gcsfuse/tools/build_gcsfuse
RUN build_gcsfuse ${GOPATH}/src/github.com/googlecloudplatform/gcsfuse /tmp ${GCSFUSE_VERSION}

FROM lsiobase/alpine:3.9
# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
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
 mv /tmp/twctemp/src /transmission-web-control && \
 echo "**** cleanup ****" && \
 rm -rf \
        /tmp/*

# copy local files
COPY root/ /
COPY --from=builder /tmp/bin/gcsfuse /usr/bin
COPY --from=builder /tmp/sbin/mount.gcsfuse /usr/sbin
RUN ln -s /usr/sbin/mount.gcsfuse /usr/sbin/mount.fuse.gcsfuse

WORKDIR /

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /watch
