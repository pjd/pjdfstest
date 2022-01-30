#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/unlink/00.t 211352 2010-08-15 21:24:17Z pjd $

desc="unlink removes regular files, symbolic links, fifos and sockets"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..112"

n0=`namegen`
n1=`namegen`
n2=`namegen`

expect 0 mkdir ${n2} 0755
cdir=`pwd`
cd ${n2}

expect 0 create ${n0} 0644
expect regular lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type

push_requirement ftype_symlink
expect 0 symlink ${n1} ${n0}
expect symlink lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type
pop_requirement

push_requirement ftype_fifo
expect 0 mkfifo ${n0} 0644
expect fifo lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type
pop_requirement

push_requirement ftype_block
expect 0 mknod ${n0} b 0644 1 2
expect block lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type
pop_requirement

push_requirement ftype_char
expect 0 mknod ${n0} c 0644 1 2
expect char lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type
pop_requirement

push_requirement ftype_socket
expect 0 bind ${n0}
expect socket lstat ${n0} type
expect 0 unlink ${n0}
expect ENOENT lstat ${n0} type
pop_requirement

# successful unlink(2) updates ctime.
expect 0 create ${n0} 0644
expect 0 link ${n0} ${n1}
ctime1=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -lt $ctime2
expect 0 unlink ${n0}

push_requirement ftype_fifo
expect 0 mkfifo ${n0} 0644
expect 0 link ${n0} ${n1}
ctime1=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -lt $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_block
expect 0 mknod ${n0} b 0644 1 2
expect 0 link ${n0} ${n1}
ctime1=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -lt $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_char
expect 0 mknod ${n0} c 0644 1 2
expect 0 link ${n0} ${n1}
ctime1=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -lt $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_socket
expect 0 bind ${n0}
expect 0 link ${n0} ${n1}
ctime1=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -lt $ctime2
expect 0 unlink ${n0}
pop_requirement

# unsuccessful unlink(2) does not update ctime.
push_requirement root
expect 0 create ${n0} 0644
ctime1=`query stat ${n0} ctime`
nap
expect EACCES -u 65534 unlink ${n0}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -eq $ctime2
expect 0 unlink ${n0}

push_requirement ftype_fifo
expect 0 mkfifo ${n0} 0644
ctime1=`query stat ${n0} ctime`
nap
expect EACCES -u 65534 unlink ${n0}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -eq $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_block
expect 0 mknod ${n0} b 0644 1 2
ctime1=`query stat ${n0} ctime`
nap
expect EACCES -u 65534 unlink ${n0}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -eq $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_char
expect 0 mknod ${n0} c 0644 1 2
ctime1=`query stat ${n0} ctime`
nap
expect EACCES -u 65534 unlink ${n0}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -eq $ctime2
expect 0 unlink ${n0}
pop_requirement

push_requirement ftype_socket
expect 0 bind ${n0}
ctime1=`query stat ${n0} ctime`
nap
expect EACCES -u 65534 unlink ${n0}
ctime2=`query stat ${n0} ctime`
test_check $ctime1 -eq $ctime2
expect 0 unlink ${n0}
pop_requirement
pop_requirement

expect 0 mkdir ${n0} 0755
expect 0 create ${n0}/${n1} 0644
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}

push_requirement ftype_fifo
expect 0 mkdir ${n0} 0755
expect 0 mkfifo ${n0}/${n1} 0644
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}
pop_requirement

push_requirement ftype_block
expect 0 mkdir ${n0} 0755
expect 0 mknod ${n0}/${n1} b 0644 1 2
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}
pop_requirement

push_requirement ftype_char
expect 0 mkdir ${n0} 0755
expect 0 mknod ${n0}/${n1} c 0644 1 2
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}
pop_requirement

push_requirement ftype_socket
expect 0 mkdir ${n0} 0755
expect 0 bind ${n0}/${n1}
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}
pop_requirement

push_requirement ftype_symlink
expect 0 mkdir ${n0} 0755
expect 0 symlink test ${n0}/${n1}
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n0}/${n1}
mtime=`query stat ${n0} mtime`
test_check $time -lt $mtime
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 rmdir ${n0}
pop_requirement

expect 0 create ${n0} 0644
expect 0 link ${n0} ${n1}
time=`query stat ${n0} ctime`
nap
expect 0 unlink ${n1}
ctime=`query stat ${n0} ctime`
test_check $time -lt $ctime
expect 0 unlink ${n0}

cd ${cdir}
expect 0 rmdir ${n2}
