#!/bin/bash
#
# nightly.sh
# start nighly build, then I can goto sleep
#
# Author: Alex.wang
# Create: 2012-11-22 22:34


function nightly () {
	[ -z "$1" ] && return

	# start in subshell
	(
		cd $1
		repo sync -j1
		rm -rf out/target/product/$1
		. build/envsetup.sh
		brunch $1
	)
}


targets="$*"
[ -z "$targets" ] && targets="p350 mione_plus"
for target in $targets ; do
	nightly $target
done

