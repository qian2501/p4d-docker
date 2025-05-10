#!/bin/bash
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

if [ -z "$(ls -A "$CONFIG_PATH")" ]; then
    echo >&2 "First time installation, copying default configuration..."
    cp -r /etc/perforce/* "$CONFIG_PATH"
fi

rm -r /etc/perforce
ln -s "$CONFIG_PATH" /etc/perforce

echo "Create empty or start existing server..."
if ! p4dctl list 2>/dev/null | grep -q "$SERVER_NAME"; then
	/opt/perforce/sbin/configure-helix-p4d.sh "$SERVER_NAME" -n -p "$P4PORT" -r "$P4ROOT" -u "$P4USER" -P "${P4PASSWD}" --case "$P4CASE" --unicode
fi

# P4SSLDIR is invisible to user perforce whom actually runs p4d
if [ -n "$P4SSLDIR" ]; then
    sed -i "s|P4SSLDIR[[:space:]]*=.*|P4SSLDIR  =     $P4SSLDIR|" "$CONFIG_PATH/p4dctl.conf.d/$SERVER_NAME.conf"
else
    sed -i "s|P4SSLDIR[[:space:]]*=.*|P4SSLDIR  =|" "$CONFIG_PATH/p4dctl.conf.d/$SERVER_NAME.conf"
fi

p4dctl start $SERVER_NAME

exec /usr/bin/tail -F $P4ROOT/logs/log
