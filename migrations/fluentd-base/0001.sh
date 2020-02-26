#!/bin/bash

CERTS_DIR=/opt/td-agent/embedded/ssl/certs/
KEY_PASS="this-is-not-a-secret-:)"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -fyqq curl

curl https://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add -
echo "deb http://packages.treasuredata.com/3/debian/buster/ buster contrib" > /etc/apt/sources.list.d/fluentd.list
apt-get update
apt-get install -fyqq td-agent
td-agent-gem install fluent-plugin-rewrite-tag-filter

openssl req -x509 -newkey rsa:4096 -keyout $CERTS_DIR/key.pem -out $CERTS_DIR/cert.pem -days 3650 -subj "/CN=$( hostname )" -passout pass:"$KEY_PASS"
chmod 400 $CERTS_DIR/key.pem
chown -R td-agent:td-agent $CERTS_DIR
chown -R td-agent:td-agent /var/log/fluentd

# use our config
rm -f /etc/td-agent/td-agent.conf
ln -s /root/roles/fluentd-base/etc/td-agent/td-agent.conf /etc/td-agent/td-agent.conf

systemctl enable td-agent
service td-agent start
