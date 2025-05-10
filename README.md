# p4d-docker
This repository contains a collection of source files for building Docker images for Perforce Helix. It exists purely because there is no working Docker solution in existence for Perforce Helix.

## Building image
```
docker build -t <tag> .
```

## Environments
Common options and their default values:

```sh
SERVER_NAME=perforce-server
CONFIG_PATH=/config
P4ROOT=/p4
P4PORT=1666
P4USER=test
P4PASSWD=password1234
P4CASE=-C0
P4SSLDIR=
```

Additionally you can set `PERFORCE_UID` or `PERFORCE_GID` to force the id of user or group `perforce`, whom runs the Perforce server.

> [!WARNING]
> Please be noted that although the server survives over restarts (i.e. data are kept), but it may break if you change the options after the initial bootstrap (i.e. the very first run of the image, at when options are getting hard-coded to the Perforce Helix core server own configuration).

## Volumes
Mount `$CONFIG_PATH` to preserve server configurations.  
Mount `$P4ROOT` for data storage.

## SSL setup
Generate some self-signed SSL certificates, and ensure `P4SSLDIR` is set to a directory containing the SSL files, and set `P4PORT` to use SSL:

```sh
P4PORT=ssl:1666
P4SSLDIR=/config/ssl
```

Note that certificate files must have `600` permission and `$P4SSLDIR` must have `700` permission, p4d will reject them otherwise.

## Credits
This repository is a fork of https://github.com/sourcegraph/helix-docker, which is heavily inspired by https://github.com/p4paul/helix-docker and https://github.com/ambakshi/docker-perforce.

## Additional Notes
- The original fork uses swarm trigger. The trigger is removed but extension is not included in this fork yet. As per doc:
    > Triggers are still supported, but we recommend you use Helix Core Server Extensions.

- This fork optimized the original concept on preserving server status. Configs and data files are now seperated, and you should mount volumes for them.

