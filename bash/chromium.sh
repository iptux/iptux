#!/bin/bash
#
# chromium.sh
# auto download lastast chromium
#
# Author: Alex.wang
# Create: 2012-07-01 16:37


url="http://commondatastorage.googleapis.com/chromium-browser-snapshots"
change='LAST_CHANGE'


function getchromium()
{
	[ -z "$1" ] && return
	local version=`wget -O - $url/$1/$change`
	[ -z "$version" ] && return
	wget -c -O "chrome-$1-$version.zip" "$url/$1/$version/chrome-$2.zip"
}


getchromium Win win32
getchromium Linux linux
getchromium Mac mac
getchromium Linux_x64 linux
getchromium Arm linux
getchromium Linux_ChromiumOS linux
getchromium Linux_ARM_Cross-Compile linux
getchromium chromium-full-linux-chromeos linux

