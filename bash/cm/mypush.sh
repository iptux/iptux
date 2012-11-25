#!/bin/bash
#
# mypush.sh
# push files to android device
#
# Author: Alex.wang
# Create: 2012-11-25 21:16


grep -E -v '^#|^\s*$' | while read file ; do
	echo pushing "$file"
	adb push system/$file /system/$file
	if echo $file | grep '^bin' ; then
		adb shell chmod 755 /system/$file
	else
		adb shell chmod 644 /system/$file
	fi
done


