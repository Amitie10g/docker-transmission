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
    ar \
	curl \
	findutils \
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
 mv /tmp/twctemp/src /transmission-web-control

RUN echo "**** install gcsfuse ****"
RUN mkdir /tmp/gcsfuse
RUN cd /tmp/gcsfuse
RUN curl -o \
        /tmp/gcsfuse/gcsfuse.deb -L \
        "https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v$GCSFUSE_VERSION/gcsfuse_$GCSFUSE_VERSION_amd64.deb"
RUN ar -v x gcsfuse.deb
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
