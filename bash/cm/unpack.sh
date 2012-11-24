#!/bin/bash
#
# unpack.sh
# unpack boot.img and recovery.img
#
# Author: Alex.wang
# Create: 2012-11-07 14:16


function unpack() {
	parm=$1
	[ -z "$parm" ] && return
	mkdir -p $parm
	unpackbootimg -i $parm.img -o $parm
	rm -rf $parm/root
	mkdir -p $parm/root
	( cd $parm/root && gunzip -c ../$parm.img-ramdisk | cpio -i )
}


images="$*"
[ -z "$images" ] && images="boot recovery"

for image in $images ; do
	unpack $image
done


