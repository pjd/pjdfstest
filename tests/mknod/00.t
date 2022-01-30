#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/mknod/00.t 211352 2010-08-15 21:24:17Z pjd $

desc="mknod creates fifo files"

dir=`dirname $0`
. ${dir}/../misc.sh

require ftype_fifo
require mknod

echo "1..35"

n0=`namegen`
n1=`namegen`

expect 0 mkdir ${n1} 0755
cdir=`pwd`
cd ${n1}

# POSIX: The file permission bits of the new FIFO shall be initialized from
# mode. The file permission bits of the mode argument shall be modified by the
# process' file creation mask.
expect 0 mknod ${n0} f 0755 0 0
expect fifo,0755 lstat ${n0} type,mode
expect 0 unlink ${n0}
expect 0 mknod ${n0} f 0151 0 0
expect fifo,0151 lstat ${n0} type,mode
expect 0 unlink ${n0}
expect 0 -U 077 mknod ${n0} f 0151 0 0
expect fifo,0100 lstat ${n0} type,mode
expect 0 unlink ${n0}
expect 0 -U 070 mknod ${n0} f 0345 0 0
expect fifo,0305 lstat ${n0} type,mode
expect 0 unlink ${n0}
expect 0 -U 0501 mknod ${n0} f 0345 0 0
expect fifo,0244 lstat ${n0} type,mode
expect 0 unlink ${n0}

# POSIX: Upon successful completion, mknod() shall mark for update the
# st_atime, st_ctime, and st_mtime fields of the file. Also, the st_ctime and
# st_mtime fields of the directory that contains the new entry shall be marked
# for update.
time=`query stat . ctime`
nap
expect 0 mknod ${n0} f 0755 0 0
atime=`query stat ${n0} atime`
test_check $time -lt $atime
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
mtime=`query stat . mtime`
test_check $time -lt $mtime
ctime=`query stat . ctime`
test_check $time -lt $ctime
expect 0 unlink ${n0}

# POSIX: The FIFO's user ID shall be set to the process' effective user ID.
# The FIFO's group ID shall be set to the group ID of the parent directory or to
# the effective group ID of the process.
expect 0 chown . 65535 65535
expect 0 -u 65535 -g 65535 mknod ${n0} f 0755 0 0
expect 65535,65535 lstat ${n0} uid,gid
expect 0 unlink ${n0}
expect 0 -u 65535 -g 65534 mknod ${n0} f 0755 0 0
expect "65535,6553[45]" lstat ${n0} uid,gid
expect 0 unlink ${n0}
expect 0 chmod . 0777
expect 0 -u 65534 -g 65533 mknod ${n0} f 0755 0 0
expect "65534,6553[35]" lstat ${n0} uid,gid
expect 0 unlink ${n0}

cd ${cdir}
expect 0 rmdir ${n1}
