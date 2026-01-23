#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="symlink returns ENAMETOOLONG if an entire length of either path name exceeded {PATH_MAX} characters"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..6"

n0=`namegen`
nx=`dirgen_max`
nxx="${nx}x"

mkdir -p "${nx%/*}"

# On XFS, symlink targets are limited to 1024 bytes (vs PATH_MAX 4096).
case "$fs" in
	xfs|XFS)
	todo Linux "XFS symlink target limit (1024) is smaller than PATH_MAX"
	;;
esac
expect 0 symlink ${nx} ${n0}

# Cleanup (unlink) will fail with ENOENT if the creation step above failed.
case "$fs" in
	xfs|XFS)
	todo Linux "Cleanup fails because symlink creation failed on XFS"
	;;
esac
expect 0 unlink ${n0}

expect 0 symlink ${n0} ${nx}
expect 0 unlink ${nx}
expect ENAMETOOLONG symlink ${n0} ${nxx}
expect ENAMETOOLONG symlink ${nxx} ${n0}
rm -rf "${nx%%/*}"
