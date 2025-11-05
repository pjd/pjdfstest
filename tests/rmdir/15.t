#!/bin/sh
# vim: filetype=sh noexpandtab ts=8 sw=8

desc="rmdir returns EFAULT if the path argument points outside the process's allocated address space"

dir=`dirname $0`
. ${dir}/../misc.sh

echo "1..2"

expect EFAULT rmdir NULL
expect EFAULT rmdir DEADCODE
