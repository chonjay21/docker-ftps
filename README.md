# [**FTPS**](https://github.com/chonjay21/docker-ftps)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/chonjay21/ftps)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/chonjay21/ftps)
![Docker Pulls](https://img.shields.io/docker/pulls/chonjay21/ftps)
![GitHub](https://img.shields.io/github/license/chonjay21/docker-ftps)
![Docker Stars](https://img.shields.io/docker/stars/chonjay21/ftps?style=social)
![GitHub stars](https://img.shields.io/github/stars/chonjay21/docker-ftps?style=social)
## FTPS based on official latest alpine image
* Support Multiple architectures
* Support Authentication
* Support SSL(ftps) with automatically generated self signed certificate
* Support passive mode ftps
* Support umask change
* Support UserID|GroupID change
* Support custom TimeZone
* Support custom event script override

<br />

# Who I am
Our goal is to create a simple, consistent, customizable and convenient image using official image

Find me at:
* [GitHub](https://github.com/chonjay21)
* [Blog](https://chonjay.tistory.com/)

<br />

# Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64, latest |
| armhf | arm32v7, latest |
| arm64 | arm64v8, latest |

<br />

# Usage

Here are some example snippets to help you get started running a container.

## docker (simple)

```
docker run -e APP_USER_NAME=admin -e APP_USER_PASSWD=admin -e APP_UID=1000 -e APP_GID=1000 -e PASSV_MIN_PORT=60000 -e PASSV_MAX_PORT=60010 -p 21:21 -p 60000-60010:60000-60010 -v /vsftpd/data:/home/vsftpd/data chonjay21/ftps
```

## docker

```
docker run \
  -e APP_USER_NAME=admin	\
  -e APP_USER_PASSWD=admin	\
  -e APP_UID=1000	\
  -e APP_GID=1000	\
  -e PASSV_MIN_PORT=60000	\
  -e PASSV_MAX_PORT=60010	\
  -e FORCE_REINIT_CONFIG=false                  `#optional` \
  -e USE_SSL=true                               `#optional` \
  -e APP_UMASK=007                              `#optional` \
  -e TZ=America/Los_Angeles                     `#optional` \
  -p 21:21 \
  -p 60000-60010:60000-60010 \
  -v /vsftpd/data:/home/vsftpd/data \
  -v /vsftpd/cert.key:/usr/certs/cert.key:ro    `#optional for custom certificate(USE_SSL=true)` \
  -v /vsftpd/cert.crt:/usr/certs/cert.crt:ro    `#optional for custom certificate(USE_SSL=true)` \
  chonjay21/ftps
```


## docker-compose

Compatible with docker-compose v2 schemas. (also compatible with docker-compose v3)

```
version: '2.2'
services:
  ftps:
    container_name: ftps
    image: chonjay21/ftps:latest
    ports:
      - "21:21"
      - "60000-60010:60000-60010"
    environment:
      - APP_USER_NAME=admin
      - APP_USER_PASSWD=admin
      - APP_UID=1000
      - APP_GID=1000
      - PASSV_MIN_PORT=60000
      - PASSV_MAX_PORT=60010
      - FORCE_REINIT_CONFIG=false                  #optional
      - USE_SSL=true                               #optional
      - APP_UMASK=007                              #optional
      - TZ=America/Los_Angeles                     #optional
    volumes:
      - /vsftpd/data:/home/vsftpd/data
      - /vsftpd/cert.key:/usr/certs/cert.key:ro    #optional for custom certificate(USE_SSL=true)
      - /vsftpd/cert.crt:/usr/certs/cert.crt:ro    #optional for custom certificate(USE_SSL=true)
```

# Parameters

| Parameter | Function | Optional |
| :---- | --- | :---: |
| `-p 21` | for ftp port |  |
| `-p 60000-60010` | for ftp passive mode port |  |
| `-e APP_USER_NAME=admin` | for login username |  |
| `-e APP_USER_PASSWD=admin` | for login password |  |
| `-e APP_UID=1000` | for filesystem permission (userid)  |  |
| `-e APP_GID=1000` | for filesystem permission (groupid)  |  |
| `-e PASSV_MIN_PORT=60000` | for ftp passive mode port range limit  |  |
| `-e PASSV_MAX_PORT=60010` | for ftp passive mode port range limit  |  |
| `-e FORCE_REINIT_CONFIG=false` | if true, always reinitialize APP_USER_NAME etc ...  | O |
| `-e USE_SSL=false` | if true, use ssl for ftps (with automatically created selfsigned certificate) | O |
| `-e APP_UMASK=007` | for filesystem permission umask  | O |
| `-e TZ=America/Los_Angeles` | for timezone  | O |
| `-v /home/vsftpd/data` | for data access with this container |  |
| `-v /usr/certs/cert.key` | for custom ssl certificate | O |
| `-v /usr/certs/cert.crt` | for custom ssl certificate | O |

<br />

# Event scripts

All of our images are support custom event scripts

| Script | Function |
| :---- | --- |
| `/sources/ftps/eventscripts/on_pre_init.sh` | called before initialize container (only for first time) |
| `/sources/ftps/eventscripts/on_post_init.sh` | called after initialize container (only for first time) |
| `/sources/ftps/eventscripts/on_run.sh` | called before running app (every time) |

You can override these scripts for custom logic
for example, if you don`t want your password exposed by environment variable, you can override on_pre_init.sh in this manner

## Exmaple - on_pre_init.sh
```
#!/usr/bin/env bash
set -e

APP_USER_PASSWD=mysecretpassword    # or you can set password from secret store and get with curl etc ...
```

## 1. Override with volume mount
```
docker run \
  ...
  -v /ftps/on_pre_init.sh:/sources/ftps/eventscripts/on_pre_init.sh \
  ...
  chonjay21/ftps
```

## 2. Override with Dockerfile
```
FROM chonjay21/ftps:latest
ADD host/on_pre_init.sh /sources/ftps/
```

<br />

# License

View [license information](https://github.com/chonjay21/docker-ftps/blob/master/LICENSE) of this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.