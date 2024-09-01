# p4d-docker
This repository contains a collection of source files for building Docker images for Perforce Helix. It exists purely because there is no working Docker solution in existence for Perforce Helix.

## Building image
```
docker build -t <tag> .
```

## Configuration
Common options and their default values:

```sh
NAME=perforce-server
PORT=1666
P4NAME=main
P4PORT=ssl:1666
P4USER=test
P4PASSWD=password1234
P4CASE=-C0
P4CHARSET=utf8
P4SSLDIR=/cert
```

Additionally you can set `PERFORCE_UID` or `PERFORCE_GID` to force the id of user or group `perforce`, whom runs the Perforce server.

> [!WARNING]
> Please be noted that although the server survives over restarts (i.e. data are kept), but it may break if you change the options after the initial bootstrap (i.e. the very first run of the image, at when options are getting hard-coded to the Perforce Helix core server own configuration).

## SSL setup
Generate some self-signed SSL certificates, and ensure `P4SSLDIR` is set to a directory containing the SSL files, and set `P4PORT` to use SSL:

```sh
P4PORT=ssl:1666
P4SSLDIR=/cert
```

## Credits
This repository is a fork of https://github.com/sourcegraph/helix-docker, which is heavily inspired by https://github.com/p4paul/helix-docker and https://github.com/ambakshi/docker-perforce.
