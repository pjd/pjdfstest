#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8
# $FreeBSD: head/tools/regression/pjdfstest/tests/chown/00.t 228975 2011-12-30 00:04:11Z uqs $

desc="chown changes ownership"

dir=`dirname $0`
. ${dir}/../misc.sh

if supported lchmod; then
	echo "1..1306"
else
	echo "1..1280"
fi

n0=`namegen`
n1=`namegen`
n2=`namegen`

expect 0 mkdir ${n2} 0755
cdir=`pwd`
cd ${n2}

# super-user can always modify ownership
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		expect 0 chown ${n0} 123 456
		expect 123,456 lstat ${n0} uid,gid
		expect 0 chown ${n0} 0 0
		expect 0,0 lstat ${n0} uid,gid

		expect 0 symlink ${n0} ${n1}
		uidgid=`${fstest} lstat ${n1} uid,gid`
		expect 0 chown ${n1} 123 456
		expect 123,456 stat ${n1} uid,gid
		expect 123,456 stat ${n0} uid,gid
		expect ${uidgid} lstat ${n1} uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	create_file ${type} ${n0}
	expect 0 lchown ${n0} 123 456
	expect 123,456 lstat ${n0} uid,gid
	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

# non-super-user can modify file group if he is owner of a file and
# gid he is setting is in his groups list.
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		expect 0 chown ${n0} 65534 65533
		expect 65534,65533 lstat ${n0} uid,gid
		expect 0 -u 65534 -g 65532,65531 -- chown ${n0} -1 65532
		expect 65534,65532 lstat ${n0} uid,gid
		expect 0 -u 65534 -g 65532,65531 chown ${n0} 65534 65531
		expect 65534,65531 lstat ${n0} uid,gid

		expect 0 symlink ${n0} ${n1}
		uidgid=`${fstest} lstat ${n1} uid,gid`
		expect 0 chown ${n1} 65534 65533
		expect 65534,65533 stat ${n0} uid,gid
		expect 65534,65533 stat ${n1} uid,gid
		expect ${uidgid} lstat ${n1} uid,gid
		expect 0 -u 65534 -g 65532,65531 -- chown ${n1} -1 65532
		expect 65534,65532 stat ${n0} uid,gid
		expect 65534,65532 stat ${n1} uid,gid
		expect ${uidgid} lstat ${n1} uid,gid
		expect 0 -u 65534 -g 65532,65531 chown ${n1} 65534 65531
		expect 65534,65531 stat ${n0} uid,gid
		expect 65534,65531 stat ${n1} uid,gid
		expect ${uidgid} lstat ${n1} uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	create_file ${type} ${n0}
	expect 0 lchown ${n0} 65534 65533
	expect 65534,65533 lstat ${n0} uid,gid
	expect 0 -u 65534 -g 65532,65531 -- lchown ${n0} -1 65532
	expect 65534,65532 lstat ${n0} uid,gid
	expect 0 -u 65534 -g 65532,65531 lchown ${n0} 65534 65531
	expect 65534,65531 lstat ${n0} uid,gid
	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

# chown(2) should succeed even if the user is not the owner of a file, as long
# as both uid and gid are -1.
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		# chown directly on the file
		expect 0 -u 65534 -g 65534 -- chown ${n0} -1 -1
		expect 0,0 stat ${n0} uid,gid

		# chown through a symlink
		expect 0 symlink ${n0} ${n1}
		expect 0 -u 65534 -g 65534 -- chown ${n1} -1 -1
		expect 0,0 stat ${n0} uid,gid
		expect 0,0 lstat ${n1} uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	# lchown directly on a file or symlink
	create_file ${type} ${n0}
	expect 0 -u 65534 -g 65534 -- lchown ${n0} -1 -1
	expect 0,0 lstat ${n0} uid,gid
	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

# when super-user calls chown(2), set-uid and set-gid bits may be removed.
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		expect 0 chown ${n0} 65534 65533
		expect 0 chmod ${n0} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 0 chown ${n0} 65532 65531
		expect "(06555|0555),65532,65531" stat ${n0} mode,uid,gid
		expect 0 chmod ${n0} 06555
		expect 06555,65532,65531 stat ${n0} mode,uid,gid
		expect 0 chown ${n0} 0 0
		expect "(06555|0555),0,0" stat ${n0} mode,uid,gid

		expect 0 symlink ${n0} ${n1}
		expect 0 chown ${n1} 65534 65533
		expect 0 chmod ${n1} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 06555,65534,65533 stat ${n1} mode,uid,gid
		expect 0 chown ${n1} 65532 65531
		expect "(06555|0555),65532,65531" stat ${n0} mode,uid,gid
		expect "(06555|0555),65532,65531" stat ${n1} mode,uid,gid
		expect 0 chmod ${n1} 06555
		expect 06555,65532,65531 stat ${n0} mode,uid,gid
		expect 06555,65532,65531 stat ${n1} mode,uid,gid
		expect 0 chown ${n1} 0 0
		expect "(06555|0555),0,0" stat ${n0} mode,uid,gid
		expect "(06555|0555),0,0" stat ${n1} mode,uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	if [ "${type}" != "symlink" ] || supported lchmod; then
		create_file ${type} ${n0}
		expect 0 lchown ${n0} 65534 65533
		if supported lchmod; then
			expect 0 lchmod ${n0} 06555
		else
			expect 0 chmod ${n0} 06555
		fi
		expect 06555,65534,65533 lstat ${n0} mode,uid,gid
		expect 0 lchown ${n0} 65532 65531
		expect "(06555|0555),65532,65531" lstat ${n0} mode,uid,gid
		if supported lchmod; then
			expect 0 lchmod ${n0} 06555
		else
			expect 0 chmod ${n0} 06555
		fi
		expect 06555,65532,65531 lstat ${n0} mode,uid,gid
		expect 0 lchown ${n0} 0 0
		expect "(06555|0555),0,0" lstat ${n0} mode,uid,gid
		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi
