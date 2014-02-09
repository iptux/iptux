#!/bin/bash
#
# nightly.sh
# start nighly build, then I can goto sleep
#
# Author: Alex.wang
# Create: 2012-11-22 22:34


function nightly () {
	# parm: branch device
	[ -z "$1" ] && return
	[ -z "$2" ] && return

	echo remove old build
	rm -rf "$1/out/target/product/$2"

	echo start sync $1
	( cd $1 && repo sync -j1 )

	echo start build "$2"
	( cd $1 && . build/envsetup.sh && brunch $2 )
}

export LANG=
export USE_CCACHE=1

# now we use new dir layout in `BuildingDirectoryLayout.txt'
nightly jellybean mione_plus

