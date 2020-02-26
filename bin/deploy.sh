#!/bin/bash

GITURL="https://github.com/darthhexx/servermattic.git"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -fqqy upgrade

for x in $( apt-get -fqqy install ca-certificates wget vim git apt-utils net-tools ); do
	echo -e "\t$x"
done

mkdir -p /root/bin

if echo $GITURL | grep -q '^git@github.com:'; then
	ssh-keyscan -t rsa -H github.com >> ~/.ssh/known_hosts
fi

cd /root
if [ ! -d .git ]; then
	git init
	git remote add origin $GITURL
	git fetch
	git checkout -q -f -t origin/master
	git pull
fi

export DEBIAN_FRONTEND=noninteractive
/bin/bash /root/bin/role.sh init

# Remove thyself
#rm $0
