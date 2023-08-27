#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/link/13.t 211352 2010-08-15 21:24:17Z pjd $

desc="link returns EPERM if the parent directory of the destination file has its immutable flag set"

dir=`dirname $0`
. ${dir}/../misc.sh

require chflags
require link

echo "1..49"

n0=`namegen`
n1=`namegen`
n2=`namegen`

expect 0 mkdir ${n0} 0755

expect 0 create ${n0}/${n1} 0644
expect 1 stat ${n0}/${n1} nlink
expect 0 link ${n0}/${n1} ${n0}/${n2}
expect 2 stat ${n0}/${n1} nlink
expect 0 unlink ${n0}/${n2}
expect 1 stat ${n0}/${n1} nlink

expect 0 chflags ${n0} SF_IMMUTABLE
expect EPERM link ${n0}/${n1} ${n0}/${n2}
expect 1 stat ${n0}/${n1} nlink
expect 0 chflags ${n0} none
expect 0 link ${n0}/${n1} ${n0}/${n2}
expect 2 stat ${n0}/${n1} nlink
expect 0 unlink ${n0}/${n2}
expect 1 stat ${n0}/${n1} nlink

expect 0 chflags ${n0} SF_NOUNLINK
expect 0 link ${n0}/${n1} ${n0}/${n2}
expect 2 stat ${n0}/${n1} nlink
expect 0 chflags ${n0} none
expect 0 unlink ${n0}/${n2}
expect 1 stat ${n0}/${n1} nlink

expect 0 chflags ${n0} SF_APPEND
expect 0 link ${n0}/${n1} ${n0}/${n2}
expect 2 stat ${n0}/${n1} nlink
expect 0 chflags ${n0} none
expect 0 unlink ${n0}/${n2}
expect 1 stat ${n0}/${n1} nlink

push_requirement chflags_UF_IMMUTABLE
	expect 0 chflags ${n0} UF_IMMUTABLE
	expect EPERM link ${n0}/${n1} ${n0}/${n2}
	expect 1 stat ${n0}/${n1} nlink
	expect 0 chflags ${n0} none
	expect 0 link ${n0}/${n1} ${n0}/${n2}
	expect 2 stat ${n0}/${n1} nlink
	expect 0 unlink ${n0}/${n2}
	expect 1 stat ${n0}/${n1} nlink
pop_requirement

push_requirement chflags_UF_NOUNLINK
	expect 0 chflags ${n0} UF_NOUNLINK
	expect 0 link ${n0}/${n1} ${n0}/${n2}
	expect 2 stat ${n0}/${n1} nlink
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}/${n2}
	expect 1 stat ${n0}/${n1} nlink
pop_requirement

push_requirement chflags_UF_APPEND
	expect 0 chflags ${n0} UF_APPEND
	expect 0 link ${n0}/${n1} ${n0}/${n2}
	expect 2 stat ${n0}/${n1} nlink
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}/${n2}
	expect 1 stat ${n0}/${n1} nlink
pop_requirement

expect 0 unlink ${n0}/${n1}
expect 0 rmdir ${n0}