done

# when non-super-user calls chown(2) successfully, set-uid and set-gid bits may
# be removed, except when both uid and gid are equal to -1.
for type in regular dir fifo block char socket symlink; do
	#
	# Linux makes a destinction for behavior when an executable file vs a
	# non-executable file. From chmod(2):
	#
	#   When the owner or group of an executable file are changed by an
	#   unprivileged user the S_ISUID and S_ISGID mode bits are cleared.
	#
	# I believe in this particular case, the behavior's bugged.
	#
	if [ "${type}" = "dir" -a "${os}" = "Linux" ]; then
		_todo_msg="Linux doesn't clear the SGID/SUID bits for directories, despite the description noted"
	else
		_todo_msg=
	fi
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		expect 0 chown ${n0} 65534 65533
		expect 0 chmod ${n0} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 chown ${n0} 65534 65532
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65532 stat ${n0} mode,uid,gid
		expect 0 chmod ${n0} 06555
		expect 06555,65534,65532 stat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- chown ${n0} -1 65533
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65533 stat ${n0} mode,uid,gid
		expect 0 chmod ${n0} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- chown ${n0} -1 -1
		expect "(06555|0555),65534,65533" stat ${n0} mode,uid,gid

		expect 0 symlink ${n0} ${n1}
		expect 0 chown ${n1} 65534 65533
		expect 0 chmod ${n1} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 06555,65534,65533 stat ${n1} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 chown ${n1} 65534 65532
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65532 stat ${n0} mode,uid,gid
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65532 stat ${n1} mode,uid,gid
		expect 0 chmod ${n1} 06555
		expect 06555,65534,65532 stat ${n0} mode,uid,gid
		expect 06555,65534,65532 stat ${n1} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- chown ${n1} -1 65533
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65533 stat ${n0} mode,uid,gid
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65533 stat ${n1} mode,uid,gid
		expect 0 chmod ${n1} 06555
		expect 06555,65534,65533 stat ${n0} mode,uid,gid
		expect 06555,65534,65533 stat ${n1} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- chown ${n1} -1 -1
		expect "(06555|0555),65534,65533" stat ${n0} mode,uid,gid
		expect "(06555|0555),65534,65533" stat ${n1} mode,uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	if [ "${type}" != "symlink" ] || supported lchmod; then
		create_file ${type} ${n0}

		expect 0 lchown ${n0} 65534 65533
		if supported lchmod; then
			expect 0 lchmod ${n0} 06555
		else
			expect 0 chmod ${n0} 06555
		fi
		expect 06555,65534,65533 lstat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 lchown ${n0} 65534 65532
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65532 lstat ${n0} mode,uid,gid
		if supported lchmod; then
			expect 0 lchmod ${n0} 06555
		else
			expect 0 chmod ${n0} 06555
		fi
		expect 06555,65534,65532 lstat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- lchown ${n0} -1 65533
		[ -n "${_todo_msg}" ] && todo "Linux" "${_todo_msg}"
		expect 0555,65534,65533 lstat ${n0} mode,uid,gid
		if supported lchmod; then
			expect 0 lchmod ${n0} 06555
		else
			expect 0 chmod ${n0} 06555
		fi
		expect 06555,65534,65533 lstat ${n0} mode,uid,gid
		expect 0 -u 65534 -g 65533,65532 -- lchown ${n0} -1 -1
		expect "(06555|0555),65534,65533" lstat ${n0} mode,uid,gid

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi
done

