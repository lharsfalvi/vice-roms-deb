#!/bin/bash
set -e

# *** Needs ***
# build-essential
# devscripts
# cdbs
# equivs
# fakeroot
# subversion

# *** Use ***
# ./makedeb.sh                (looks up version from installed / available VICE package)
# ./makedeb.sh *version*      (attempts to pull and package ROMs for specified VICE version tag)


function error {
    echo "$1" 1>&2
    exit 1
}

function formatver {
    local v=$(echo $1|sed 's/^v//')
    echo $v | grep -Pq '^\d+\.\d+\.0' && v=$(echo $v|grep -Po '^\d+\.\d+')
    R="$v"
}

function getosviceversion {
    dpkg -s dpkg >/dev/null 2>&1 || error "Dpkg looks nonfunctional. Use a dpkg/apt based system."
    if dpkg -s vice >/dev/null 2>&1; then 
        local ver=$(dpkg -s vice|grep Version)
    else
	apt-cache policy vice > /dev/null 2>&1 || error "VICE is unavailable. Try supplying the required version number manually."
	local ver=$(apt-cache policy vice | grep Candidate)
    fi

    R=$(echo "$ver" | grep -Po '\K\d+\.\d+\.*\d*')
}


##### Main #####

APPNAME="vice-roms"
SRC_URI="https://svn.code.sf.net/p/vice-emu/code"
DATE=$(LC_ALL=C date -R)

if [ $# -eq 0 ]; then
    getosviceversion
    formatver "$R"
    VERSION="$R"
else
    formatver "$1"
    VERSION=$R
fi

TAG="v$VERSION"

DVERSION="$VERSION-1"
SRCDIR="vice-roms_$APPNAME_$DVERSION.orig"
URI="$SRC_URI/tags/$TAG/vice/data"

CDIR=$(pwd)
WORKDIR=`mktemp -d`

cd "$WORKDIR"
mkdir "$SRCDIR"
svn export "$URI" "$SRCDIR/data" || error "Couldn't svn export $URI, version number may be invalid."

cd "$SRCDIR"
rm -rf data/common data/GLSL
find data -name '*.v??' -o -name '*.sym' -o -name '*.am' -o -name '*.in' | xargs rm -f
cp -r "$CDIR/debian" .
sed -i "s/DVERSION/$DVERSION/" debian/changelog
sed -i "s/DATE/$DATE/" debian/changelog
sed -i "s/VERSION/$VERSION/" debian/control

debuild -i -us -uc -b || error "Build failed, verify prerequisite packages."

cd "$CDIR"
mv $WORKDIR/vice-roms_*_all.deb .

rm -rf "$WORKDIR"
