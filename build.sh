#!bash

set -e

gpg --import /volume/keys.asc
cd /tmp/build
cd `find . -mindepth 1 -maxdepth 1 -type d`/debian

cat control | sed 's/^Build-Depends: /Build-Depends: libheif-dev, /' > control.new
mv control.new control

dch --local tonimelisma --distribution `lsb_release -cs` 'Add HEIF support'

debuild -S -sd

cd ../..

dput ppa:tonimelisma/ppa `find . -type f -name '*source.changes'`