# successful chown(2) call (except uid and gid equal to -1) updates ctime.
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		ctime1=`${fstest} stat ${n0} ctime`
		sleep 1
		expect 0 chown ${n0} 65534 65533
		expect 65534,65533 stat ${n0} uid,gid
		ctime2=`${fstest} stat ${n0} ctime`
		test_check $ctime1 -lt $ctime2
		ctime1=`${fstest} stat ${n0} ctime`
		sleep 1
		expect 0 -u 65534 -g 65532 chown ${n0} 65534 65532
		expect 65534,65532 stat ${n0} uid,gid
		ctime2=`${fstest} stat ${n0} ctime`
		test_check $ctime1 -lt $ctime2

		expect 0 symlink ${n0} ${n1}
		ctime1=`${fstest} stat ${n1} ctime`
		sleep 1
		expect 0 chown ${n1} 65533 65532
		expect 65533,65532 stat ${n1} uid,gid
		ctime2=`${fstest} stat ${n1} ctime`
		test_check $ctime1 -lt $ctime2
		ctime1=`${fstest} stat ${n1} ctime`
		sleep 1
		expect 0 -u 65533 -g 65531 chown ${n1} 65533 65531
		expect 65533,65531 stat ${n1} uid,gid
		ctime2=`${fstest} stat ${n1} ctime`
		test_check $ctime1 -lt $ctime2
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	create_file ${type} ${n0}

	ctime1=`${fstest} lstat ${n0} ctime`
	sleep 1
	expect 0 lchown ${n0} 65534 65533
	expect 65534,65533 lstat ${n0} uid,gid
	ctime2=`${fstest} lstat ${n0} ctime`
	test_check $ctime1 -lt $ctime2
	ctime1=`${fstest} lstat ${n0} ctime`
	sleep 1
	expect 0 -u 65534 -g 65532 lchown ${n0} 65534 65532
	expect 65534,65532 lstat ${n0} uid,gid
	ctime2=`${fstest} lstat ${n0} ctime`
	test_check $ctime1 -lt $ctime2

	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		ctime1=`${fstest} stat ${n0} ctime`
		sleep 1
		expect 0 -- chown ${n0} -1 -1
		ctime2=`${fstest} stat ${n0} ctime`
		todo Linux "According to POSIX: If both owner and group are -1, the times need not be updated."
		test_check $ctime1 -eq $ctime2
		expect 0,0 stat ${n0} uid,gid

		expect 0 symlink ${n0} ${n1}
		ctime1=`${fstest} stat ${n1} ctime`
		sleep 1
		expect 0 -- chown ${n1} -1 -1
		ctime2=`${fstest} stat ${n1} ctime`
		todo Linux "According to POSIX: If both owner and group are -1, the times need not be updated."
		test_check $ctime1 -eq $ctime2
		expect 0,0 stat ${n1} uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	create_file ${type} ${n0}

	ctime1=`${fstest} lstat ${n0} ctime`
	sleep 1
	expect 0 -- lchown ${n0} -1 -1
	ctime2=`${fstest} lstat ${n0} ctime`
	todo Linux "According to POSIX: If both owner and group are -1, the times need not be updated."
	test_check $ctime1 -eq $ctime2
	expect 0,0 lstat ${n0} uid,gid

	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

# unsuccessful chown(2) does not update ctime.
for type in regular dir fifo block char socket symlink; do
	if [ "${type}" != "symlink" ]; then
		create_file ${type} ${n0}

		ctime1=`${fstest} stat ${n0} ctime`
		sleep 1
		expect EPERM -u 65534 -- chown ${n0} 65534 -1
		expect EPERM -u 65534 -g 65534 -- chown ${n0} -1 65534
		expect EPERM -u 65534 -g 65534 chown ${n0} 65534 65534
		ctime2=`${fstest} stat ${n0} ctime`
		test_check $ctime1 -eq $ctime2
		expect 0,0 stat ${n0} uid,gid

		expect 0 symlink ${n0} ${n1}
		ctime1=`${fstest} stat ${n1} ctime`
		sleep 1
		expect EPERM -u 65534 -- chown ${n1} 65534 -1
		expect EPERM -u 65534 -g 65534 -- chown ${n1} -1 65534
		expect EPERM -u 65534 -g 65534 chown ${n1} 65534 65534
		ctime2=`${fstest} stat ${n1} ctime`
		test_check $ctime1 -eq $ctime2
		expect 0,0 stat ${n1} uid,gid
		expect 0 unlink ${n1}

		if [ "${type}" = "dir" ]; then
			expect 0 rmdir ${n0}
		else
			expect 0 unlink ${n0}
		fi
	fi

	create_file ${type} ${n0}

	ctime1=`${fstest} lstat ${n0} ctime`
	sleep 1
	expect EPERM -u 65534 -- lchown ${n0} 65534 -1
	expect EPERM -u 65534 -g 65534 -- lchown ${n0} -1 65534
	expect EPERM -u 65534 -g 65534 lchown ${n0} 65534 65534
	ctime2=`${fstest} lstat ${n0} ctime`
	test_check $ctime1 -eq $ctime2
	expect 0,0 lstat ${n0} uid,gid

	if [ "${type}" = "dir" ]; then
		expect 0 rmdir ${n0}
	else
		expect 0 unlink ${n0}
	fi
done

cd ${cdir}
expect 0 rmdir ${n2}
