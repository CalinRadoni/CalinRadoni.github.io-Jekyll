---
layout: post
title: "Virtualized Kali Linux"
description: "Install a virtualized Kali Linux and initialize GVM (OpenVAS) and Metasploit"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Kali", "VMware", "Hyper-V", "GVM", "Metasploit", "OpenVAS", "Systemd" ]
---

This guide show the installation of Kali in Hyper-V or VMware and the initialization steps needed for GVM and Metasploit.<!--more-->

- [Get and verify the ISO](#get-and-verify-the-iso)
- [Hyper-V hypervisor](#hyper-v-hypervisor)
- [VMware hypervisor](#vmware-hypervisor)
- [Kali installation](#kali-installation)
- [Basic settings and GVM](#basic-settings-and-gvm)
- [About GVM](#about-gvm)
- [Metasploit](#metasploit)
- [System update](#system-update)
- [(optional) Enable automatic start for GVM](#optional-enable-automatic-start-for-gvm)

## Get and verify the ISO

Go to [https://cdimage.kali.org/current/](https://cdimage.kali.org/current/) and download:

- `kali-linux-2022.4-installer-amd64.iso` (the name will change with each release)
- SHA256SUMS
- SHA256SUMS.gpg

Run the next commands and after `gpg --verify ...` make sure that:

- it returned `Good signature`
- the `Primary key fingerprint` is the same as the fingerprint returned by `gpg --fingerprint ...`

```sh
# download and import the Kali Linux official key
wget -q -O - https://archive.kali.org/archive-key.asc | gpg --import
# gpg: key ED444FF07D8D0BF6: public key "Kali Linux Repository <devel@kali.org>" [...]

# verify that the key is properly installed
gpg --fingerprint 44C6513A8E4FB3D30875F758ED444FF07D8D0BF6
# pub   rsa4096 2012-03-05 [SC] [expires: 2025-01-24]
#       44C6 513A 8E4F B3D3 0875  F758 ED44 4FF0 7D8D 0BF6
# uid           [ unknown] Kali Linux Repository <devel@kali.org>
# sub   rsa4096 2012-03-05 [E] [expires: 2025-01-24]

# verify the signature
gpg --verify SHA256SUMS.gpg SHA256SUMS
# gpg: Signature made Mi 07 dec 2022 04:07:48 +0200 EET
# gpg:                using RSA key 44C6513A8E4FB3D30875F758ED444FF07D8D0BF6
# gpg: Good signature from "Kali Linux Repository <devel@kali.org>" [unknown]
# gpg: WARNING: This key is not certified with a trusted signature!
# gpg:          There is no indication that the signature belongs to the owner.
# Primary key fingerprint: 44C6 513A 8E4F B3D3 0875  F758 ED44 4FF0 7D8D 0BF6

# compute the SHA256 checksum for the downloaded ISO
grep kali-linux-2022.4-installer-amd64.iso SHA256SUMS | sha256sum -c
# kali-linux-2022.4-installer-amd64.iso: OK
# [...]
```

If you've got `kali-linux-2022.4-installer-amd64.iso: OK` then the image is successfully authenticated and can be used *safely*.

## Hyper-V hypervisor

Copy the downloaded and verified ISO to Hyper-V hypervisor host.

Create a virtual machine:

- Name:  `KaliVM`
- Generation 2
- Startup memory: 4096 MB
- connected to Internet
- Create a virtual hard disk, size 80 GB
- Install an operating system from a bootable image file: select the ISO

then:

- disable Secure Boot
- select 4 virtual processors
- start the virtual machine

## VMware hypervisor

Copy the downloaded and verified ISO to VMware's datastore.

Create a new virtual machine and select for compatibility the version of your hypervisor:

- Name: `KaliVM`
- Compatibility: `ESXi 7`
- Guest OS family: `Linux`
- Guest OS version: `Debian GNU/Linux 10 (64-bit)`

for Virtual Hardware select:

- 4 CPU (2 cores x 2 sockets)
- Memory 4096 MB
- Hard disk 1 80 GB
- CD/DVD Drive 1: select `Datastore ISO file` then select the Kali Linux install ISO

Start the virtual machine.

## Kali installation

Use `Graphical Install` and:

- Select the language (`English`), country, Locales (`Unites States, en_US.UTF-8`) and Keyboard (`American English`)
- Hostname: `KaliVM`
- Domain name: *empty*
- Full name for the new user: `Kali`
- Username for your account: `kali`
- Password: *use_a_proper_password*
- Partition disks: `Guided - use entire disk, all files in one partition`
- Software selection: *default selection*
  - Desktop environment
  - Xfce (Kali's default desktop environment)
  - Collection of tools
  - ... top10 -- the 10 most popular tools
  - ... default -- recommended tools
- Install the GRUB boot loader to the primary drive (/dev/sda)

## Basic settings and GVM

Go to *Start* / `Settings` / `Advanced Network Configuration` to set:

- IP address, mask and the gateway
- the DNS servers

the disconnect and reconnect the network.

Enable and start `SSH`:

```sh
sudo systemctl start ssh.service
sudo systemctl enable ssh.service
```

Update the system and install some tools, make sure your replace:

- *use_a_proper_password*
- *your_IP_address*

```sh
# update the system
sudo apt update && sudo apt -y upgrade
sudo apt update && sudo apt -y full-upgrade
sudo apt -y autoremove
sudo apt -y autoclean

# install some tools
sudo apt install -y kali-tools-vulnerability nsis

# postgresql service is required
sudo systemctl enable postgresql.service

# this command will take a long time to complete
sudo gvm-setup

# if you enter the commands *manually* keep the leading
# space to prevent the command to be stored in Bash history
  sudo runuser -u _gvm -- gvmd --user=admin --new-password=use_a_proper_password

# enable the redis service for openvas
sudo systemctl enable redis-server@openvas.service

# change GVM's HTTP Server configuration to be accessible from the network
sudo sed -i 's/127\.0\.0\.1/your_IP_address/g' /lib/systemd/system/gsad.service
sudo systemctl daemon-reload

# verify that the GVM was setup correctly
sudo gvm-check-setup
```

## About GVM

After the configuration step GVM is installed and started. It's web interface can be accessed at [https://your_IP_address:9392/](https://your_IP_address:9392/)

`Scan Configs` **should be available** once are loaded into the database. `Administration -> Feed Status` should show `Current` and not `Update in progress...`

Use `sudo gvm-stop` and `sudo gvm-start` to restart GVM.

Manually initiate a feed update with `sudo gvm-feed-update`

### Quick Start

**1** go to `Configuration / Targets` and create a new target:

- Name: Net 1
- Hosts: 192.168.1.1-254
- leave other settings default

**2** go to `Scan / Tasks` and create a new task:

- Name: Scan net 1
- Scan Targets: Net 1
- leave other settings default

**3** In the tasks window click the `Start` button under `Actions`

## Metasploit

In the [Metasploit Basics]({% post_url 2022-11-19-Metasploit_Basics %}) post I have a quick start documentation for Metasploit, *From the first start to a reverse shell on a vulnerable host*.

You can also check [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/) and the [official documentation](https://docs.rapid7.com/metasploit/) for information on using the Metasploit Framework.

For a target to practice Metasploit Usage framework use [Metasploitable 2 from SourceForge](http://sourceforge.net/projects/metasploitable/files/Metasploitable2/). The default login and password is `msfadmin:msfadmin` and here is a [Metasploitable 2 Exploitability Guide](https://community.rapid7.com/docs/DOC-1875) on the Rapid7 website.

Before running Metasploit Framework's tools the database should be created and initialized:

```sh
sudo msfdb init
```

Launch `msfconsole` and verify database connectivity with `db_status` then `exit` the console.

```txt
$ msfconsole -q
msf6 > db_status
[*] Connected to msf. Connection type: postgresql.
msf6 > exit
```

## System update

Update GVM's feed and Kali as any other Debian / Ubuntu distribution:

```sh
sudo gvm-feed-update

sudo apt update && sudo apt -y upgrade && \
    ([[ -f /var/run/reboot-required ]] && (echo; echo; cat /var/run/reboot-required))
```

### (optional) disable Kali's automatic check for updates

If you want to disable the automatic check for updates:

```sh
for timer in apt-daily.timer apt-daily-upgrade.timer; do
    sudo systemctl stop $timer
    sudo systemctl disable $timer
    sudo systemctl status $timer
done
```

If you disable the automatic check for updates, make sure you to manually check for updates at least weekly.

## (optional) Enable automatic start for GVM

I have used a `Systemd` service and a script to enable automatic start of GVM's services when the system boots.

Create a script with this content and run it:

```sh
#!/bin/bash

startupScript='/etc/systemd/system/start_gvm_services'
startupService='/etc/systemd/system/start_gvm.service'

cat << 'EOF' | sudo tee "$startupScript" > /dev/null
#!/bin/bash

# start services ...
systemctl start notus-scanner gvmd ospd-openvas
# ... wait a little ...
sleep 5s
# ... then start gsa
systemctl start gsad
EOF

sudo chown root:root "$startupScript"
sudo chmod 744 "$startupScript"

cat << EOF | sudo tee "$startupService" > /dev/null
[Unit]
Description=Start GVM services
After=network.target networking.service postgresql.service redis-server@openvas.service

[Service]
ExecStart=$startupScript

[Install]
WantedBy=multi-user.target
EOF

sudo chown root:root "$startupService"
sudo chmod 644 "$startupService"

sudo systemctl enable "$startupService"
```

Check the status of services with:

```sh
systemctl --no-pager -l status gsad gvmd ospd-openvas
```
