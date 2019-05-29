FROM FROM ocaml/opam2:alpine AS builder
RUN OPAMYES=true opam init && \
  OPAMYES=true opam depext google-drive-ocamlfuse && \
  OPAMYES=true opam install google-drive-ocamlfuse && \
  mv /root/.opam/system/bin/google-drive-ocamlfuse /bin/google-drive-ocamlfuse

# Base
FROM lsiobase/alpine:3.9
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"
ENV DRIVE_PATH="/drive"
ENV LABEL="gdrive"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl \
	findutils \
	fuse \
	jq \
	libressl2.4-libtls \
	libgmpxx \
	ncurses-libs \
	openssl \
	p7zip \
	python \
	rsync \
	sqlite-libs \
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
COPY --from=builder /bin/google-drive-ocamlfuse /usr/bin/google-drive-ocamlfuse
COPY --from=builder /init.sh /usr/bin/gdrive-init.sh

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /watch
