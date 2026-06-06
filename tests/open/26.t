#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="open can create files with 0000 mode"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..9"

n0=`namegen`

# POSIX: The file is created with the specified mode.
# We test O_WRONLY, O_RDWR, and O_RDONLY to ensure all combinations
# work correctly even when the file permissions are 0000.
# This is used e.g. by FreeBSD mv -f and previously failed on p9fs.

expect 0 open ${n0} O_CREAT,O_WRONLY 0000
expect regular,00 lstat ${n0} type,mode
expect 0 unlink ${n0}

expect 0 open ${n0} O_CREAT,O_RDWR 0000
expect regular,00 lstat ${n0} type,mode
expect 0 unlink ${n0}

expect 0 open ${n0} O_CREAT,O_RDONLY 0000
expect regular,00 lstat ${n0} type,mode
expect 0 unlink ${n0}
