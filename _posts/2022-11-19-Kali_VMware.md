---
layout: post
title: "Kali Linux on VMware Workstation"
description: "Install Kali Linux 2022 with GVM (openVAS), Metasploit and Nessus on VMWare Workstation Player"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Kali", "VMware", "GVM", "Metasploit", "Nessus", "OpenVAS" ]
---

This guide installs Kali Linux 2022 as a VMware virtual machine and makes the basic configurations needed to run GVM (previously named OpenVAS), Metasploit and Nessus.

## Download Kali Image

Download [Kali](https://www.kali.org/get-kali/) prebuilt virtual machine for VMware in the directory where you keep yor virtual machines and extract the image:

```sh
# make sure you have p7zip installed
sudo apt install -y p7zip-full
# extract the 7z archive
7z x kali-linux-2022.3-vmware-amd64.7z
# delete the downloaded and compressed image
rm -rf kali-linux-2022.3-vmware-amd64.7z
```

Start VMware Player, click on `Open a Virtual Machine` and select the `.vmx` file from the Kali's virtual machine directory.
Verify the settings and change them if needed before booting the virtual machine.

These are the changes I've made:

- set the memory to 4GB
- set the network to `Bridged`
- remove the CD/DVD

The images are build with `kali:kali` default credentials.

### Update

Update your new installation with:

```sh
# perform the standard upgrade procedure
sudo apt-get update && sudo apt-get -y upgrade

# remove PostgreSQL version 14 (obsoleted according to what a message in the previous step told)
sudo systemctl stop postgresql@14-main.service
sudo systemctl disable postgresql@14-main.service
sudo apt purge -y postgresql-14 postgresql-client-14

# distribution upgrade
sudo apt-get update && sudo apt-get -y dist-upgrade

# cleanup
sudo apt-get -y autoremove
sudo apt-get -y autoclean
```

Make sure `postgresql` is running on port 5432, check the file `/etc/postgresql/15/main/postgresql.conf` and change the port if it is not 5432.

### Metapackages

`kali-linux-everything` may be too much, there is a complete list of [Kali Linux Metapackages](https://www.kali.org/docs/general-use/metapackages/) but I have used only some of those :

- `kali-tools-vulnerability`: Vulnerability assessments tools
- `kali-tools-web`: Designed doing web applications attacks
- `kali-tools-database`: Based around any database attacks
- `kali-tools-wireless`: All tools based around Wireless protocols – 802.11, Bluetooth, RFID & SDR
- `kali-tools-exploitation`: Commonly used for doing exploitation
- `kali-tools-sniffing-spoofing`: Any tools meant for sniffing & spoofing
- `kali-tools-post-exploitation`: Techniques for post exploitation stage

To install them use:

```sh
sudo apt install -y kali-tools-vulnerability \
  kali-tools-web kali-tools-database kali-tools-wireless \
  kali-tools-exploitation kali-tools-sniffing-spoofing \
  kali-tools-post-exploitation
```

### Services

Some services are required by multiple tools. I have enabled these to start when the virtual machine boots:

```sh
sudo systemctl enable redis-server.service
sudo systemctl enable postgresql.service
```

Start them manually now and check their status, it should be `Active (running)`:

```sh
sudo systemctl start redis-server
sudo systemctl start postgresql

sudo systemctl status redis-server
sudo systemctl status postgresql@15-main.service
```

### Restart

Before configuring and installing other tools I have restarted the system.

## Greenbone Vulnerability Manager (previously named OpenVAS)

It is installed by the `kali-tools-vulnerability` metapackage or with:

```sh
sudo apt install -y --install-recommends gvm
```

Run the setup using the `sudo gvm-setup` command.

After a *very long time* the automatically generated password will be displayed. If you forget it or you want to change it, use:

```sh
# use a proper password if the machine is accessible from the network !
sudo runuser -u _gvm -- gvmd --user=admin --new-password=admin
```

Install `nsis` with `sudo apt install -y nsis`

Check the installation with `sudo gvm-check-setup` and solve all problems.
Most of the time `gvm-check-setup` will tell you what to do.

To solve the **warning:** *Your password policy is empty* I have only uncommented the line `!/^.{8,}$/` in `/etc/gvm/pwpolicy.conf` because this particular virtual machine is not a public accessible / production one anyway.

When there are no errors and warnings connect to the [web interface](https://127.0.0.1:9392) of GVM.

**Note:** GVM worked OK after a system restart. `gvm-stop` and `gvm-start` were not enough.

## Metasploit

Beside the [official documentation](https://docs.rapid7.com/metasploit/) you can also check [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/) for information on using the Metasploit Framework.

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

## Install Nessus in Kali VM

Check [Nessus 10.4.x User Guide](https://docs.tenable.com/nessus/Content/GettingStarted.htm) for usage.

### ... using a script

For Nessus 10.4.1 you can use this script to download, check and install it:

```sh
#!/bin/bash

curl --request GET \
  --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.4.1-debian9_amd64.deb' \
  --output 'Nessus-10.4.1-debian9_amd64.deb'

echo "0a3ce53067e9fbed2140c1b28aad83bde8e2b95f510903128666e3c649b59550 *Nessus-10.4.1-debian9_amd64.deb" \
  > Nessus-CHECKSUM
sha256sum -c Nessus-CHECKSUM || exit 1

sudo apt install -y ./Nessus-10.4.1-debian9_amd64.deb

rm -rf Nessus-10.4.1-debian9_amd64.deb
rm -rf Nessus-CHECKSUM
```

### ... or the manual way

Go to [Tenable Nessus Download page](https://www.tenable.com/downloads/nessus), select the last version and `Linux - Debian - amd64` platform and click the `Download` button.

Verify the checksum then install it with:

```sh
sudo apt install -y ./Nessus-10.4.1-debian9_amd64.deb
rm -rf Nessus-10.4.1-debian9_amd64.deb
```

### Configure Nessus

Start Nessus Scanner with `sudo systemctl start nessusd.service` then go to [https://localhost:8834/](https://localhost:8834/) or to [https://kali:8834/](https://kali:8834/) to configure it.

Configuration steps for `Nessus Essentials`:

- On the `Welcome to Nessus` screen, select `Nessus Essentials`
- On the `Get an activation code` screen, type your name and email address then click `Email`
- Check your email for your free activation code
- On the `Register Nessus` screen, type your Activation Code
- On the `Create a user account` screen create a Nessus administrator user account that you will use to log in to Nessus
