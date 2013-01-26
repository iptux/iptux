#!/bin/sh
#
# smali_clean.sh
# clean some smali code
#
# Author: Alex.wang
# Create: 2012-11-14 18:35
#
# Update: 2012-12-15 18:22
#  1. porting from .bat to .sh


help () {
	script=`basename $0`
	echo ${script} - clean some smali code
	echo Usage: ${script} APK KEYWORD...
	echo Example: ${script} apk_dir com.google.ads
	exit 1
}


apkdir=$1
[ -z "${apkdir}" ] && help
[ ! -e "${apkdir}" ] && echo dir not exist: "${apkdir}"
shift

# backup smali
[ -n "$1" -a ! -e "${apkdir}/smali.orig" ] && cp -R "${apkdir}/smali" "${apkdir}/smali.orig"

while [ -n "$1" ] ; do
	classname="$1"
	# remove the class
	rm -rf "${apkdir}/smali/`echo ${classname} | sed -e 's,\.,/,g'`"

	# remove refernce to this class
	for file in `grep -E -R -l "${classname}" "${apkdir}/smali" 2>/dev/null` ; do
		echo sed -r -i -e "/invoke.*${classname}/ s,^,#," "${file}"
		sed -r -i -e "/invoke.*${classname}/ s,^,#," "${file}" 2>/dev/null
	done

	# show reference still exist
	grep -E -R -n "${classname}" "${apkdir}/smali" 2>/dev/null | grep -v -E ':#' 2>/dev/null

	# next
	shift
done

