---
layout: post
title: "CheckPoint SSH access with Public Key"
description: "Configure access to CheckPoint appliances (R80 and R81) using SSH and public key authentication"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "CheckPoint", "SSH", "public key", "RSA", "ed25519", "ssh-keygen" ]
---

**Contents:**

- [Supported algorithms](#supported-algorithms)
- [Configure algorithms](#configure-algorithms)
- [SSH authentication with RSA key, Gaia Embedded since R77.20](#ssh-authentication-with-rsa-key-gaia-embedded-since-r7720)
- [SSH authentication with RSA key, Gaia since R77.20](#ssh-authentication-with-rsa-key-gaia-since-r7720)
- [SSH authentication with ed25519 key, Gaia since R80.40](#ssh-authentication-with-ed25519-key-gaia-since-r8040)
- [SSH Config records](#ssh-config-records)
- [PuTTY](#putty)

The information here is compiled from `sk106836`, `sk95890`, `sk167199`, `sk162794`, `sk106031` and `sk179517` and tested on Gaia Embedded R80.20.40 and Gaia R81.10.

**Note:** This document uses `~/keys` as the directory that holds your keys. Name your keys accordingly, `ckpRSAAccessKey` is just an example.

## Supported algorithms

For R80 and R81, to find supported ciphers and HMACs use:

```sh
dbclient -c help
dbclient -m help
```

On R80.20 SMBs supported ciphers and HMACs are:

```txt
Available ciphers: aes128-ctr,aes256-ctr,aes128-cbc,aes256-cbc
Available MACs: hmac-sha1,hmac-sha2-256,hmac-sha2-512
```

At least since R80.20.40 you can use `ssh -Q` commands:

```sh
[Expert@...]# ssh -Q cipher
# ...
aes256-gcm@openssh.com
chacha20-poly1305@openssh.com

[Expert@...]# ssh -Q mac
# ...
hmac-sha2-256-etm@openssh.com
hmac-sha2-512-etm@openssh.com

[Expert@...]# ssh -Q key
ssh-ed25519
sk-ssh-ed25519@openssh.com
ssh-rsa
# ...

[Expert@...]# ssh -Q kex
# ...
curve25519-sha256
curve25519-sha256@libssh.org 
```

## Configure algorithms

**Note:** Gaia Embedded on SMB does not allow to change the supported list of cryptographic algorithms. The weak ciphers
cannot be disabled (see `sk162794`).

From R80.20 (see `sk106031`):

- edit `/etc/ssh/ssh_config`
- edit `/etc/ssh/ssh_config`
- restart the SSH server with `service sshd restart`

From R80.40 jumbo 83 (see `sk106031` and `sk179517`):

- edit `/etc/ssh/templates/sshd_config.templ`
- run `run /bin/sshd_template_xlate < /config/active`
- restart the SSH server with `service sshd restart`

From R81.10 you can also use in Clish (see `sk179517`):

- `show ssh server ...`
- `set ssh server ...`

## Copy a key to an appliance

You can change the content of the file on the appliance but **if you use a user with the Bash shell** this should work:

```sh
cat ~/keys/ckpRSAAccessKey.pub | ssh user@IP_Address_of_CheckPoint -T "cat >> /storage/test_file"
```

## SSH authentication with RSA key, Gaia Embedded since R77.20

Create a RSA key pair on a Linux host or on the Management server:

```sh
mkdir -p ~/keys
ssh-keygen -t rsa -b 4096 -f ~/keys/ckpRSAAccessKey -C ""
```

Copy the content of the `ckpRSAAccessKey.pub` to the appliance's `/storage/authorized_keys` file.
Create the file `/storage/authorized_keys` if it does not exists.

Edit `/pfrm2.0/bin/sshd` and add before the line:

```sh
start_cpwd.sh
```

these commands:

```sh
chown root /
mkdir -p /.ssh
chmod 600 /storage/authorized_keys
ln -sf /storage/authorized_keys /.ssh/authorized_keys
```

Restart the SSH service with:

```sh
killall dropbear ; sshd
# or
nohup sh -c 'killall dropbear && sshd'
```

## SSH authentication with RSA key, Gaia since R77.20

Create a RSA key pair **on a Linux host** or on the Management server:

```sh
mkdir -p ~/keys
# use this until R80.40
ssh-keygen -t rsa -b 4096 -f ~/keys/ckpRSAAccessKey -C ""
# use this since R80.40
ssh-keygen -t rsa -b 4192 -f ~/keys/ckpRSAAccessKey -C ""
```

Connect **to the appliance** *as the user for which you want to add the key* then create or check the required files and directories:

```sh
mkdir -p ~/.ssh
chmod u=rwx,g=,o=  ~/.ssh
touch ~/.ssh/authorized_keys
touch ~/.ssh/authorized_keys2
chmod u=rw,g=,o=  ~/.ssh/authorized_keys
chmod u=rw,g=,o=  ~/.ssh/authorized_keys2
```

Add the content of the public key file `~/keys/ckpRSAAccessKey.pub` to both the `~/.ssh/authorized_keys`
and the `~/.ssh/authorized_keys2` files.

Use another shell to test the authentication with the key:

```sh
ssh -i ~/keys/ckpRSAAccessKey IP_Address_of_CheckPoint
```

## SSH authentication with ed25519 key, Gaia since R80.40

This section differs from the previous only in the key creation process:

```sh
# create a ed25519 key pair
ssh-keygen -t ed25519 -f ~/keys/ckpAccessKey -C ""
```

## SSH Config records

Add the key to the config records for your hosts. For more information see [SSH Config File]({% post_url 2021-01-26-SSH_Config %}) post.

## PuTTY

For PuTTY on Windows see `sk98774` *Configure PuTTY to use RSA Authentication when connecting to Gaia OS machine*.
