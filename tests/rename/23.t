#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD$

desc="rename succeeds when to is multiply linked"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..42"

src=`namegen`
dst=`namegen`
dstlnk=`namegen`
parent=`namegen`

expect 0 mkdir ${parent} 0755
cdir=`pwd`
cd ${parent}

for type in regular fifo block char socket; do
	push_requirement ftype_${type}

	create_file ${type} ${src}
	create_file ${type} ${dst}
	expect 0 link ${dst} ${dstlnk}
	ctime1=`query lstat ${dstlnk} ctime`
	nap

	expect 0 rename ${src} ${dst}

	# destination inode should have reduced nlink and updated ctime
	expect ${type},1 lstat ${dstlnk} type,nlink
	ctime2=`query lstat ${dstlnk} ctime`
	test_check $ctime1 -lt $ctime2

	expect 0 unlink ${dst}
	expect 0 unlink ${dstlnk}

	pop_requirement
done

cd ${cdir}
expect 0 rmdir ${parent}
