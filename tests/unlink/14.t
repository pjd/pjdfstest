#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD$

desc="An open file will not be immediately freed by unlink"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..7"

n0=`namegen`
n2=`namegen`

expect 0 mkdir ${n2} 0755
cdir=`pwd`
cd ${n2}

# Stating open but deleted files should work
expect 0 create ${n0} 0644
expect 0 open ${n0} O_WRONLY : write 0 "Hello, World!"
# A deleted file's link count should be 0
expect 0 open ${n0} O_RDONLY : unlink ${n0} : fstat 0 nlink

# I/O to open but deleted files should work, too
expect 0 create ${n0} 0644
expect "Hello,_World!" open ${n0} O_RDWR : \
	write 0 "Hello,_World!" : \
	unlink ${n0} : \
	pread 0 13 0

cd ${cdir}
expect 0 rmdir ${n2}
