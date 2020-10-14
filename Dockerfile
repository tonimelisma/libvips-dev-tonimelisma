FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# Enable deb-src APT sources
RUN sed -e '/^#\sdeb-src /s/^# *//;t;d' "/etc/apt/sources.list" \
    >> "/etc/apt/sources.list.d/ubuntu-sources.list" && apt-get update
RUN apt-get -y --no-install-recommends install \
    build-essential devscripts


# Install the package we want to repackage
RUN apt-get -y source vips && \
    apt-get -y build-dep vips

# Install our own build dependencies
#RUN apt-get -y install libheif-dev

# TODO
# Needs editor
# How to automate dch
# Is debuild necessary
# Move libheif to build dependencies definition in debian/control?

# dch -n 
# debuild -b -uc -us

# equivs cdbs fakeroot dput
# inspiration: https://github.com/tsaarni/docker-deb-builder
