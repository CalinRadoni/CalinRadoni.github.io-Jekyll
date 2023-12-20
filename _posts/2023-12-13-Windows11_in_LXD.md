---
layout: post
title: "Install Windows 11 in LXD"
description: "Install Windows 11 as a LXD virtual machine"
#image: /assets/img/.png
date-modified: 2023-12-20
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "LXD", "Windows 11" ]
---

Install Windows 11 as a LXD virtual machine using a dedicated LXD profile and updated virtio drivers. At the end of this article is some information about templating.

## Tools

These are the tools needed if you use Ubuntu 22.04 LTS:

```sh
sudo snap install distrobuilder --classic
sudo apt -y install libwin-hivex-perl wimtools genisoimage virt-viewer
```

**Note:** `remote-viewer` (added by `virt-viewer`) is the recommended Spice client. See the [Spice User Manual](https://www.spice-space.org/spice-user-manual.html) for more information.

## Installation image

Go to Microsoft's page to [Download Windows 11](https://www.microsoft.com/software-download/windows11) and download the `Windows 11 Disk Image (ISO) for x64 devices`.

On the same page, after selecting the language, you should find the SHA256 of the iso.

On directory where you have the ISO create a hash result file. For `Windows 11 23H2 x64 English (United States)` edition:

```sh
echo '71A7AE6974866603D366A911B0C00EACE476E0B49D12205D7529765CC50B4B39 Win11_23H2_English_x64.iso' > Win11_23H2_English_x64.sha256
```

then check the hash of the downloaded image. The command:

```sh
sha256sum -c Win11_23H2_English_x64.sha256
```

should return `Win11_23H2_English_x64.iso: OK`

Prepare the ISO execute:

```sh
sudo distrobuilder repack-windows Win11_23H2_English_x64.iso win11.lxd.iso
```

## Create a dedicated LXC profile for Windows 11

```sh
lxc profile create win11

lxc profile set win11 limits.cpu=4
lxc profile set win11 limits.memory=8GiB

lxc profile device add win11 root disk \
    path=/ pool=default size=64GiB

lxc profile device add win11 eth0 nic \
    name=eth0 network=lxdbr0

lxc profile device add win11 vtpm tpm path=/dev/tpm0

# if you want audio
lxc profile set win11 raw.qemu='-device intel-hda -device hda-duplex'
```

## Install Windows 11

```sh
lxc init win11vm --vm --empty --profile=win11

lxc config device add win11vm \
    install_media disk source=/absolute_path_to_the_prepared_iso/win11.lxd.iso \
    boot.priority=9

lxc start win11vm --console=vga
```

To reconnect to vm's console use:

```sh
lxc console win11vm --type=vga
```

After Windows 11 is installed disconnect the install disk:

```sh
lxc config device remove win11vm install_media
```

## Virtio drivers

### Method 1

From [virtio-win / virtio-win-pkg-scripts](https://github.com/virtio-win/virtio-win-pkg-scripts) select the `virtio-win direct-downloads full archive` link, download `virtio-win-gt-x64.msi` and execute it.

### Method 2

If you are offline or the previous method does not work for some reason, use this method.

From [virtio-win / virtio-win-pkg-scripts](https://github.com/virtio-win/virtio-win-pkg-scripts) download the `Stable virtio-win ISO` and add it to the Windows 11 virtual machine:

```sh
lxc config device add win11vm virtio_win disk source=/absolute_path_to_the_iso/virtio-win-0.1.240.iso
```

then, in Windows 11 virtual machine, execute `virtio-win-gt-x64.msi`.

When done remove the `virtio-win` disk:

```sh
lxc config device remove win11vm virtio_win
```

## Templating

Make all the settings you want.

You can use [Sysprep](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview?view=windows-11) to generalize the Windows installation. There is more to be said about `Sysprep` but the simplest usage is:

```sh
Sysprep /generalize /shutdown
```

When the virtual machine is stopped you can create an image with:

```sh
lxc publish win11vm --public --alias=my_windows_11
```

## Links

- [How to install a Windows 11 VM using LXD](https://ubuntu.com/tutorials/how-to-install-a-windows-11-vm-using-lxd)
- [Man page for lxc](https://documentation.ubuntu.com/lxd/en/latest/reference/manpages/lxc)
- ... and too many others :(
