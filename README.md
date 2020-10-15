# libvips-dev-tonimelisma

This is my build script to produce libvips (image processing library) Ubuntu packages
with HEIF support. To install the vips packages:

`sudo add-apt-repository ppa:tonimelisma/ppa`

`sudo apt install libvips42`

## Usage for building your own Ubuntu packages

The script and Dockerfile monitor a source package in the given Ubuntu releases,
and when the source updates, it automatically creates an updated customized package
and uploads it to your PPA, so your PPA version is always up to date.

If you want to build your own Ubuntu packages with this, you will need to:
Install docker, set up a PPA at Launchpad and upload your GPG keys,
make a copy of the Dockerfile and change it to suit your build process. Then run:

`DISTRIBUTION=focal DISTVERSION=20.04 PACKAGE=vips bash build.sh`

`DISTRIBUTION=focal DISTVERSION=20.10 PACKAGE=vips bash build.sh`

You can run this from cron daily (be sure to run it as your user account)