---
layout: post
title: "openfortivpn"
description: "openfortivpn is a client for PPP+SSL VPN tunnel services. It is compatible with Fortinet VPNs"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "openfortivpn", "FortiClient VPN", "Debian", "Ubuntu" ]
---

[openfortivpn](https://github.com/adrienverge/openfortivpn) is a client for PPP+SSL VPN tunnel services. It is compatible with Fortinet VPNs.

If you do not like the [FortiClient VPN](https://www.fortinet.com/support/product-downloads) or installing it is more like a PITA, in Debian 11 at least, `openfortivpn` is a great alternative.

## Installation

Installation is as simple as:

```sh
sudo apt install openfortivpn
```

## Certificates and keys

If the certificate is a [PKCS #12](https://en.wikipedia.org/wiki/PKCS_12) archive, as it should be, you can check it with:

```sh
openssl pkcs12 -info -in myVPNUserCertificate.p12 -nodes
```

To extract the private key and the certificate into files use:

```sh
# extract the private key
openssl pkcs12 -in myVPNUserCertificate.p12 -out vpn_user.key -nodes -nocerts

# extract the certificate
openssl pkcs12 -in myVPNUserCertificate.p12 -out vpn_user.crt -nokeys
```

**Warning:** the files should be kept as private as possible because those are not password protected !

## Configuration

You should have:

- the IP Address or the name of the VPN server (let's say `192.168.5.3`) and it's port (let's say `443`)
- a username (let's say `vpn_user`) and the password (let's say `vpn_pass`)

Create a configuration file in a **protected directory**, where you are keeping the `vpn_user.key` and `vpn_user.crt` files:

```ini
### config file for openfortivpn, see man openfortivpn(1) ###

host = 192.168.5.3
port = 443
username = vpn_user
password = vpn_pass
user-cert = vpn_user.crt
user-key = vpn_user.key
# trusted-cert = abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234
```

## Usage

```sh
sudo openfortivpn -c vpn_config
```

If the VPN gateway's certificate is not trusted you may get a message like:

```txt
ERROR:  Gateway certificate validation failed, and the certificate digest is not in the local whitelist. If you trust it, rerun with:
ERROR:      --trusted-cert abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234
ERROR:  or add this line to your config file:
ERROR:      trusted-cert = abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234
ERROR:  Gateway certificate:
ERROR:      subject:
ERROR:          CN=zzzzzzzzzzzzz
ERROR:      issuer:
ERROR:          C=zzzzzzzzzzzzz
ERROR:          ST=zzzzzzzzzzzzz
ERROR:          L=zzzzzzzzzzzzz
ERROR:          O=zzzzzzzzzzzzz
ERROR:          CN=zzzzzzzzzzzzz
ERROR:      sha256 digest:
ERROR:          abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234
[...]
```

so, *if you trust it*, edit the `vpn_config` file, uncomment the `trusted-cert =` line and put that certificate digest there.

If there are still errors remember to use the `-v` flag when connecting.
