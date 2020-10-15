#!bash

PACKAGE=vips
DATE=`date --iso-8601=minutes`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${DISTRIBUTION}" ]; then
	echo Define environment variable DISTRIBUTION (e.g. focal)
	exit 1
fi

if [ -z "${DISTVERSION}" ]; then
	echo Define environment variable DISTVERSION (e.g. 20.04)
	exit 1
fi

echo Building base image:

docker build -t build-$PACKAGE:$DISTVERSION -f $DIR/Dockerfile-$DISTVERSION $DIR || echo build failed 1>&2 && exit 1

echo

if [ -f ~/.buildvers/$PACKAGE-$DISTRIBUTION ]; then
	OLDVERSION=`cat ~/.buildvers/$PACKAGE-DISTRIBUTION`
	NEWVERSION=`docker run --rm build:20.04 bash -c "apt-get -qq update && rmadison $PACKAGE | grep $DISTRIBUTION | awk {'print $3'}"`
	if [ "$OLDVERSION" = "$NEWVERSION" ]; then
		echo Versions match, no need to update
		exit
	fi
else
	echo No old version found, creating new package
fi

echo End
exit 

COPY GPG KEYS

apt-get update && rmadison $PACKAGE | grep $DISTRIBUTION | awk {'print $3'}



DOCKER RUN
set -e

mkdir -p /tmp/build-$DISTRIBUTION-$DATE
cd /tmp/build-$DATE-$DISTRIBUTION


gpg --import /volume/keys.asc
cd /tmp/build
apt-get -y source vips
cd `find . -mindepth 1 -maxdepth 1 -type d`/debian

cat control | sed 's/^Build-Depends: /Build-Depends: libheif-dev, /' > control.new
mv control.new control

dch --local tonimelisma --distribution `lsb_release -cs` 'Add HEIF support'

debuild -S -sd

cd ../..

dput ppa:tonimelisma/ppa `find . -type f -name '*source.changes'`

DELETE GPG KEYS
