#!/bin/bash

GITURL="https://github.com/darthhexx/servermattic.git"

export DEBIAN_FRONTEND=noninteractive

need_help=0
if [ $# -eq 0 ];      then need_help=1; fi
if [ "$1" = "?" ];    then need_help=1; fi
if [ "$1" = "help" ]; then need_help=1; fi

if [ $need_help -eq 1 ]; then
	echo -e "Args for " $0
	echo -e "\thelp|?\tShow this help"
	echo -e "\tinit\tInitialize the system"
	echo -e "\tupdate\tUpdate migration data"
	exit 0
fi

function get_metadata {
	primary_ip=$( ip route get 8.8.8.8 | sed -r -n -e 's/^8.8.8.8.*src ([[:digit:].]+).*$/\1/p' | xargs )
	id_meta=$( awk -F : '$0 ~ /^[^#]/ && $3 ~ /^'$primary_ip'$/' /root/etc/servers.dat )
	if [ "$id_meta" = "" ]; then
		echo "Did not find a server with IP {$primary_ip} or the server has no metadata set. Please check /root/etc/servers.dat"
		exit 0
	fi

	export primary_ip=$primary_ip
	export sid=$( echo $id_meta | cut -d':' -f1 )
	export id_hn=$( echo $id_meta | cut -d':' -f4 )
	export id_dc=$( echo $id_meta | cut -d':' -f2 )
	export id_be=$( echo $id_meta | cut -d':' -f5 )
	if [ "$id_be" = "" ]; then export id_be="NA"; fi
	export id_roles=$( echo $id_meta | cut -d':' -f6 )
}

function sysinit {
	chmod ug+x /root/bin/*

	if [ -d /root/.git ]; then
		cd /root
		git pull
	else
		cd /root
		git init
		git remote add origin $GITURL
		git checkout -q -f -t origin/master
		git pull
	fi

	if [ ! -d /etc/roles ]; then
		mkdir -p /etc/roles
	fi

	if [ ! -d /root/roles ]; then
		mkdir -p /root/roles
	fi

	if [ ! -d /root/migrations ]; then
		mkdir -p /root/migrations
	fi

	if [ ! -d /root/etc ]; then
		mkdir -p /root/etc
	fi
}

function update {
	chmod ug+x /root/bin/*
	cd /root
	git pull -q
	roles=$( ls -1 /root/roles/ | wc -l )
}

function apply_role {
CR="
"
SP=" "
	get_metadata
	echo -e "Server Info:"
	echo -e "\tServer ID:\t$sid"
	echo -e "\tIp Address:\t$primary_ip"
	echo -e "\tDataCenter:\t$id_dc"
	echo -e "\tHostname:\t$id_hn"
	echo -e "\tBackend:\t$id_be"
	echo -e "\tRoles:\t\t$id_roles"
	echo

	## Role Work
	if [ ! "$2" = "" ]; then
		if [ -d /root/migrations/$2 ]; then
			if [ -f /etc/roles/$2 ]; then
				current_revision=$( cat /etc/roles/$2 )
			else
				current_revision=0
			fi
			for i in $( ls /root/migrations/$2/????.sh ); do
				script=$( echo $i | cut -d '/' -f 5 )
				revision=$( echo $script | cut -d '.' -f 1 )
				if [ $current_revision -lt $revision ]; then
					echo -e "Applying Role:\t$2\tRev:\t$revision"
					OIFS=$IFS
					IFS=$CR
					if [ ! -d /root/tags/$2 ]; then
						cd /root
						for x in $( git -q pull ); do
							echo -e "\t$x"
						done
					fi
					if [ ! -d /root/roles/$2 ]; then
						ln -s /root/tags/$2/$revision /root/roles/$2
					fi
					IFS=$OIFS
					/root/bin/linkprop.sh $2
					/bin/bash $i up $id_dc $id_hn $id_be
				fi
			done
		else
			echo "invalid role"
		fi
	else
		echo "please specify a role"
	fi
}

function apply_auto {
	get_metadata

	# We always apply base, if it exists
	if [ -d /root/migrations/base ]; then
		if [ ! -f /etc/roles/base ]; then
			$0 apply base
		fi
	fi

	if [ "$id_roles" = "" ]; then
		echo "This server has no auto-apply roles defined"
		return 0
	fi

	# Auto-apply per-host role if it exists
	if [ -d /root/migrations/$id_hn ]; then
		if [ ! -f /etc/roles/$id_hn ]; then
			$0 apply $id_hn
		fi
	fi

	IFS=","
	for i in $id_roles; do
		# Don't apply empty roles, or base (since we did earlier)
		if [ ! "$i" = "" ]; then
			if [ ! "$i" = "base" ]; then
				if [ ! -f /etc/roles/$i ]; then
					$0 apply $i
				fi
			fi
		fi
	done

	return 0;
}

case $1 in
	init)
		sysinit
		apply_auto
		;;
	update)
		update
		;;
	apply)
		apply_role $@
		;;
esac
