#!/bin/bash
#
# alarm.sh
# play a sound to alarm me
#
# Author: Alex.wang
# Create: 2012-01-08 03:10


function AlarmMe () {
	# -loop 0: endless loop, need Ctrl+C to stop
	# -af volume=10.1: 10dB volume
	# 2>/dev/null 1&>2: output nothing
	mplayer -loop 0 -af volume=10 /media/ext3/cm/Hassium.ogg 2>/dev/null 1&>2
}

AlarmMe

