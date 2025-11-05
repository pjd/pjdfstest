#!/bin/sh

set -e

if [ "$#" -lt 1 ]; then
	echo "usage: ${0##*/} pkg_0 [... pkg_n]"
	exit 1
fi
packages=$*

start_time=$(date +%s)
# shellcheck disable=SC2086
pkg install -y $packages && exit 0

cat <<EOF
pkg install failed after $(($(date +%s) - start_time))s

dmesg tail:
$(dmesg | tail)

trying again
EOF

start_time=$(date +%s)
# shellcheck disable=SC2086
pkg install -y $packages && exit 0

cat <<EOF
second pkg install failed after $(($(date +%s) - start_time))s
EOF
exit 1
