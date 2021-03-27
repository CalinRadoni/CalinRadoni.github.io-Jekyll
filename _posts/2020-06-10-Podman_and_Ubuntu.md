---
layout: post
title: "Podman and Ubuntu 20.04 LTS"
description: "Installation and basic usage of Podman in Ubuntu 20.04 LTS"
#image: /assets/img/.png
date-modified: 2021-03-26
categories: [ "System Administration" ]
tags: [ "Podman", "Ubuntu", "Buildah", "Docker" ]
---

I have built a new version of this document for rootless containers and pods at [Manage Podman root and rootless containers and pods with Systemd]({% post_url 2021-03-27-Podman_Systemd %}) but this document still have useful information.

*optional:* Uninstall old Docker versions, if any:

```sh
sudo apt remove docker
sudo apt remove docker-engine
sudo apt remove docker.io
sudo apt remove containerd runc
```

## Install Podman and Buildah

```sh
#!/bin/bash
set -e

# add the repository from Kubic project
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
# and its key
wget -qO - https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key | sudo apt-key add -

# install podman and buildah
sudo apt update && sudo apt install -y podman buildah
```

## Configuration files

- `/etc/containers/registries.conf`, (man registries.conf.5)
- `/usr/share/containers/mounts.conf` and optionally `/etc/containers/mounts.conf`
- `/usr/share/containers/seccomp.json`
- `/etc/containers/policy.json`, (man policy.json.5)

### Local repository

Docker's local repository is in `/var/lib/docker` but Podman's local repository is in (based on the Open Containers Initiative (OCI) standards):

- `/var/lib/containers`
- `~/.local/share/containers`

To gracefully move images between `/var/lib/docker` and `/var/lib/containers` use `podman pull` and `podman push` like:

```sh
# pull from Docker to Podman
systemctl stop docker
podman pull docker-daemon:myfedora:latest

# push from Podman to Docker
podman push myfedora docker-daemon:myfedora:latest
```

## Basic commands

- `podman --help` and `podman <subcommand> --help`
- `man podman` and `man podman-<subcommand>`

- `podman search <search_term>`
- `podman search --filter=is-official debian`
- `podman search --list-tags docker.io/library/debian`
- `podman pull registry.fedoraproject.org/f29/httpd`
- `podman images`

- `podman run -dt -p 8080:8080/tcp registry.fedoraproject.org/f29/httpd`
- `podman ps` and `podman ps -a`
- `podman inspect -l`
- `podman logs -l`
- `podman top -l`
- `podman stop -l`
- `podman rm -l`

## More information

- [Networking](https://podman.io/getting-started/network)
- [Checkpointing](https://podman.io/getting-started/checkpoint)
- [Podman Commands](https://github.com/containers/libpod/blob/master/commands-demo.md)
- [Podman and Buildah for Docker users](https://developers.redhat.com/blog/2019/02/21/podman-and-buildah-for-docker-users/)
- [Podman Installation Instructions](https://podman.io/getting-started/installation.html)
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
