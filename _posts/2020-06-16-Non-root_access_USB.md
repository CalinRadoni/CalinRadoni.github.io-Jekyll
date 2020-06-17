---
layout: post
title: "Non-root access for ST-LINK and USB-to-serial devices"
description: "Using a user account to access ST-LINK programming interfaces, USB-to-serial converters and some other USB devices"
#image: /assets/img/.png
date-modified: 2020-06-17
categories: [ "System Administration" ]
tags: [ "udev", "ST-LINK", "USB-to-serial", "CP2102", "CP210x" ]
---

Accessing the ST-LINK programming interfaces, USB-to-serial converters and some other USB devices from a non-root account
requires the creation of dedicated `udev` rules to set access permissions.

Go straight to [Final config](#final-config) or read on for details.

## Step by step

When a USB device is plugged, executing `lsusb` should show it.
For the ST-LINK interface of a STM32F3 Discovery board:

```txt
Bus 001 Device 008: ID 0483:3748 STMicroelectronics ST-LINK/V2
```

and the device `/dev/bus/usb/001/080` will be created.

To give read and write access to non-root users the simplest way is to create a `.rules` file in `/etc/udev/rules.d/` 
with a udev rule like this:

```ini
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", TAG+="uaccess"
```

This rule will give access for the logged user to the USB device with `idVendor 0483` and `idProduct 3748`.

To be a little more restrictive let's make sure that we offer read and write access only for the logged user
and tie the rule to the USB subsystem:

```ini
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess"
```

**Note:** One can also add a group restriction like `GROUP="plugdev"` to permit the access only for the members of this group.

`/dev/bus/usb/001/xxx` is not a friendly name but we have the option to use a `SYMLINK`:

```ini
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"
```

will also create an alias for the device, `/dev/stlinkv2_8`. Better but far from perfect.

The device number (8 for this example) will change with each plugging of the device. If the device have a unique field
it can be used to create a clearly defined name. I have not found one for ST-LINK interfaces.

Read [USB-to-serial converters](#usb-to-serial-converters) for more information.

## ST-LINK interfaces

The following script creates the access rules for ST-LINK V2, V2.1 and V3:

```sh
#!/bin/bash

sudo tee /etc/udev/rules.d/70-st-link.rules > /dev/null <<'EOF'
# ST-LINK V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"

# ST-LINK V2.1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"

# ST-LINK V3
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3loader_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
EOF

sudo udevadm control --reload-rules
```

## USB-to-serial converters

Some USB-to-serial converters have a `serial` field. If is unique it can be use to name those clearly.

Example for:

- a generic USB-to-serial convertor with CP2102 USB to UART bridge **programmed** with serial 0099
- a generic USB-to-serial convertor with CP2102 USB to UART bridge **programmed** with serial 0100
- ESP32-DevKitC with CP2102 USB to UART bridge **programmed** with serial 0101

we can make the following rules:

```sh
# the blue USB-to-serial adapter
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="0099", MODE="600", TAG+="uaccess", SYMLINK+="u2s-blue"
# the black USB-to-serial adapter
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="0099", MODE="600", TAG+="uaccess", SYMLINK+="u2s-black"
# ESP32-DevKitC
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="0101", MODE="600", TAG+="uaccess", SYMLINK+="esp32-devkitc"
```

and the devices will be available also under the following aliases:

- /dev/u2s-blue
- /dev/us2-black
- /dev/esp32_devkit

Almost perfect **BUT** those CP201x are all programmed from factory with serial number 0001 ! However those can be reprogrammed.
I have not done it but if you need more information search for AN721 in [Silicon Labs's Technical Resource](https://www.silabs.com/support/resources.ct-application-notes.ct-example-code.p-interface).

## Final config

The following script creates access rules for ST-LINK V2, V2.1 and V3 and for some USB-to-serial converters:

```sh
#!/bin/bash

sudo tee /etc/udev/rules.d/70-st-link.rules > /dev/null <<'EOF'
# ST-LINK V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"

# ST-LINK V2.1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"

# ST-LINK V3
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3loader_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
EOF

sudo tee /etc/udev/rules.d/70-usb-to-serial.rules > /dev/null <<'EOF'
# CP2101 - CP 2104
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="600", TAG+="uaccess", SYMLINK+="usb2ser_%n"

# ATEN UC-232A
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0557", ATTRS{idProduct}=="2008", MODE="600", TAG+="uaccess", SYMLINK+="usb2ser_aten_%n"
EOF

sudo udevadm control --reload-rules
```
