#!/bin/bash
#
# repack.sh
# repack boot.img and recovery.img
#
# Author: Alex.wang
# Create: 2012-11-07 14:16


function repack() {
	parm=$1
	[ -z "$parm" ] && return
	[ -e $parm/newramdisk.cpio.gz ] && rm $parm/newramdisk.cpio.gz
	( cd $parm/root && find . | cpio -o -H newc | gzip > ../newramdisk.cpio.gz )
	( cd $parm && mkbootimg --cmdline "$(cat $parm.img-cmdline)" --base `cat $parm.img-base` --pagesize `cat $parm.img-pagesize` --kernel $parm.img-zImage --ramdisk newramdisk.cpio.gz -o ../new$parm.img )
}


images="$*"
[ -z "$images" ] && images="boot recovery"

for image in $images ; do
	repack $image
done


