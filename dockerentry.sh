#!/bin/bash
set -o errexit

groupadd -g $GROUP build

case "$1" in
    sh)
	useradd -m -g build -G sudo -s /bin/bash -u $USER build
	echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/sudo
	cd /build
	su build
    ;;
    *)
	useradd -m -g build -s /bin/bash -u $USER build
	cd /build
	sudo -u build ./makedeb.sh "$@"
    ;;
esac

