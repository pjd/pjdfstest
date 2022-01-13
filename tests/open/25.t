#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="interact with > 2 GB files"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..6"

n0=`namegen`
n1=`namegen`

expect 0 mkdir ${n1} 0755
cdir=`pwd`
cd ${n1}

expect 0 open ${n0} O_CREAT,O_WRONLY 0755 : pwrite 0 "a" $((2 * 1024 * 1024 * 1024 + 1))
expect $((2 * 1024 * 1024 * 1024 + 2)) lstat ${n0} size
expect "a" open ${n0} O_RDONLY : pread 0 1 $((2 * 1024 * 1024 * 1024 + 1))
expect 0 unlink ${n0}

cd ${cdir}
expect 0 rmdir ${n1}
