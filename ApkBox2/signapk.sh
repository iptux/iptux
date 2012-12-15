#!/bin/sh
#
# signapk.sh
# call signapk.jar
#
# Author: Alex.wang
# Create: 2012-11-14 16:44
#
# Update: 2012-12-15 18:22
#  1. porting from .bat to .sh


help () {
	echo `basename $0`
	echo Usage: `basename $0` input_tobesigned.apk [output_signed.apk]
	exit 1
}

unsigned=$1
signed=$2

[ -z "${unsigned}" ] && help
[ ! -e "${unsigned}" ] && echo file not exist: "${unsigned}" && exit 1
[ -z "${signed}" ] && signed="${unsigned%\.*}s.${unsigned##*\.}"

dir="`dirname $0`/signapk"

java -jar "${dir}/signapk.jar" "${dir}/testkey.x509.pem" "${dir}/testkey.pk8" "${unsigned}" "${signed}"

