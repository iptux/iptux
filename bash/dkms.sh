#!/bin/bash
#
# dkms.sh
# build all dkms module
#
# Author: Alex.wang
# Create: 2015-12-20


dkms_build() {
	local kernel="$1"
	ls /usr/src/ | \
	grep -v "^linux" | \
	sed -E -e "s,-([^-]*)$, \1," | \
	while read module version ; do
		sudo dkms build -k "${kernel}" -m "${module}" -v "${version}"
		sudo dkms install -k "${kernel}" -m "${module}" -v "${version}"
	done
}

main() {
	for kernel in `ls /lib/modules` ; do
		dkms_build "${kernel}"
	done
}

main

