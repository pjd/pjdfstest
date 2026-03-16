#! /bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD$

desc="utimensat is y2038 compliant"

dir=`dirname $0`
. ${dir}/../misc.sh

require "utimensat"

echo "1..7"

require utimensat

n0=`namegen`
n1=`namegen`
DATE1=2147483648	# 2^31, ie Mon Jan 18 20:14:08 MST 2038
DATE2=4294967296	# 2^32, ie Sat Feb  6 23:28:16 MST 2106

expect 0 mkdir ${n1} 0755
cdir=`pwd`
cd ${n1}

# Some file systems express st_* fields with 32-bit quantities.
#
# Linux:
# - XFS with `bigtime=0`
# - ext* with 128-bit inodes (`EXT2_GOOD_OLD_INODE_SIZE`, etc).
INT32_MAX="2147483647"  # => (2 ^ 32) - 1.
probe_file="probe_$$"
${fstest} create ${probe_file} 0644 >/dev/null 2>&1
${fstest} open . O_RDONLY : utimensat 0 ${probe_file} $DATE1 0 $DATE2 0 0 >/dev/null 2>&1
probe_atime=$(${fstest} lstat ${probe_file} atime 2>/dev/null)
${fstest} unlink ${probe_file} >/dev/null 2>&1

if [ "$probe_atime" = "$DATE1" ]; then
	THIRTY_TWO_BIT_FS_TIME_T=false
elif [ "$probe_atime" != "${INT32_MAX}" ]; then
	echo "Could not determine if file system has 32-bit or 64-bit st_* fields (probe_atime='$probe_atime'; DATE1='$DATE1')"
	echo 'Bail out!'
	exit 1
else
	THIRTY_TWO_BIT_FS_TIME_T=true
fi

create_file regular ${n0}
expect 0 open . O_RDONLY : utimensat 0 ${n0} $DATE1 0 $DATE2 0 0

if ${THIRTY_TWO_BIT_FS_TIME_T}; then
	todo Linux "Filesystem uses 32-bit time_t st* fields"
fi
expect $DATE1 lstat ${n0} atime

if ${THIRTY_TWO_BIT_FS_TIME_T}; then
	todo Linux "Filesystem uses 32-bit time_t st* fields"
fi
expect $DATE2 lstat ${n0} mtime

expect 0 unlink ${n0}

cd ${cdir}
expect 0 rmdir ${n1}
