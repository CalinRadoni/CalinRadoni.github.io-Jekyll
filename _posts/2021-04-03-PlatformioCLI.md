---
layout: post
title: "PlatformIO Core"
description: "Cross-platform, cross-architecture, multiple framework, professional tool for embedded systems engineers and for software developers who write applications for embedded products"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "PlatformIO", "ESP32", "Arduino" ]
---

PlatformIO is a cross-platform, cross-architecture, multiple framework, professional tool for embedded systems engineers and for software developers who write applications for embedded products.<!--more-->

## Installation

PlatformIO does not require administrative / elevated permissions.

```sh
#!/bin/bash

set -e

# download installation script
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o get-platformio.py

# install PlatformIO Core
python3 get-platformio.py

# add links to the executables
# ~/.local/bin/ is part of the systemd file system hierarchy and in the user's $PATH search path
ln -s ~/.platformio/penv/bin/platformio ~/.local/bin/platformio
ln -s ~/.platformio/penv/bin/pio ~/.local/bin/pio
ln -s ~/.platformio/penv/bin/piodebuggdb ~/.local/bin/piodebuggdb

# install udev rules for PlatformIO supported boards/devices
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control --reload-rules
```

**Note:** instead of installing udev rules for PlatformIO, you can use another approach and add only the rules you want, see the [Non-root access for ST-LINK and USB-to-serial devices]({% post_url 2020-06-16-Non-root_access_USB %}) article.

## Create a test project

```sh
#!/bin/bash

set -e

# create a directory for the new project
testDir=$(mktemp -d -t pio_test_XXXXX --tmpdir="$PWD")
cd "$testDir"

# initialize a new project
testBoard="esp32dev"
pio project init --board $testBoard
# ...
# Project has been successfully initialized! Useful commands:
# `pio run` - process/build project from the current directory
# `pio run --target upload` or `pio run -t upload` - upload firmware to a target
# `pio run --target clean` - clean project (remove compiled files)
# `pio run --help` - additional information

cat << 'EOF' > src/main.cpp
#include <Arduino.h>

void setup()
{
    Serial.begin(9600);
}

void loop()
{
    Serial.println("Hello world!");
    delay(1000);
}
EOF

pio run
pio run --silent --target clean
```

## pio commands

All the commands are in [CLI Guide](https://docs.platformio.org/en/latest/core/userguide/index.html).

- `pio platform list` Lists installed development platforms
- `pio platform install <platform>` Installs `<platform>`
- `pio platform uninstall <platform>` Uninstalls `<platform>`
- `pio update` is a combination of `pio platform update` and `pio lib update`

## Custom boards

Each project can have custom boards. The default location for project-specific board definitions is the `boards` directory in the root of the project.

With the default settings, PlatformIO looks for boards in this order:

- project's `boards` directory
- `~/.platformio/boards` directory
- `~/.platformio/platforms/*/boards` directory

You can add a board in `~/.platformio/boards` to be available for multiple projects.

If you use the `Arduino` framework you need an Arduino Variant for your board. See [Custom STM32 board for PlatformIO and Arduino, CMSIS, STM32Cube and LibOpenCM3]({% post_url 2021-04-03-PlatformIO_CustomSTM32Board %}) for details.
