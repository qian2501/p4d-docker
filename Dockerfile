# Installation refer to https://www.perforce.com/manuals/p4sag/Content/P4SAG/install.linux.packages.html
ARG UBUNTU_VERSION=noble

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION
# search for available version at https://package.perforce.com/apt/ubuntu/pool/release/p
ARG P4_VERSION=2024.1-2625008
ARG SWARM_VERSION=2024.3-2628402

# Prepare system and add Perforce repo
RUN apt-get update && \
    apt-get upgrade -y && \
    userdel -r ubuntu && \
    apt-get install -y wget gnupg2 && \
    wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | tee /usr/share/keyrings/perforce.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu ${UBUNTU_VERSION} release" > /etc/apt/sources.list.d/perforce.list

# Install Perforce Server
RUN apt-get update && apt-get install -y helix-p4d=${P4_VERSION}~${UBUNTU_VERSION} helix-swarm-triggers=${SWARM_VERSION}~${UBUNTU_VERSION}

# Add external files
COPY files/restore.sh /usr/local/bin/restore.sh
COPY files/setup.sh /usr/local/bin/setup.sh
COPY files/init.sh /usr/local/bin/init.sh
COPY files/latest_checkpoint.sh /usr/local/bin/latest_checkpoint.sh

RUN chmod +x /usr/local/bin/restore.sh && \
    chmod +x /usr/local/bin/setup.sh && \
    chmod +x /usr/local/bin/init.sh && \
    chmod +x /usr/local/bin/latest_checkpoint.sh

# Defaults
ARG NAME=perforce-server
ARG PORT=1666
ARG P4NAME=main
ARG P4HOME=/p4
ARG P4PORT=ssl:1666
ARG P4USER=test
ARG P4PASSWD=password1234
ARG P4CASE=-C0
ARG P4CHARSET=utf8
ARG P4SSLDIR=/cert

# Environment variable
ENV NAME=$NAME \
    P4NAME=$P4NAME \
    P4HOME=$P4HOME \
    P4PORT=$P4PORT \
    P4USER=$P4USER \
    P4PASSWD=$P4PASSWD \
    P4CASE=$P4CASE \
    P4CHARSET=$P4CHARSET \
    P4SSLDIR=$P4SSLDIR \
    JNL_PREFIX=$P4NAME

ENV P4ROOT=$P4HOME/data \
    P4DEPOTS=$P4HOME/depots \
    P4CKP=$P4HOME/checkpoints

EXPOSE $PORT
VOLUME $P4HOME

ENTRYPOINT \
    init.sh && \
    /usr/bin/tail -F $P4ROOT/logs/log

HEALTHCHECK \
    --interval=2m \
    --timeout=10s \
    CMD p4 info -s > /dev/null || exit 1
