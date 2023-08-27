#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/chmod/04.t 211352 2010-08-15 21:24:17Z pjd $

desc="chmod returns ENOENT if the named file does not exist"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..9"

n0=`namegen`
n1=`namegen`
n2=`namegen`

expect 0 mkdir ${n0} 0755
expect ENOENT chmod ${n0}/${n1}/test 0644
expect ENOENT chmod ${n0}/${n1} 0644

push_requirement lchmod
expect ENOENT lchmod ${n0}/${n1}/test 0644
expect ENOENT lchmod ${n0}/${n1} 0644
pop_requirement

push_requirement ftype_symlink
expect 0 symlink ${n2} ${n0}/${n1}
expect ENOENT chmod ${n0}/${n1} 0644
expect 0 unlink ${n0}/${n1}
pop_requirement

expect 0 rmdir ${n0}
