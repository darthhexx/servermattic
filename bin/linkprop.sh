#!/bin/bash

CR="
"
SP=" "

## Sanity Check
if [ ! -d /root/roles/$1 ]; then
	exit 0
fi

IFS=$CR
for i in $( find /root/roles/$1/ ); do
	to=$( echo $i | sed s/"\/root\/roles\/$1"/''/1 )
	to_dir=${to%'/'*}
	still_do=1
	seen_in=""
	if [ "$1" = "base" ]; then
		cpwd=$( pwd )
		cd /root/roles
		for role in $( ls -1 | grep -Ev '^base$' ); do
			if [ -f /root/roles/$role$to ]; then
				still_do=0
				seen_in="$role, $seen_in"
			fi
		done
		cd $cpwd
	fi
	if [ $still_do -eq 1 ]; then
		if [ ! "$to_dir" = "" ]; then
			mkdir -p $to_dir
		fi
		if [ ! -d $i ]; then
			ln -sf "$i" "$to" 2>&1 | grep -v 'are the same file'
		fi
	else
		echo "$to overridden by non-base role ("$(echo $seen_in | sed -r s/', $'/''/)")"
	fi
done
