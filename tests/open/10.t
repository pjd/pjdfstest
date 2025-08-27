#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/open/10.t 211352 2010-08-15 21:24:17Z pjd $

desc="open returns EPERM when the named file has its immutable flag set and the file is to be modified"

dir=`dirname $0`
. ${dir}/../misc.sh

require chflags

echo "1..28"

n0=`namegen`

expect 0 create ${n0} 0644
expect 0 chflags ${n0} SF_IMMUTABLE
expect EPERM open ${n0} O_WRONLY
expect EPERM open ${n0} O_RDWR
expect EPERM open ${n0} O_RDONLY,O_TRUNC
expect 0 chflags ${n0} none
expect 0 unlink ${n0}

expect 0 create ${n0} 0644
expect 0 chflags ${n0} SF_NOUNLINK
expect 0 open ${n0} O_WRONLY
expect 0 open ${n0} O_RDWR
expect 0 open ${n0} O_RDONLY,O_TRUNC
expect 0 chflags ${n0} none
expect 0 unlink ${n0}

push_requirement chflags_UF_IMMUTABLE
	expect 0 create ${n0} 0644
	expect 0 chflags ${n0} UF_IMMUTABLE
	expect EPERM open ${n0} O_WRONLY
	expect EPERM open ${n0} O_RDWR
	expect EPERM open ${n0} O_RDONLY,O_TRUNC
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}
pop_requirement

push_requirement chflags_UF_NOUNLINK
	expect 0 create ${n0} 0644
	expect 0 chflags ${n0} UF_NOUNLINK
	expect 0 open ${n0} O_WRONLY
	expect 0 open ${n0} O_RDWR
	expect 0 open ${n0} O_RDONLY,O_TRUNC
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}
pop_requirement
