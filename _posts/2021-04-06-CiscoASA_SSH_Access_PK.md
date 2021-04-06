---
layout: post
title: "Cisco ASA SSH access with Public Key"
description: "Configure access to Cisco ASA using SSH and public key authentication"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "Cisco ASA", "SSH", "public key", "ssh-keygen" ]
---

This document uses `~/keys/asaAccessKey` as the key used by `sshUser` to connect with SSH to Cisco ASA.

## Create a key pair

```sh
# create a key pair
ssh-keygen -t rsa -b 2048 -f ~/keys/asaAccessKey -C "sshUser@ASA"
# and print the base64-encoded public key
cat ~/keys/asaAccessKey.pub | cut -d ' ' -f 2
```

## Configure ASA

Here follows the procedure to configure SSH access to ASA using public key authentication.

```text
! create a RSA key and save it
crypto key generate rsa modulus 2048
write memory

! enable local authentication for SSH
aaa authentication ssh console LOCAL

! create an *all privileges* user for SSH access
username sshUser password password_for_sshUser privilege 15
username sshUser attributes
ssh authentication publickey base64-encoded-public-key
exit

! allow SSH from specified IPs and interfaces
ssh 192.168.1.0 255.255.255.0 inside

! set some parameters
ssh timeout minutes_default_is_5
ssh version 2
ssh key-exchange group dh-group14-sha1
```

**Warning:** do not use `nopassword` when creating a user ! `nopassword` means login with empty password.

If the base64-encoded public key is too long, the command `ssh authentication publickey base64-encoded-public-key` will fail. You can use the command `ssh authentication pkf` instead, but first you must convert the key.

Use `ssh-keygen -e -f ~/keys/asaAccessKey.pub` to obtain the public key in the format defined by RFC4716.

## SSH Config records

Add the key to the config records for your hosts. For more information see [SSH Config File]({% post_url 2021-01-26-SSH_Config %}) post.
