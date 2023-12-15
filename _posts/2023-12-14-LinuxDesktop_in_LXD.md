---
layout: post
title: "Linux Desktop images in LXD"
description: "Use Linux Desktop virtual machine images in LXD"
#image: /assets/img/.png
# date-modified: 2023-10-03
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "LXD", "Linux Desktop" ]
---

## Linux Desktop Images

List all the `desktop` amd64 virtual machines in [images remote server](https://images.linuxcontainers.org):

```sh
lxc image list images: type=virtual-machine architecture=x86_64 --columns=lLfFpdasut desktop
```

- `archlinux/desktop-gnome` Archlinux current
- `opensuse/15.4/desktop-kde` Opensuse 15.4
- `opensuse/15.5/desktop-kde` Opensuse 15.5
- `opensuse/tumbleweed/desktop-kde` Opensuse tumbleweed
- `ubuntu/mantic/desktop` Ubuntu mantic
- `ubuntu/focal/desktop` Ubuntu focal
- `ubuntu/jammy/desktop` Ubuntu jammy
- `ubuntu/lunar/desktop` Ubuntu lunar

Here are some commands related to remote servers:

```sh
# configured remote servers
lxc remote list
# get the default remote server
lxc remote get-default
# set 'ubuntu' as the new default remote server
lxc remote switch ubuntu

# list images in the default remote server
lxc image list
# list images in the 'ubuntu' remote server
lxc image list ubuntu:
# list virtual machines with x86_64 architecture in the 'images' remote server
lxc image list images: type=virtual-machine architecture=x86_64 --columns=lLfFpdasut
```

## Create a dedicated LXC profile

```sh
lxc profile create LinuxDesktop

lxc profile set LinuxDesktop limits.cpu=4
lxc profile set LinuxDesktop limits.memory=8GiB

lxc profile device add LinuxDesktop root disk \
    path=/ pool=default

lxc profile device add LinuxDesktop eth0 nic \
    name=eth0 network=lxdbr0

# if you want audio
lxc profile set LinuxDesktop raw.qemu='-device intel-hda -device hda-duplex'
```

## Launch a new image

```sh
lxc launch images:ubuntu/jammy/desktop UbuntuDesktop --vm --profile=LinuxDesktop --console=vga
```

After startup you may want to:

```sh
# update the system
sudo apt update && sudo apt -y upgrade

# install the openssh server and add a public key for remote access
ssh_key='ssh-ed25519 AAAA...'
sudo apt install openssh-server
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$ssh_key" > ~/.ssh/authorized_keys

# for audio support
sudo apt install "linux-modules-extra-$(uname -r)"
reboot
```

To connect to vm's console use:

```sh
lxc console UbuntuDesktop --type=vga
```

## Templating

If you want to make a template out of the modified virtual machine you should generalize it, at least:

- empty the `machine-id` file
- delete host keys
- empty log files
- remove unneeded packages and clean the local apt repository

When is stopped publish an image to you local image repository:

```sh
lxc publish UbuntuDesktop --public --alias=UbuntuDesktop_Base
```

**Note:** An example script for simple generalization of a virtual machine or container is [generalize_simple.sh](https://github.com/CalinRadoni/Scripts/blob/main/Bash/generalize_simple.sh)

## Links

- [How to add sound to an Ubuntu LXD VM](https://discuss.linuxcontainers.org/t/how-to-add-sound-to-an-ubuntu-lxd-vm/14372/)
- [Man page for lxc](https://documentation.ubuntu.com/lxd/en/latest/reference/manpages/lxc)
