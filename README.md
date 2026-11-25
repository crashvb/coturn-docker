# coturn-docker

[![version)](https://img.shields.io/docker/v/crashvb/coturn/latest)](https://hub.docker.com/repository/docker/crashvb/coturn)
[![image size](https://img.shields.io/docker/image-size/crashvb/coturn/latest)](https://hub.docker.com/repository/docker/crashvb/coturn)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/coturn-docker.svg)](https://github.com/crashvb/coturn-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [coturn](https://github.com/coturn/coturn), configured for STUN only. TURN authentication and relay settings are retained but unused.

## Entrypoint Scripts

### coturn

The embedded entrypoint script is located at `/etc/entrypoint.d/coturn` and performs the following actions:

1. The PKI certificates are generated or imported from secrets.
2. A new coturn configuration is generated, if absent, using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | COTURN\_IP\_LISTENING | 0.0.0.0,:: | Comma-separated listening IP addresses. |
 | COTURN\_IP\_RELAY | 0.0.0.0,:: | Comma-separated relay IP addresses; unused in STUN-only mode. |
 | COTURN\_PORT\_RANGE | 49152-49200 | Relay port range (`min-max`); unused in STUN-only mode. |

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ coturn/
│  │  └─ turnserver.conf
│  ├─ entrypoint.d/
│  │  └─ coturn
│  ├─ healthcheck.d/
│  │  └─ coturn
│  └─ supervisor/
│     └─ conf.d/
│        └─ coturn.conf
├─ run/
│  └─ secrets/
│     ├─ coturn.crt
│     ├─ coturn.key
│     └─ coturnca.crt
└─ var/
   └─ lib/
      └─ coturn/
         └─ turndb
```

### Exposed Ports

* `3478/tcp` - STUN listening port.
* `3478/udp` - STUN listening port.
* `5349/tcp` - TLS listening port.
* `5349/udp` - DTLS listening port.

### Volumes

* `/etc/coturn` - coturn configuration directory.

## Development

[Source Control](https://github.com/crashvb/coturn-docker)
