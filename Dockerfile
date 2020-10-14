FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBFULLNAME="Toni Melisma"
ENV DEBEMAIL="toni.melisma@iki.fi"

# Enable deb-src APT sources and get build tools
RUN sed -e '/^#\sdeb-src /s/^# *//;t;d' "/etc/apt/sources.list" \
    >> "/etc/apt/sources.list.d/ubuntu-sources.list" && apt-get update
RUN apt-get -y --no-install-recommends install \
    build-essential devscripts

# Change working directory
RUN mkdir -p /tmp/build
WORKDIR /tmp/build

# Install the package we want to repackage
RUN apt-get -y build-dep vips && \
    apt-get -y install libheif-dev
RUN apt-get -y source vips
