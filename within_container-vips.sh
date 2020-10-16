#!/bin/sh

echo Building package $PACKAGE for distribution $DISTRIBUTION to PPA $PPANAME on date $DATE

gpg --import /volume/keys.asc || exit 1
mkdir -p /tmp/build-$PACKAGE-$DISTRIBUTION-$DATE && cd /tmp/build-$PACKAGE-$DISTRIBUTION-$DATE
apt-get -q -y source $PACKAGE || exit 1

SRCDIR=`find . -mindepth 1 -maxdepth 1 -type d`
echo Source dir is "$SRCDIR"
cd "$SRCDIR/debian" || exit 1

cat control | sed 's/^Build-Depends: /Build-Depends: libheif-dev, /' > control.new
mv control.new control

dch --local tonimelisma --distribution $DISTRIBUTION 'Add HEIF support' || exit 1
debuild -S -sd || exit 1
cd ../..
dput ppa:$PPANAME/ppa `find . -type f -name '*source.changes'`
