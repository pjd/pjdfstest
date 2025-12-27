#!/bin/sh

set -eux

PJDFSTEST_DIR="$(realpath "${0%/*}/..")"

df .
uname -a

case "$(uname)" in
Darwin)
	sw_vers -productVersion
	mount
	# FIXME: macOS has test issues that need to be addressed per Issue #13.
	exit 0
	;;
FreeBSD)
	mount -p
	;;
Linux)
	for release_file in /etc/lsb-release /etc/os-release; do
		echo "$release_file.. ->"
		cat "$release_file"
	done
	mount
	;;
esac

prove -rv "${PJDFSTEST_DIR}/tests"
