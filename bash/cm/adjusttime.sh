#!/bin/bash
#
# adjusttime.sh
# adjust time for android device
#
# Author: Alex.wang
# Create: 2012-11-23 18:51


adb shell date -s `date +%Y%m%d.%H%M%S`

