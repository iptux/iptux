#!/bin/bash
#
# services.sh
# extract services infomation from .rc files
#
# Author: Alex.wang
# Create: 2013-01-24 19:07


# .rc files is in ramdisk directory
grep -R -E -h '^service ' ramdisk | \
while read service name binary arg1 args ; do
	echo $name
	[ "$binary" != "/system/bin/sh" -a "$binary" != "/system/bin/logwrapper" ] && echo $binary
	[ -n "$arg1" ] && echo $arg1
	[ -n "$args" ] && echo $args
	echo
done

