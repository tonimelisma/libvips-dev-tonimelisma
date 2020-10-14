# libvips-dev-tonimelisma

This is my build script to produce libvips (image processing library) Ubuntu packages
with HEIF support. To use the packages:

`sudo add-apt-repository ppa:tonimelisma/ppa`

`sudo apt install libvips42`

Usage

`docker build -f Dockerfile-20.10 -t build-ubuntu-20.10`

`docker run --rm -it -v /tmp/volume:/volume build-ubuntu-20.10`
