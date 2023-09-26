---
layout: post
title: "LXD Playground for Kubernetes"
description: "Use LXD system containers to build a playground for Kubernetes"
#image: /assets/img/.png
date-modified: 2023-09-22
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "LXD", "Kubernetes", "k0s", "K3s", "cloud-init" ]
---

This article describes a way to build [LXD](https://ubuntu.com/lxd) system containers usable to create [Kubernetes](https://kubernetes.io/) servers and workers on a single host.

Using [cloud-init](https://cloudinit.readthedocs.io/en/latest/) allows for configuring users, IP addresses and SSH keys for those containers.

There will be another article with a practical, scripted way to do all these but is important to understand the main steps.

Here are the steps:

- [Create a project](#create-a-project)
- [Create a dedicate network](#create-a-dedicated-network)
- [Add devices](#add-devices)
- [Add the common cloud-init configuration to default profile](#add-the-common-cloud-init-configuration)
- [Create profiles to set static IP addresses to containers using cloud-init](#profiles-to-set-static-ip-addresses-using-cloud-init)
- [Create the containers](#create-the-containers)

For tests and troubleshooting I have used the [k0s](https://k0sproject.io/) and [K3s](https://k3s.io/) lightweight Kubernetes distributions.

Also, check the [Notes](#notes) and [Info and links](#info-and-links) sections.

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

## Add devices

```sh
# the root disk
lxc profile device add default root disk \
    path=/ pool=default --project "K8sPlay"

# a network interface
lxc profile device add default eth0 nic \
    name=eth0 \
    network="K8sPlayNet" --project "K8sPlay"

# /dev/kmsg is needed for Kubelet from K8s and derivatives
lxc profile device add default kmsg unix-char \
    source="/dev/kmsg" path="/dev/kmsg" --project "K8sPlay"
```

## Add the common cloud-init configuration

```sh
# br_netfilter is needed by K8s network components
lxc profile set default --project "K8sPlay" linux.kernel_modules=br_netfilter

# for K8s the containers must be privileged
lxc profile set default --project "K8sPlay" security.privileged true

# drop the security, the containers need more rights then usual
cat << EOF | lxc profile set default --project "K8sPlay" raw.lxc -
lxc.apparmor.profile = unconfined
lxc.cgroup.devices.allow = a
lxc.cap.drop =
lxc.mount.auto = cgroup:mixed proc:rw sys:mixed
lxc.mount.entry = /dev/kmsg dev/kmsg none defaults,bind,create=file
EOF

# these are basic, "standard", settings
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

## Notes

### /dev/kmsg

The whole `/dev/kmsg` trouble may be avoided by creating a link 
to `/dev/console`:

```sh
[[ -e /dev/kmsg ]] || ln -s /dev/console /dev/kmsg
```

preferably with `cloud-init`.

### lxc.mount.auto

I've made a test with this setting and worked:

```sh
lxc.mount.auto = cgroup:mixed proc:rw sys:mixed
```

## Info and links

Of course, [LXD documentation](https://documentation.ubuntu.com/lxd/en/latest/) should be bookmarked.

I have sorted most of the settings and steps needed after many hours and tests ... wish I have found, and read, these sooner:

- [Kubernetes in a Linux Container](https://www.thedroneely.com/posts/kubernetes-in-a-linux-container/)
- [Rancher K3s: Kubernetes on Proxmox Containers](https://betterprogramming.pub/rancher-k3s-kubernetes-on-proxmox-containers-2228100e2d13)
