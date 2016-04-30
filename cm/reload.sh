#!/bin/bash
#
# reload.sh
# reload a bootable image to android device
#
# Author: Alex.wang
# Create: 2012-11-24 15:33


function reload() {
	[ -z "$1" ] && return
	local image="$1"
	adb reboot bootloader

	# if a dir, pack and then load it
	if [ -d "${image}" ] ; then
		./repack.sh $image
		fastboot boot "new${image}.img"
	# if a file, just load it
	elif [ -f "${image}" ] ; then
		fastboot boot "${image}"
	fi
}


parm="$1"
[ -z "$parm" ] && parm=boot.img
reload "${parm%\.*}"

