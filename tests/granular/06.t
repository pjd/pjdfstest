#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD:$

desc="NFSv4 granular permissions checking - setuid and setgid are cleared when non-owner calls chown"

dir=`dirname $0`
. ${dir}/../misc.sh

nfsv4acls || quick_exit
# ZFS's default aclmode is discard, which prevents non-owners from chowning a
# file
if [ "${fs}" != "ZFS" -o \
	$(zfs get -Hp aclmode $(get_mountpoint) | cut -wf3) != passthrough ]
then
	quick_exit
fi

echo "1..32"

n0=`namegen`
n2=`namegen`

expect 0 mkdir ${n2} 0755
cdir=`pwd`
cd ${n2}

# When non-owner calls chown(2) successfully, set-uid and set-gid bits are
# removed, except when both uid and gid are equal to -1.
expect 0 create ${n0} 0644
expect 0 prependacl ${n0} user:65534:write_owner::allow
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} 65534 65532
expect 0555,65534,65532 lstat ${n0} mode,uid,gid
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} -1 65533
expect 0555,65534,65533 lstat ${n0} mode,uid,gid
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} -1 -1
expect 06555,65534,65533 lstat ${n0} mode,uid,gid
expect 0 unlink ${n0}

expect 0 mkdir ${n0} 0755
expect 0 prependacl ${n0} user:65534:write_owner::allow
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} 65534 65532
expect 0555,65534,65532 lstat ${n0} mode,uid,gid
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} -1 65533
expect 0555,65534,65533 lstat ${n0} mode,uid,gid
expect 0 chmod ${n0} 06555
expect 06555 lstat ${n0} mode
expect 0 -u 65534 -g 65533,65532 chown ${n0} -1 -1
expect 06555,65534,65533 lstat ${n0} mode,uid,gid
expect 0 rmdir ${n0}

cd ${cdir}
expect 0 rmdir ${n2}
