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


apktool () {
	java -jar "`dirname $0`/apktool.jar" "$@"
}

decode () {
	[ ! -e "$1.apk" ] && return
	echo decode apk: "$1.apk"
	apktool decode -f --keep-broken-res "$1.apk" "$1"
}

framework () {
	[ ! -e $1 ] && return
	echo install framework: $1
	apktool install-framework $1
}

build () {
	[ ! -e $1 ] && return
	echo build apk: "out/${1}b.apk"
	apktool build "$1" "out/${1}b.apk"
}

sign () {
	if [ -e "$1" ] ; then
		echo signing apk: "$1"
		./signapk.sh "$1"
	fi
}

buildandsign () {
	build "$1"
	sign "out/${1}b.apk"
}


[ ! -e out ] && mkdir out


if [ -n "$1" ] ; then
	# batch decode and rebuild
	while [ -n "$1" ] ; do
		if [ -e "$1" ] ; then
			buildandsign $1
		elif [ -e "$1.apk" ] ; then
			decode $1
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
		4*) [ -n "$apk" ] && sign "out/${apk}b.apk" ;;
		5*) [ -n "$apk" ] && buildandsign "$apk" ;;
		6*) [ -e "out/${apk}bs.apk" ] && adb install -r "out/${apk}bs.apk" ;;
		7*) [ -e framework-res.apk ] && framework framework-res.apk ;;
		8*) [ -n "$apk" ] && rm -rf "$apk" ;;
		0*) exit 0 ;;
		esac

		echo
	done
fi

