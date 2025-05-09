#!/bin/bash

# Specify UID and GID
if [ ! -z "${PERFORCE_UID}" ]; then
  	if [ ! "$(id -u perforce)" -eq "${PERFORCE_UID}" ]; then
		usermod -o -u "${PERFORCE_UID}" perforce
	fi
fi

if [ ! -z "${PERFORCE_GID}" ]; then
  	if [ ! "$(id -g perforce)" -eq "${PERFORCE_GID}" ]; then
		groupmod -o -g "${PERFORCE_GID}" perforce
	fi
fi

# Setup directories
mkdir -p "$P4ROOT"

if [ ! -d "/config" ]; then
	mkdir -p "/config"
fi

if [ -z "$(ls -A /config)" ]; then
    echo >&2 "First time installation, copying configuration from /etc/perforce to $P4ROOT/etc and relinking"
    cp -r /etc/perforce/* "/config"
fi

rm -r /etc/perforce
ln -s "/config" /etc/perforce

echo "Create empty or start existing server..."
if p4dctl list 2>/dev/null | grep -q "$NAME"; then
	p4dctl start $NAME
else
	/opt/perforce/sbin/configure-helix-p4d.sh "$NAME" -n -p "$P4PORT" -r "$P4ROOT" -u "$P4USER" -P "${P4PASSWD}" --case "$P4CASE" --unicode
fi

/usr/bin/tail -F $P4ROOT/logs/log
