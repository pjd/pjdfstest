#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="mkfifo returns EFAULT if the path argument points outside the process's allocated address space"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..2"

expect EFAULT mkfifo NULL 0644
expect EFAULT mkfifo DEADCODE 0644
