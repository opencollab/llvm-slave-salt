#!/bin/bash
# sh create-new-build-target.sh stretch http://deb.debian.org/debian/stretch/main
# Save a configuration file in dod-repo-conf/ before running this 
# eg cp stretch.conf dod-repo-conf/

if test $# -ne 2; then
	echo "Syntax:"
	echo "$0 distribution name source url"
	exit 1
fi

DISTRIBUTION=$1
URL=$2

if [ ! -f ../dod-repo-conf/$1.conf ]; then
	echo "Configuration file $1.conf not found"
	exit 1
fi

NEW_DOD_REPO_TEMPLATE="templates/dod-repo.xml"

sed -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" -e "s|@URL@|$URL|g" $NEW_DOD_REPO_TEMPLATE > /tmp/$1.xml

osc meta prj $1 -F /tmp/$1.xml
osc meta prjconf $1 -F ../dod-repo-conf/$1.conf
