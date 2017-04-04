#!/bin/sh

set -ex

cd $(dirname $0)/..

df .
uname -a

case "$(uname)" in
Darwin)
	sw_vers -productVersion
	mount
	;;
FreeBSD)
	mount -p
	;;
Linux)
	for release_file in /etc/lsb-release /etc/os-release; do
		echo "$release_file.. ->"
		cat $release_file
	done
	mount
	;;
esac

sudo prove -rv .
