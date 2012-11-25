#!/bin/bash
#
# libdepend.sh
# show lib dependence
#
# Author: Alex.wang
# Create: 2012-11-25 21:31


# libs that already in system
# gen using: find system/lib -name '*.so' -exec basename '{}' \; | sort
libs=cm-9-20121125-mione_plus.libs.txt

function depend() {
	[ -z "$1" ] && return

	readelf -d $1 | grep -o -E '\[\w+\.so\]' | sed -e 's,\[,, ; s,\],,' | sort | diff $libs - | sed -n -e '/^> / { s,,, ; p }' | grep -v `basename $1` | xargs echo $1:
}

function depend_orig () {
	for file in `grep -E '^bin|^lib' proprietary-files.orig.txt` ; do
		depend system/$file
	done | sort > proprietary-files.orig.depend.txt
}

function depend_proprietary () {
	for file in `find proprietary-files -type f` ; do
		depend $file
	done | grep -v ':$' | sort > proprietary-files.depend.txt
}

depend_orig
depend_proprietary

