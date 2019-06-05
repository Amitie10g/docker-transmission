FROM amitie10g/gcsfuse AS builder

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
COPY --from=builder /usr/bin/gcsfuse /usr/bin/gcsfuse
COPY --from=builder /usr/sbin/mount.gcsfuse /usr/sbin/mount.gcsfuse
RUN ln -s /usr/sbin/mount.gcsfuse /usr/sbin/mount.fuse.gcsfuse

WORKDIR /

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /watch
