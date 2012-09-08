#!/bin/bash
#
# chromium.sh
# auto download lastast chromium
#
# Author: Alex.wang
# Create: 2012-07-01 16:37


url="http://commondatastorage.googleapis.com/chromium-browser-snapshots"
change='LAST_CHANGE'

function getversion()
{
	[ -z "$1" ] && return
	[ -e $change ] && rm $change
	wget $url/$1/$change
	[ ! -e $change ] && return
	cat $change
	rm $change
}


function getchromium()
{
	local version=`getversion $1`
	[ -z "$version" ] && return
	wget -c -O "chrome-$2-$version.zip" "$url/$1/$version/chrome-$2.zip"
}


getchromium Win win32
getchromium Linux linux
getchromium Mac mac
getchromium Linux_x64 linux

