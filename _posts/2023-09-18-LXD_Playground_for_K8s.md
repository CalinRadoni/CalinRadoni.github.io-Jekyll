---
layout: post
title: "LXD Playground for Kubernetes"
description: "Use LXD system containers to build a playground for Kubernetes"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "LXD", "Kubernetes", "cloud-init" ]
---

This article describes a way to build [LXD](https://ubuntu.com/lxd) system containers usable to create [Kubernetes](https://kubernetes.io/) servers and workers on a single host.

Using [cloud-init](https://cloudinit.readthedocs.io/en/latest/) allows for configuring users, IP addresses and SSH keys for those containers.

There will be another article with a practical, scripted way to do all these but is important to understand the main steps.

Here are the steps:

- [Create a project](#create-a-project)
- [Create a dedicate network](#create-a-dedicated-network)
- [Add a root disk and a network interface to default profile](#add-a-root-disk-and-a-network-interface)
- [Add the common cloud-init configuration to default profile](#add-the-common-cloud-init-configuration)
- [Create profiles to set static IP addresses to containers using cloud-init](#profiles-to-set-static-ip-addresses-using-cloud-init)
- [Create the containers](#create-the-containers)

## Create a project

```sh
lxc project create "K8sPlay" \
  -c features.images=false \
  -c features.profiles=true
```

## Create a dedicated network

```sh
lxc network create "K8sPlayNet" --type=bridge \
    ipv4.address="10.11.12.1/24" \
    ipv4.dhcp.ranges="10.11.12.64-10.11.12.127" \
    ipv4.nat=true \
    ipv6.address=none
```

## Add a root disk and a network interface

```sh
lxc profile device add default root disk \
    path=/ pool=default --project "K8sPlay"

lxc profile device add default eth0 nic \
    name=eth0 \
    network="K8sPlayNet" --project "K8sPlay"
```

## Add the common cloud-init configuration

```sh
cat << EOF | lxc profile set default --project "K8sPlay" cloud-init.user-data -
#cloud-config
package_upgrade: true
packages:
  - openssh-server
ssh_pwauth: false
users:
- name: default
  gecos: System administrator
  groups: adm,netdev,sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  lock_passwd: true
  ssh_authorized_keys:
  - "ssh-ed25519 AAAA___replace_this_with_ypur_public_key___"
EOF
```

## Profiles to set static IP addresses using cloud-init

```sh
for (( idx=0; idx<5; idx++ ))
do
    lxc profile create "ip$idx" --project "K8sPlay"

    cat << EOF | lxc profile set "ip$idx" --project "K8sPlay" cloud-init.network-config -
version: 1
config:
  - type: physical
    name: eth0
    subnets:
      - type: static
        ipv4: true
        address: "10.11.12.$(( 10 + idx ))"
        netmask: 255.255.255.0
        gateway: "10.11.12.1"
        control: auto
  - type: nameserver
    address: "10.11.12.1"
EOF
done
```

## Create the containers

```sh
for (( idx=0; idx<5; idx++ ))
do
    lxc launch ubuntu-minimal:22.04 "sc$idx" \
        --project "K8sPlay" \
        --profile default \
        --profile "ip$idx"
done
```
