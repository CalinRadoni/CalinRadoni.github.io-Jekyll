---
layout: post
title: "Manage CheckPoint users using Clish"
description: "Create and modify CheckPoint (appliances with R80 and R81) users using Clish"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "CheckPoint", "password", "clish", "hash", "openssl" ]
---

**Contents:**

- [About password hashes](#about-password-hashes)
  - [R80 password hashes](#r80-password-hashes)
  - [R81 password hashes](#r81-password-hashes)
- [Change the administrative accounts R80](#change-the-administrative-accounts-r80)
- [Change the administrative accounts R81](#change-the-administrative-accounts-r81)
- [Restrict remote access](#restrict-remote-access)

These steps are extracted from:

- [Quantum Spark 1500, 1600 and 1800 Appliance Series R80.20.40 CLI Reference Guide](https://sc1.checkpoint.com/documents/SMB_R80.20.40/CLI/Default.htm)
- [CLI R81.10 Reference Guide](https://sc1.checkpoint.com/documents/R81.10/WebAdminGuides/EN/CP_R81.10_CLI_ReferenceGuide/Topics-CLIG/Introduction.htm)
- [Gaia R81.10 Administration Guide](https://sc1.checkpoint.com/documents/R81.10/WebAdminGuides/EN/CP_R81.10_Gaia_AdminGuide/Default.htm)

**Warning:** After adding a new account for SSH access you should enable the authentication with public keys. See the [CheckPoint SSH access with Public Key]({% post_url 2022-11-22-CheckPoint_SSH_Access_PK %}) post.

**Note:** This document uses:

- `the_new_admin` as the name of a new administrator.
- `$1$xyz.....` as a MD5 password hash
- `$6$xyz.....` as a SHA512 password hash

## About password hashes

These are salted and hashed passwords. To check if they match between CheckPoint and a *standard* Linux distribution, using the salt
`abc` and the password `abcd` I've got the hash `$1$abc$DxacYc10lOCxhylQ4UV6q0` with all these commands:

```sh
# from a Linux host
openssl passwd -salt abc -1 abcd
# from R80.20.40 Clish (Expert mode)
cryptpw --salt abc abcd
cryptpw --salt abc -m md5 abcd
cpopenssl passwd -salt abc -1 abcd
```

For R81 SHA512 salted hashes I've used:

```sh
# R81 Clish
cpopenssl passwd -6 -salt abcd your_password
# from a Linux host
openssl passwd -6 -salt abcd your_password
```

### R80 password hashes

Generate a password hash with:

```sh
# form Clish
cryptpw -m md5 your_password
# or
cpopenssl passwd -1 your_password

# from a Linux host
openssl passwd -1 your_password
```

### R81 password hashes

In R81 use:

```sh
# to see the configured hashing algorithm
show password-controls password-hash-type

# to change the hashing algorithm to SHA512
set password-controls password-hash-type SHA512
```

Generate a password hash with:

```sh
# form Clish
cpopenssl passwd -6 your_password

# from a Linux host
openssl passwd -6 your_password
```

## Change the administrative accounts R80

Add a new administrator:

```sh
add administrator username the_new_admin permission read-write password-hash '$1$abc.....'
```

Test that you are able to connect with the new account.

If you want to login directly to expert mode, *actually to switch to the Bash shell*:

- login as the new user
- execute `expert` command to go into expert mode
- execute `bashUser on` command

and your shell will be changed to `/bin/bash`.

`bashUser off` will restore the default shell to `clish`.

To change the password of the `admin` account and the password for `expert` mode use:

```sh
set administrator username admin permission read-write password-hash '$1$def.....'
set expert password-hash '$1$ghi.....'
```

## Change the administrative accounts R81

Add a new administrator:

```sh
add user the_new_admin uid 0 homedir /home/the_new_admin
set user the_new_admin password-hash '$6$abc......'

add rba user the_new_admin roles adminRole
add rba user the_new_admin access-mechanisms CLI,Web-UI,Gaia-API

# (optional) set the shell to Bash
set user the_new_admin shell /bin/bash
```

Test that you are able to connect with the new account.

To change the password of the `admin` account and the password for `expert` mode use:

```sh
set user admin password-hash '$6$def......'
set expert-password-hash '$6$ghi......'
```

Test that you are able to connect with the `admin` account and that you can switch to `expert` mode.

Remember to **save the configuration** with:

```sh
save config
```

## Restrict remote access

### Restrict remote access R80

Restrict the administrative access to the gateway with:

```sh
# show the actual access rules based on IP address
show admin-access-ip-addresses

# add a new IPv4 address 
add admin-access-ipv4-address single-ipv4-address 192.168.22.33
# add a new IPv4 network 
add admin-access-ipv4-address network-ipv4-address 192.168.22.0 subnet-mask 255.255.255.0
# or
add admin-access-ipv4-address network-ipv4-address 192.168.22.0 mask-length 24
```

### Restrict access R81

```sh
# show the actual allowed clients
show allowed-client all

# allow any host
add allowed-client host any-host
# add a new IPv4 address 
add allowed-client host ipv4-address 192.168.22.33
# add a new IPv4 network 
add allowed-client network ipv4-address 192.168.22.0 mask-length 24
```
