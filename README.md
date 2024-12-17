# vice-roms-deb

## Overview

According to the [Debian](https://www.debian.org/) [VICE Emulator package](https://packages.debian.org/sid/vice)'s documentation, Commodore ROM files are owned by Tulip Computers NV. As a consequence, [VICE](https://sourceforge.net/projects/vice-emu/) itself is [DFSG compliant](https://wiki.debian.org/DebianFreeSoftwareGuidelines), but the corresponding Commodore ROM files are not. The README.ROMs file of the Debian VICE package suggests manually downloading and extracting the ROM sets, off, say, ftp.zimmers.net, which is inconvenient (...especially that VICE's ROM file hierarchy tends to be release specific).

The shell script included in this archive collects and packs the ROM image files together into a deb package, which can then be installed and managed by standard package management tools on Debian derivative operating systems. An additional Docker container builds this package under arbitrary (Docker capable) environments, so that target systems could be kept free from installing package authoring tools.

## Native build

* Install build prerequisities

		sudo apt-get install -y --no-install-recommends build-essential devscripts cdbs equivs fakeroot subversion

* Clone this repository
* `cd` to the source directory
* Run the build script.

		./makedeb.sh

* Find your `vice-roms_*version*-1_all.deb` package in the current build directory.

## Docker build

The Docker container runs the deb build script in a minimal Debian / Ubuntu / *insert your favourite Debian derivative system* environment.

* Clone this repository
* `cd` to the source directory
* Edit the *Parent Image* name field in the [Dockerfile](Dockerfile), to reflect your target Linux distribution. The most common choices will be obvious here (see below). For less common Linux distribution image names, please refer to [Docker Hub](https://hub.docker.com)'s Docker image search. For [Linux Mint](https://linuxmint.com/) et. al., you should opt for your distribution's parent [Ubuntu](https://ubuntu.com/) or [Debian](https://www.debian.org/) release image.

		FROM ubuntu:22.04
		#FROM debian:11

* Build the Docker image.

		docker build -t debbuild .

* Run the package build container.

		docker run -e USER=$(id -u) -e GROUP=$(id -g) -v $(pwd):/build -it --rm debbuild

* Find your `vice-roms_*version*-1_all.deb` package in the current directory.
* Clean up images (as needed)

		docker image rm debbuild
		docker image prune

## Install

Install* the rom package using regular package management tools, for example:

		sudo dpkg -i vice-roms_*.deb

(*If a new major release of VICE rolls out for your Linux distribution, simply repeat the process. The rest would just be taken care of apt and dpkg.)

## Uninstall

Use Debian package management tools.

		sudo apt remove vice-roms

## Notes

* The build script guesses the target version by looking up VICE emulator in the local deb package database.
* The script downloads ROM files from VICE's own [code repository](https://sourceforge.net/projects/vice-emu/files/), referenced by the constructed [version tag](https://sourceforge.net/p/vice-emu/code/HEAD/tree/tags/).
* The detection logic can be overridden by supplying the target version as parameter. For example,

		./makedeb.sh 3.5

    and

		docker run -e USER=$(id -u) -e GROUP=$(id -g) -v $(pwd):/build -it --rm debbuild 3.5

    both build VICE version 3.5(.0) ROM deb's. (Package maintainer versions are ignored, please refer to the list of [valid VICE release tags](https://sourceforge.net/p/vice-emu/code/HEAD/tree/tags/) for clues.)

* VICE Emulator has, prior to v3.5, expected ROM files to be present under `/usr/lib/vice`. VICE 3.5 and above would look for ROMs under `/usr/share/vice`. This package installs files to `/usr/share/vice`, and symlinks them back to `/usr/lib/vice`.
* Yes, this is a hack. No, neither I, nor this code, are affiliated with [The VICE Team](https://vice-emu.sourceforge.io) in any way. The mere reason this piece of code exists, is practical convenience.
* The included

		debian/changelog
		debian/control

    files contain fake package maintainer data.

* Generated packages are most likely not legally redistributable. You have been warned.

## License

Files in this package are distributed under the Zlib license (see: [LICENSE](LICENSE)), (C) 2022-2024 Levente Hársfalvi
