#!/bin/bash

PACKAGE=vips
DATE=`date --iso-8601=minutes`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${DISTRIBUTION}" ]; then
	echo Define environment variable DISTRIBUTION "(e.g. focal)"
	exit 1
fi

if [ -z "${DISTVERSION}" ]; then
	echo Define environment variable DISTVERSION "(e.g. 20.04)"
	exit 1
fi

if [ -z "${PACKAGE}" ]; then
	echo Define environment variable PACKAGE "(e.g. vips)"
	exit 1
fi

echo Building base image:

docker build -t build-$PACKAGE:$DISTVERSION -f $DIR/Dockerfile-$PACKAGE-$DISTVERSION $DIR || (echo build failed 1>&2 && exit 1)

echo

if [ ! -d ~/.buildvers ]; then
	mkdir -p ~/.buildvers
fi

if [ -f ~/.buildvers/$PACKAGE-$DISTRIBUTION ]; then
	OLDVERSION=`cat ~/.buildvers/$PACKAGE-DISTRIBUTION`
	NEWVERSION=`docker run --rm build-$PACKAGE:$DISTVERSION bash -c "apt-get -qq update && rmadison $PACKAGE | grep $DISTRIBUTION | awk {'print $3'}"`
	if [ "$OLDVERSION" = "$NEWVERSION" ]; then
		echo Versions match, no need to update
		exit
	fi
	echo Version changed from $OLDVERSION to $NEWVERSION, creating new package
else
	echo No old version found, creating new package
fi

echo -n Press enter to continue or Ctrl-C to abort:' '
read

clean_gpg() {
	rm /tmp/volume-$PACKAGE-$DISTRIBUTION/keys.asc
	exit
}

trap clean_gpg SIGINT SIGTERM EXIT

mkdir -p /tmp/volume-$PACKAGE-$DISTRIBUTION
gpg --export-secret-keys --armor >> /tmp/volume-$PACKAGE-$DISTRIBUTION/keys.asc || echo "Couldn't write GPG keys" && exit 1

docker run --rm -i -v /tmp/volume-$PACKAGE-$DISTRIBUTION:/volume build-$PACKAGE-$DISTVERSION bash -s <<EOF
gpg --import /volume/keys.asc || exit 1
mkdir -p /tmp/build-$PACKAGE-$DISTRIBUTION-$DATE && cd /tmp/build-$PACKAGE-$DISTRIBUTION-$DATE
apt-get -q -y source $PACKAGE || exit 1

cd `find . -mindepth 1 -maxdepth 1 -type d`/debian || exit 1

cat control | sed 's/^Build-Depends: /Build-Depends: libheif-dev, /' > control.new
mv control.new control

dch --local tonimelisma --distribution $DISTRIBUTION 'Add HEIF support' || exit 1
debuild -S -sd || exit 1
cd ../..
dput ppa:$PPANAME/ppa `find . -type f -name '*source.changes'`
EOF
gpg_clean

echo -n Press enter to mark $NEWVERSION as successfully uploaded or Ctrl-C to abort:' '
read

echo $NEWVERSION > ~/.buildvers/$PACKAGE-$DISTRIBUTION