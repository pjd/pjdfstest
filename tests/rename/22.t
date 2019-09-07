#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD$

desc="rename changes file ctime"

dir=`dirname $0`
. ${dir}/../misc.sh

require rename_ctime

echo "1..30"

src=`namegen`
dst=`namegen`
parent=`namegen`

expect 0 mkdir ${parent} 0755
cdir=`pwd`
cd ${parent}

# successful rename(2) updates ctime.
for type in regular dir fifo block char socket symlink; do
	create_file ${type} ${src}
	ctime1=`${fstest} lstat ${src} ctime`
	sleep 1
	expect 0 rename ${src} ${dst}
	ctime2=`${fstest} lstat ${dst} ctime`
	test_check $ctime1 -lt $ctime2
	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${dst}
	else
		expect 0 unlink ${dst}
	fi
done

cd ${cdir}
expect 0 rmdir ${parent}
