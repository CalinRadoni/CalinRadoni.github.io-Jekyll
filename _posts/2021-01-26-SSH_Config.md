---
layout: post
title: "SSH Config File"
description: "SSH configuration file for the OpenSSH client"
#image: /assets/img/.png
#date-modified: 2021-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "SSH" ]
---

Remembering many IP addresses, user names, keys, ports and options may be possible, until is not :) A custom configuration file for the `ssh` program (the OpenSSH client) is a must.<!--more-->

The `ssh` program is configured with two files:

- `/etc/ssh/ssh_config` for global options
- `~/.ssh/config` for user-specific options

**The first obtained value for an option is used** and the options are read:

1. first from the command line
2. then from `~/.ssh/config`
3. and last from `/etc/ssh/ssh_config`

If `~/.ssh/config` does not exists, it can be created with:

```sh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

The config file is using *sections* for hosts. Each *section* starts with the `Host` directive.

The `Host` directive:

- can contain one pattern or a whitespace-separated list of patterns
- each pattern is matched against the host name given on the command line
- restricts the declarations that follows to be only for the hosts that match one of directive's patterns

A pattern can the following specifiers:

- `*` to match zero or more characters
- `?` to match one character
- `!` at the start of the pattern negates the match

Because the first obtained value for an option is used, the more host specific options should be first followed by the group specific and general ones.

Use `man ssh_config` to read about available options, or check one of many online sources like
[ssh_config(5) - Linux man page](https://linux.die.net/man/5/ssh_config) or
[SSH Config File](https://www.ssh.com/ssh/config/) .

The following demo `config` file covers some common usage cases:

```conf
# A rule for GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/keys/GitHub_key

# Rules for some servers that I am connecting directly to
Host ntpserver
    HostName 192.168.4.33

Host a_server
    HostName 192.168.4.28

Host another_server
    HostName 192.168.4.29

# There are servers that I have access only from other jumper/gateway/bastion hosts.
# Using a tunnel to JumperA or JumperB I can RDP to them by using local ports.
# `ssh -N JumperA` or `ssh -N JumperB` will open tunnels from local ports 9001 - 9003
# to the RDP port on those serves.
Host JumperA
    HostName 10.10.5.15
    LocalForward 9001 10.10.1.1:3389
    LocalForward 9002 10.10.1.2:3389
    LocalForward 9003 10.10.1.3:3389

Host JumperB
    HostName 10.10.5.16
    LocalForward 9001 10.10.1.1:3389
    LocalForward 9002 10.10.1.2:3389
    LocalForward 9003 10.10.1.3:3389

# Here are some access points
Host AP1
    HostName 192.168.3.1
Host AP2
    HostName 192.168.3.2
Host AP_garden
    HostName 192.168.3.3

# for AP1, AP2, AP_garden I am using the `admin` user and `ap_key`
Host AP*
    User admin
    IdentityFile ~/keys/ap_key

# These rules are for all targets.
# Here I am setting the default user name, my_user_name, and the default key, my_user_key
# for all connections
Host *
    User my_user_name
    IdentityFile ~/keys/my_user_key
    IdentitiesOnly yes
```
