# vice-roms-deb

## Overview

According to the [Debian](https://www.debian.org/) [VICE Emulator package](https://packages.debian.org/sid/vice), Commodore ROM files are allegedly owned by Tulip Computers NV, a Dutch company. As such, [VICE](https://sourceforge.net/projects/vice-emu/) is [DFSG compliant](https://wiki.debian.org/DebianFreeSoftwareGuidelines), but the ROM files aren't. The ROM files are typically not included in Linux distributions, due to the lack of distribution rights. The README.ROMs file of the Debian VICE package suggests manually downloading and extracting the ROM sets off, say, ftp.zimmers.net, which is kind of inconvenient (...especially that file hierarchy tends to be VICE version specific).

The included shell script builds a full-fledged vice-roms deb package, which can be managed by standard package management tools.

An additional Docker container builds the package under arbitrary (Docker capable) environments.

## Native build

This strictly needs a Debian derivative operating system.

* Install build prerequisities

		sudo apt-get install build-essential devscripts cdbs equivs fakeroot subversion

* Clone this repository
* Open a terminal, cd to the clone directory
* Run the build script.

		./makedeb.sh

* Find your vice-roms_*version*-1_all.deb package in the current directory.

* Install* the rom package with dpkg, apt, etc. For example:

		sudo apt-get install /full-path-to-package/vice-roms_*.deb

	(*In the unlikely event that a new major version of VICE rolls out for your current Linux distribution, re-running the script and installing the package will properly update the old ROM set.)

## Docker build

The Docker container runs the deb build script in a minimal Debian / Ubuntu / *insert your favourite Debian derivative system here* environment.


* Clone this repository
* Open a terminal, cd to the clone directory
* Edit the *Parent Image* name field in the [Dockerfile](Dockerfile), to reflect your target Linux distribution. The most common choices will be obvious here. For less common Linux distribution image names, please refer to [Docker Hub](https://hub.docker.com)'s Docker image search. For [Linux Mint](https://linuxmint.com/) et. al., you should opt for your distribution's parent [Ubuntu](https://ubuntu.com/) or [Debian](https://www.debian.org/) image distribution. Save the updated Dockerfile.

		#FROM ubuntu:18.04
		#FROM ubuntu:20.04
		FROM debian:11

* Build the Docker image. This will induce some 100Ms of downloads.

		docker build -t debbuild .

* Run the package build container.

		docker container run -e USER=$(id -u) -e GROUP=$(id -g) -v $(pwd):/build -it --rm debbuild

* Find your vice-roms_*version*-1_all.deb package in the current directory.
* Install the package as above (probably on some remote system).
* Clean up the (no longer needed) docker images

		docker image rm debbuild
		docker image prune

## Notes

* The build script extracts current (either installed, or, available) VICE emulator version level from deb package management.
* ROM files will be downloaded directly from VICE's [code repository](https://sourceforge.net/projects/vice-emu/files/) for package creation according to the collected [version tag](https://sourceforge.net/p/vice-emu/code/HEAD/tree/tags/).
* You can override the version detection logic by supplying the required level explicitly (either to the makedeb.sh script, or, the build container) as parameter. For example,

		./makedeb.sh 3.5

	will build VICE ROMs from/for version 3.5(.0) . (Package maintainer's sub-versions don't count. Please refer to the available VICE release tags for clues.)

* VICE prior to v3.5 expected ROM files under /usr/lib/vice. VICE 3.5 and above expects ROMs under /usr/share/vice. This package installs files to /usr/share/vice, but retains compatibility by symlinking to /usr/lib/vice.
* The included

		debian/changelog
		debian/control

	files contain fake package maintainer data.

* You should likely not distribute the generated ROM packages. Disclaimer: in any case, I'm not responsible for implied copyright infringements.

## License

Files in this package are distributed under the Zlib license (see: [LICENSE](LICENSE)), (C) 2022 Levente Hársfalvi
