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
mkdir -p "$P4DEPOTS"
mkdir -p "$P4CKP"

# Restore checkpoint if symlink latest exists
if [ -L "$P4CKP/latest" ]; then
    echo "Restoring checkpoint..."
	restore.sh
	rm "$P4CKP/latest"
else
	echo "Create empty or start existing server..."
	setup.sh
fi

p4 login <<EOF
$P4PASSWD
EOF

echo "Perforce Server starting..."
until p4 info -s 2> /dev/null; do sleep 1; done
echo "Perforce Server [RUNNING]"

## Remove all triggers
echo "Triggers:" | p4 triggers -i
