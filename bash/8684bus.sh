#!/bin/bash
#
# 8684bus.sh
# Download 8684 bus database from 8684.cn
#
# Author: Tommy Alex
# Create: 2011-12-17 14:02


# XXX: this URLs may change, check it on http://mobile.8684.cn
down=http://mobile.8684.cn/down
busdb=http://update1.8684.cn/down/

list=8684bus.lst
outdir=8684


# check city list
if [ ! -e "${list}" ] ; then
	html=index.html

	[ ! -e "${html}" ] && wget -O "${html}" "${down}"

	grep -E -o -h '/down/[^\."]*' "${html}" | \
	sed -e 's,/down/,, ; s,\s*$,,' | \
	sort | \
	uniq > "${list}"

	rm "${html}"
fi


[ ! -e "${outdir}" ] && mkdir "${outdir}"

while read city ; do
	[ ! -e "${outdir}/${city}" ] && wget -O "${outdir}/${city}" "${busdb}${city}"
done < "${list}"

# tar Jcf 8684bus-`date +%Y%m%d`.tar.xz 8684 8684bus.sh 8684bus.lst 8684bus.bat decode.exe
tar Jcf 8684bus-`date +%Y%m%d`.tar.xz "${outdir}" `basename $0` "${list}" 8684bus.bat decode.exe

echo "Move 8684 directory to SD card and enjoy!"

