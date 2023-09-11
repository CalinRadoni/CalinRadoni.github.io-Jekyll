---
layout: post
title: "Connect a Linux server using LACP to a switch"
description: "Create a LACP trunk on a switch and the Netplan configuration, including bridges and VLANS"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "LACP", "Netplan", "VLAN","Ubuntu", "Cisco" ]
---

This document creates a network configuration to connect a Ubuntu server with a LACP trunk to a switch.
The server should be accessible on a dedicated VLAN and there should be VLANs for containers and virtual machines.

The server's network configuration is done using [Netplan](https://netplan.io/) (*tested on Ubuntu 22.04 LTS but should work in newer versions too*).
The switch configuration is for a Cisco switch but other switches can be used.

## Ubuntu netplan configuration

The following netplan file creates:

- a LACP trunk with four physical interfaces
- three VLANs:
  - one for host access with a static IPv4 address
  - two to be used by containers and virtual machines
- two bridges to connect containers and virtual machines through VLANs

See the Notes section for some explanations.

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1: {}
    eno2:
      optional: true
    eno3:
      optional: true
    eno4: 
      optional: true
  bonds:
    lacpbond:
      interfaces: [eno1, eno2, eno3, eno4]
      parameters:
        mode: 802.3ad
        lacp-rate: fast
        mii-monitor-interval: 100
        transmit-hash-policy: layer2
  vlans:
    vlanHost:
      id: 40
      link: lacpbond
      accept-ra: false
      addresses: [192.168.10.7/24]
      routes:
        - to: default
          via: 192.168.10.1
      nameservers:
        addresses:
          - 192.168.10.1
          - 8.8.8.8
        search: []
    vlan20:
      id: 20
      link: lacpbond
      accept-ra: false
    vlan21:
      id: 21
      link: lacpbond
      accept-ra: false
  bridges:
    net20:
      interfaces: [vlan20]
    net21:
      interfaces: [vlan21]
```

## Example configuration for a Cisco switch

I have used these commands to set a compatible LACP trunk on a Cisco switch:

```cisco_ios
enable
configure terminal

port-channel load-balance src-dst-mac

default interface range GigabitEthernet0/5-8

interface range GigabitEthernet0/5-8
channel-group 3 mode active
exit

interface Port-channel 3
switchport trunk encapsulation dot1q
switchport mode trunk
switchport trunk native vlan 3333
switchport trunk allowed vlan 40,20,21
end
```

### Troubleshooting commands for Cisco LACP

```cisco_ios
debug lacp all
no debug lacp all
show etherchannel summary
show lacp 3 counters
show lacp 3 neighbor
show lacp 3 internal
```

## Notes

### LACP rate

Use `lacp-rate: slow` if the switch does not support `fast` LACP rate.

### transmit-hash-policy

In this document I used the *default* `layer2` load balancing but another method may be faster, depending on the workload.

`transmit-hash-policy` must be set according to the load balancing method configured on the switch. For more information see:

- `xmit_hash_policy` in [Linux Ethernet Bonding Driver HOWTO](https://docs.kernel.org/networking/bonding.html) abot `transmit-hash-policy`
- [EtherChannel Load Balancing Explanation & Configuration](https://study-ccnp.com/etherchannel-load-balancing-explanation-configuration/) for Cisco related load balancing
