#!/bin/bash

id_dc=$2
id_dc_l=$(echo $id_dc | tr "[:upper:]" "[:lower:]")

# Install symlinks and conntrack user-space tools and xz-utils and strace and tcpdump and dig
export DEBIAN_FRONTEND=noninteractive
apt-get -fqqy install symlinks conntrack xz-utils strace tcpdump dnsutils arping apt-utils

# Permissions on /root/ need to change for anything to work
chmod 755 /root/

# Set the default editor to vim, nano kind of sucks
update-alternatives --set editor /usr/bin/vim.basic

# Install gdisk GPT fdisk
apt-get -fqqy install gdisk

# Install aggregate for firewall rule consolidation
apt-get -fqqy install aggregate

apt-get -fqqy install libpam-systemd
cat >>/etc/pam.d/common-session <<EOF
##### See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=751636#277
session optional        pam_systemd.so
EOF

# Enable logging timestamp in history file
echo "HISTTIMEFORMAT=\"[%d/%m/%Y:%H:%M:%S] \"" >>/etc/bash.bashrc
