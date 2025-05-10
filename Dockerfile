ARG UBUNTU_VERSION=noble
FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION
# search for available version at https://package.perforce.com/apt/ubuntu/pool/release/p
ARG P4_VERSION=2024.2-2726408

# Prepare system and install Perforce Server
# Installation refer to https://www.perforce.com/manuals/p4sag/Content/P4SAG/install.linux.packages.html
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget gnupg2 && \
    userdel -r ubuntu && \
    \
    wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | tee /usr/share/keyrings/perforce.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu ${UBUNTU_VERSION} release" > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install -y helix-p4d=${P4_VERSION}~${UBUNTU_VERSION} && \
    apt-get remove -y wget gnupg2

# Add external files
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variable
ENV SERVER_NAME=perforce-server \
    CONFIG_PATH=/config \
    P4ROOT=/p4 \
    P4PORT=1666 \
    P4USER=test \
    P4PASSWD=password1234 \
    P4CASE=-C0 \
    P4SSLDIR=

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
