#!/bin/bash
#
# checkout.sh
# checkout a branch or a tag of a bare git repo to another dir
# all these dir reference to the same repo
#
# Author: Alex.wang
# Create: 2014-05-05 22:15


# I'm using it for linux kernel
REPO=linux.git


checkout ()
{
	REFS=$1
	DIR=$2
	[ -z "${REFS}" ] && return 1
	[ -z "${DIR}" ] && DIR=$REFS

	mkdir -p ${DIR}/.git
	for link in config description hooks info logs objects packed-refs refs rr-cache svn ; do
		[ -e "${DIR}/.git/${link}" ] || ln -s "../../${REPO}/${link}" "${DIR}/.git/${link}"
	done

	[ -e "${DIR}/.git/HEAD" ] && return 0

	cp "${REPO}/HEAD" "${DIR}/.git/HEAD"
	(
		cd "${DIR}"
		git checkout "${REFS}"
	)
}


checkout "$@"

