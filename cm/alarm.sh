#!/bin/bash
#
# alarm.sh
# play a sound to alarm me
#
# Author: Alex.wang
# Create: 2012-01-08 03:10


ALARM_FILE=/media/ext3/cm/Hassium.ogg


function AlarmMe () {
	echo "Press Ctrl+C to stop alarm"

	# -loop 0: endless loop, need Ctrl+C to stop
	# -af volume=10: 10dB volume
	# >/dev/null 2&>1: output nothing
	mplayer -loop 0 -af volume=10 ${ALARM_FILE} >/dev/null 2>&1
}

AlarmMe

