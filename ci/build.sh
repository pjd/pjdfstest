#!/bin/sh

set -ex

PJDFSTEST_DIR="$(realpath "${0%/*}/..")"

cd "$PJDFSTEST_DIR"
autoreconf -ifs
./configure
make
