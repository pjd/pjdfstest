#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="rename of a directory updates its .. link"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..13"

src_parent=`namegen`
dst_parent=`namegen`
src=`namegen`
dst=`namegen`

expect 0 mkdir ${src_parent} 0755
expect 0 mkdir ${dst_parent} 0755
expect 0 mkdir ${src_parent}/${src} 0755
cdir=`pwd`

# Initial conditions
expect 3 lstat ${src_parent} nlink
expect 2 lstat ${dst_parent} nlink
dotdot_inode=`${fstest} lstat ${src_parent} inode`
expect ${dotdot_inode} lstat ${src_parent}/${src}/.. inode

expect 0 rename ${src_parent}/${src} ${dst_parent}/${dst}

# The .. link and parents' nlinks values should be updated
expect 2 lstat ${src_parent} nlink
expect 3 lstat ${dst_parent} nlink
dotdot_inode=`${fstest} lstat ${dst_parent} inode`
expect ${dotdot_inode} lstat ${dst_parent}/${dst}/.. inode

cd ${cdir}
expect 0 rmdir ${dst_parent}/${dst}
expect 0 rmdir ${dst_parent}
expect 0 rmdir ${src_parent}
