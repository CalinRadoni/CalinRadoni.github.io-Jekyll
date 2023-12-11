---
layout: post
title: "TCP proxy with nc"
description: "Quick and temporary TCP proxy with nc ... for when you need one"
#image: /assets/img/.png
# date-modified: 2023-12-11
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "TCP proxy", "nc", "RDP" ]
---

This procedure works for any TCP connection. It creates a named pipe and uses two `nc` instances to communicate through that pipe.

Here follows an example for RDP which uses the port 3389 TCP by default.
Let's say you want to make a RDP connection to `HostD` through `HostJ`.

In `HostJ` create a TCP proxy with `nc`:

```sh
mkfifo proxyz
nc -l -k -p 3389 < proxyz | nc __replace_with_IP_address_of_HostD__ 3389 > proxyz
```

Now any RDP connection to `HostJ` will go to `HostD`.

When done, stop the nc proxy with `Ctrl+C` and remove the named pipe:

```sh
rm proxyz
```

**Note:** You may have to enable incoming RDP connection in `HostJ` from `HostS`. If you use `nftables` edit `/etc/nftables.conf` and add a rule like:

```sh
ip saddr __replace_with_IP_address_of_HostS__ tcp dport 3389 ct state new accept
```

then apply the configuration with the `sudo nft -f /etc/nftables.conf` command. When done, remember to restore the firewall settings.
