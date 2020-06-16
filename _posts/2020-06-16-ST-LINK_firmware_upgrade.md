---
layout: post
title: "ST-LINK firmware upgrade"
description: "Upgrading the firmware of ST-LINK interfaces in Linux, Windows and macOS"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
categories: [ "System Administration" ]
tags: [ "ST-LINK" ]
---

To update the firmware of ST-LINK boards, ST offers three aplications:

- STM32CubeProgrammer
  ([STM32CubeProg](https://www.st.com/content/st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-programmers/stm32cubeprog.html))
  is an all-in-one multi-OS software tool for programming STM32 products.
- STM32 ST-LINK Utility
  ([STSW-LINK004](https://www.st.com/content/st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-programmers/stsw-link004.html))
  is a full-featured software interface for programming STM32 microcontrollers.
- [STSW-LINK007](https://www.st.com/content/st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-programmers/stsw-link007.html)
  is used to upgrade the firmware of the ST-LINK, ST-LINK/V2 and ST-LINK/V2-1 boards through the USB port.

I am using the dedicated one, [STSW-LINK007](https://www.st.com/en/development-tools/stsw-link007). These instructions
are dedicated to Linux but usage is similar in Windows and macOS. See `RN0093` (*link on the bottom of the document*) for details.

**I have to remember to myself:** *The [STM32Cube Ecosystem](https://www.st.com/content/st_com/en/stm32cube-ecosystem.html) is a complete software solution for STM32 microcontrollers and microprocessors. It is intended both for users looking for a complete and free development environment for STM32, as well as for users who already have an IDE, including Keil or iAR, in which they can easily integrate the various components such as STM32CubeMX, STM32CubeProgrammer or STM32CubeMonitor.*

## Libusb and permissions

It needs `libusb-1.0` so make sure is installed:

```sh
# for Ubuntu 20.04
sudo apt update && sudo apt -y install libusb-1.0-0

# for Debian / Ubuntu
sudo apt update && sudo apt -y install libusb-1.0
```

### USB permissions

This is a *quick-and-dirty* procedure. See [Non-root access for ST-LINK and USB-to-serial devices]({% post_url 2020-06-16-Non-root_access_USB %})
for better settings and more information.

Also, in the `AllPlatforms/StlinkRulesFilesForLinux` directory you can find, maybe, a simpler method. Start with the `readme.txt` file.

Libusb requires write access to USB device nodes. If you have not done it already, for non-root acces create the file `/etc/udev/rules.d/70-st-link.rules` with this content:

```sh
# ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", TAG+="uaccess"

# ST-LINK/V2-1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", TAG+="uaccess"
```

and reload all the udev rules:

```sh
sudo udevadm control --reload-rules
```

If the ST-LINK board was plugged, unplug it then plug it again.

## STLinkUpgrade

Download it, extract it and from the `AllPlatforms` directory, either:

- launch `STLinkUpgrade.jar`
- execute `java -jar STLinkUpgrade.jar`

`STLinkUpgrade` should have found the board, click `Refresh device list` if not.
Now click `Open in update mode` then click `upgrade`.

`STLinkUpgrade 3.3.4` upgraded my ST-LINK/V2 boards to V2J37S0 firmware version.

[RN0093 Firmware upgrade for ST-LINK, ST-LINK/V2, ST-LINK/V2-1 and STLINK‐V3 boards](https://www.st.com/resource/en/release_note/dm00107009-firmware-upgrade-for-stlink-stlinkv2-stlinkv21-and-stlinkv3-boards-stmicroelectronics.pdf) offers detailed information about the upgrade process.
