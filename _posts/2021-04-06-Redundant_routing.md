---
layout: post
title: "Redundant routing"
description: "Some simple VRRP and HSRP redundant routing examples"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "VRRP", "HSRP", "Redundant routing" ]
---

Examples are for two Layer 3 switches configured for redundant routing.
Assuming:

- `vlan12` with associated IPv4 network address of `192.168.7.0/24`
- the IPv4 address of switch 1 in `vlan12` is `192.168.7.2`
- the IPv4 address of switch 2 in `vlan12` is `192.168.7.3`
- the IPv4 address of the redundant router is `192.168.7.1`

here follows the examples:

## Allied Telesys - VRRP protocol

For the first Layer 3 switch:

```text
interface vlan12
  ip address 192.168.7.2/24
router vrrp 12 vlan12
  virtual-ip 192.168.7.1 backup
  priority 250
  enable
```

and for the second Layer 3 switch:

```text
interface vlan12
  ip address 192.168.7.3/24
router vrrp 12 vlan12
  virtual-ip 192.168.7.1 backup
  priority 200
  enable
```

## Cisco - HSRP protocol

For the first Layer 3 switch:

```text
interface Vlan12
  ip address 192.168.7.2 255.255.255.0
  standby 12 ip 192.168.7.1
  standby 12 priority 200
```

and for the second Layer 3 switch:

```text
interface Vlan12
  ip address 192.168.7.3 255.255.255.0
  standby 12 ip 192.168.7.1
  standby 12 priority 150
```

## Huawei - VRRP protocol

For the first Layer 3 switch:

```text
interface Vlanif12
  ip address 192.168.7.2 255.255.255.0
  vrrp vrid 12 virtual-ip 192.168.7.1
  vrrp vrid 12 priority 120
  vrrp vrid 12 preempt-mode timer delay 15
```

and for the second Layer 3 switch:

```text
interface Vlanif12
  ip address 192.168.7.3 255.255.255.0
  vrrp vrid 12 virtual-ip 192.168.7.1
  vrrp vrid 12 priority 110
```
