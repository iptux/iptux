#!/bin/sh
#
# apk.sh
# apk decode and rebuild tool
#
# Author: Alex.wang
# Create: 2012-11-14 16:57
#
# Update: 2012-12-15 18:22
#  1. porting from .bat to .sh
#
# Update: 2012-12-15 22:24
#  1. add baksmali/smali support


readonly PROGDIR="$(cd `dirname $0`;pwd)"
readonly OUT="${PROGDIR}/out"

jar () {
	local jar="${PROGDIR}/jar/$1.jar"
	shift
	java -jar "${jar}" "$@"
}

unpackandundex () {
	[ ! -e "$1.apk" ] && return
	[ -e "$1" ] && rm -rf "$1"

	echo unpack: "$1.apk"
	unzip "$1.apk" classes.dex -d "$1"
	echo undex: "$1/classes.dex"
	jar baksmali --output "$1/smali" "$1/classes.dex"
}

redexandpack () {
	[ ! -e "$1" ] && return

	echo redex: "$1/smali"
	jar smali --output "$1/classes.dex" -- "$1/smali"

	echo pack: "${OUT}/${1}-unsigned.apk"
	cp --force "${1}.apk" "${OUT}/${1}-unsigned.zip"
	( cd $1 && zip -u "${OUT}/${1}-unsigned.zip" classes.dex )
	mv --force "${OUT}/${1}-unsigned.zip" "${OUT}/${1}-unsigned.apk"
}

decode () {
	[ ! -e "$1.apk" ] && return

	echo decode apk: "$1.apk"
	jar apktool decode --force --keep-broken-res --output "$1" "$1.apk"

	# if decode failed, try baksmali.jar
	if [ ! -e "$1/apktool.yml" ] ; then
		echo Failed decoding "$1.apk", try baksmali.jar
		unpackandundex $1
	fi
}

framework () {
	[ ! -e "$1" ] && return

	echo install framework: $1
	jar apktool install-framework $1
}

build () {
	[ ! -e "$1" ] && return

	# is decoded by apktool.jar succ?
	if [ -e "$1/apktool.yml" ] ; then
		echo build apk: "${OUT}/${1}-unsigned.apk"
		jar apktool build --output "${OUT}/${1}-unsigned.apk" "$1"
	else
		redexandpack $1
	fi
}

sign () {
	if [ -e "$1" ] ; then
		echo signing apk: "$1"
		"${PROGDIR}/signapk.sh" "$@"
	fi
}

buildandsign () {
	[ ! -e "${OUT}" ] && mkdir "${OUT}"

	build "$1"
	sign "${OUT}/${1}-unsigned.apk" "${OUT}/${1}-unaligned.apk"
	zipalign -f -p 4 "${OUT}/${1}-unaligned.apk" "${OUT}/${1}-debug.apk"
}


if [ -n "$1" ] ; then
	# batch decode and rebuild
	while [ -n "$1" ] ; do
		apk="${1%\.*}"
		if [ -e "${apk}" ] ; then
			buildandsign "${apk}"
		elif [ -e "$1" ] ; then
			decode "${apk}"
		fi
		# next apk
		shift
	done
else
	# interactive mode
	apk=
	while : ; do
		echo apk name: ${apk}

		# show menu
		echo 1. set apk name
		echo 2. decode apk
		echo 3. rebuild apk
		echo 4. sign apk
		echo 5. rebuild and sign apk
		echo 6. install apk to device
		echo 7. install framework-res.apk
		echo 8. clean workspace
		echo 0. exit

		read -p "enter your choise: " choose
		case "${choose}" in
		1*) read -p "enter apk name: " apk ;;
		2*) [ -n "$apk" ] && decode "$apk" ;;
		3*) [ -n "$apk" ] && build "$apk" ;;
		4*) [ -n "$apk" ] && sign "${OUT}/${apk}-unsigned.apk" "${OUT}/${apk}-unaligned.apk" ;;
		5*) [ -n "$apk" ] && buildandsign "$apk" ;;
		6*) [ -e "${OUT}/${apk}-debug.apk" ] && adb install -r "${OUT}/${apk}-debug.apk" ;;
		7*) [ -e framework-res.apk ] && framework framework-res.apk ;;
		8*) [ -n "$apk" ] && rm -rf "$apk" ;;
		0*) exit 0 ;;
		esac

		echo
	done
fi

