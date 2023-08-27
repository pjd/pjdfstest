#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/mknod/08.t 211474 2010-08-18 22:06:43Z pjd $

desc="mknod returns EEXIST if the named file exists"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..35"

n0=`namegen`

for type in regular dir fifo block char socket symlink; do
	push_requirement ftype_${type}

	create_file ${type} ${n0}

	push_requirement ftype_block
	expect EEXIST mknod ${n0} b 0644 0 0
	pop_requirement

	push_requirement ftype_char
	expect EEXIST mknod ${n0} c 0644 0 0
	pop_requirement

	push_requirement ftype_fifo
	expect EEXIST mknod ${n0} f 0644 0 0
	pop_requirement

	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi

	pop_requirement
done
