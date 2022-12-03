---
layout: post
title: "Shared directory for Kali Linux on VMware Workstation"
description: "Shared directory for Kali Linux on VMware Workstation"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Kali", "VMware", "Shared directory"]
---

This post shows how to always share a directory from the VMware host with a Kali Linux guest.
The sharing can be temporary, check the sharing options in the settings window.

## VMware preparation

Select the virtual machine and click the `Edit virtual machine settings`.

In the `Virtual Machine Settings` window select the `Options` tab then the `Shared Folders` setting.

Select `Always enabled` for `Folder Sharing` and click `Add...` to add shared directory:

- **Name:** `host` *(you can use another name)*
- **Host Path:** the path to host's directory
- **Attributes:** check `Enabled`

Click the `Save` button and start the virtual machine.

## Kali virtual machine

```sh
sudo mkdir -p /mnt/shared

cat << 'EOF' | sudo tee -a /etc/fstab > /dev/null
vmhgfs-fuse /mnt/shared fuse defaults,allow_other 0 0
EOF

sudo systemctl daemon-reload
sudo mount /mnt/shared
ls -l /mnt/shared/host
```
