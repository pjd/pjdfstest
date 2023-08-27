#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/symlink/09.t 211352 2010-08-15 21:24:17Z pjd $

desc="symlink returns EPERM if the parent directory of the file named by name2 has its immutable flag set"

dir=`dirname $0`
. ${dir}/../misc.sh

require chflags
require ftype_symlink

echo "1..30"

n0=`namegen`
n1=`namegen`

expect 0 mkdir ${n0} 0755

expect 0 symlink test ${n0}/${n1}
expect 0 unlink ${n0}/${n1}

expect 0 chflags ${n0} SF_IMMUTABLE
expect EPERM symlink test ${n0}/${n1}
expect 0 chflags ${n0} none
expect 0 symlink test ${n0}/${n1}
expect 0 unlink ${n0}/${n1}

expect 0 chflags ${n0} SF_NOUNLINK
expect 0 symlink test ${n0}/${n1}
expect 0 chflags ${n0} none
expect 0 unlink ${n0}/${n1}

expect 0 chflags ${n0} SF_APPEND
expect 0 symlink test ${n0}/${n1}
expect 0 chflags ${n0} none
expect 0 unlink ${n0}/${n1}

push_requirement chflags_UF_IMMUTABLE
	expect 0 chflags ${n0} UF_IMMUTABLE
	expect EPERM symlink test ${n0}/${n1}
	expect 0 chflags ${n0} none
	expect 0 symlink test ${n0}/${n1}
	expect 0 unlink ${n0}/${n1}
pop_requirement

push_requirement chflags_UF_NOUNLINK
	expect 0 chflags ${n0} UF_NOUNLINK
	expect 0 symlink test ${n0}/${n1}
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}/${n1}
pop_requirement

push_requirement chflags_UF_APPEND
	expect 0 chflags ${n0} UF_APPEND
	expect 0 symlink test ${n0}/${n1}
	expect 0 chflags ${n0} none
	expect 0 unlink ${n0}/${n1}
pop_requirement

expect 0 rmdir ${n0}
