# Installation refer to https://www.perforce.com/manuals/p4sag/Content/P4SAG/install.linux.packages.html
ARG UBUNTU_VERSION=noble

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION
# search for available version at https://package.perforce.com/apt/ubuntu/pool/release/p
ARG P4_VERSION=2024.2-2726408

# Prepare system and install Perforce Server
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget gnupg2 && \
    \
    wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | tee /usr/share/keyrings/perforce.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu ${UBUNTU_VERSION} release" > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install -y helix-p4d=${P4_VERSION}~${UBUNTU_VERSION}

# Add external files
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Defaults
ARG NAME=perforce-server
ARG PORT=1666
ARG P4NAME=main
ARG P4ROOT=/p4
ARG P4PORT=1666
ARG P4USER=test
ARG P4PASSWD=password1234
ARG P4CASE=-C0
ARG P4CHARSET=utf8
ARG P4SSLDIR=/cert

# Environment variable
ENV NAME=$NAME \
    P4NAME=$P4NAME \
    P4ROOT=$P4ROOT \
    P4PORT=$P4PORT \
    P4USER=$P4USER \
    P4PASSWD=$P4PASSWD \
    P4CASE=$P4CASE \
    P4CHARSET=$P4CHARSET \
    P4SSLDIR=$P4SSLDIR \
    JNL_PREFIX=$P4NAME

EXPOSE $PORT
VOLUME $P4ROOT
VOLUME /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

HEALTHCHECK \
    --interval=2m \
    --timeout=10s \
    CMD p4 info -s > /dev/null || exit 1
