#!/bin/bash
#
# dex2jar.sh
# wrapper script for dex2jar .jar
#
# Author: Alex.wang
# Create: 2016-09-02 21:18


# script and their launcher class name
readonly -A DEX2JAR=(
	[baksmali]=com.googlecode.d2j.smali.BaksmaliCmd
	[dex2jar]=com.googlecode.dex2jar.tools.Dex2jarCmd
	[dex2smali]=com.googlecode.d2j.smali.BaksmaliCmd
	[dex-recompute-checksum]=com.googlecode.dex2jar.tools.DexRecomputeChecksum
	[jar2dex]=com.googlecode.dex2jar.tools.Jar2Dex
	[jar2jasmin]=com.googlecode.d2j.jasmin.Jar2JasminCmd
	[jasmin2jar]=com.googlecode.d2j.jasmin.Jasmin2JarCmd
	[smali]=com.googlecode.d2j.smali.SmaliCmd
	[std-apk]=com.googlecode.dex2jar.tools.StdApkCmd
)

readonly ZERO=`realpath --relative-base=$(dirname $0) $0`
readonly DIR=`dirname ${ZERO}`
readonly LIB="${DIR}/dex2jar"

# build java classpath from library directory
classpath() {
	local classpath=.
	if [ -d "$1" ] ; then
		local jar
		for jar in "$1"/*.jar ; do
			classpath="${classpath}:${jar}"
		done
	fi
	echo "${classpath}"
}

# get class name by script name
classname() {
	if [ -n "$1" ] ; then
		echo "${DEX2JAR[$1]}"
	fi
}

dex2jar() {
	local classname=`classname $1`
	if [ -n "${classname}" ] ; then
		shift
	else
		classname=`classname dex2jar`
	fi

	java -Xmx1024m -classpath `classpath "${LIB}"` "${classname}" "$@"
}

dex2jar "$@"
