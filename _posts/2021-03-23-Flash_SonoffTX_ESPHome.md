---
layout: post
title: "Flash Sonoff TX with ESPHome"
description: "Flash Sonoff TX (and other ESP8266/ESP32 based devices) with ESPHome"
#image: /assets/img/.png
#date-modified: 2021-mm-dd
excerpt_separator: <!--more-->
categories: [ "Automation" ]
tags: [ "ESPHome", "Sonoff", "ESP8266", "podman", "docker" ]
---

I have used the official [ESPHome container](https://hub.docker.com/r/esphome/esphome) to flash some Sonoff TX switches.
Initial flashing requires a USB to UART convertor. Next, the firmware can be changed / updated / upgraded over the air.<!--more-->

To flash the firmware, these are the basic steps:

- generate a configuration file
- put the main chip in serial bootloader mode
- flash the chip

**Note:** I am using `podman`. To use `docker`, replace `podman` with `docker`.

## Preparation

Get the container:

```sh
podman pull docker.io/esphome/esphome:latest
```

## Generate the configuration file

Normally you should read at least [Getting Started with ESPHome](https://esphome.io/guides/getting_started_command_line.html) to create a basic configuration that can be changed / updated / upgraded later.

This is a basic configuration generated using the wizard:

```yaml
esphome:
  name: wizard_config
  platform: ESP8266
  board: esp01_1m

wifi:
  ssid: "Your_SSID"
  password: "Your_PASS"

  # Enable fallback hotspot (captive portal) in case wifi connection fails
  ap:
    ssid: "Startup Config Fallback Hotspot"
    password: "B3jelu0fjQZD"

captive_portal:

# Enable logging
logger:

# Enable Home Assistant API
api:
  password: "Bk4JG6gtjlax"

ota:
  password: "Bk4JG6gtjlax"
```

At least, generate one for each device, replacing:

- the name *wizard_config* with a unique one for each device
- *Your_SSID* and *Your_PASS* with the ones you use

## Serial bootloader mode

<p class="text-center back-red-color">
<b>Warning:</b> make sure the switch is not connected to the mains voltage ! Do not execute these procedures with the switch connected to the mains voltage, to any appliance or plugged in !</p>

Remove the mainboard from the switch and observe the pins:

![Top image]({{ site.baseurl }}{% link assets/img/210322-SonoffTX-1.png %}){: .max-width-100}

To comunicate with the ESP8266, you need to connect the converter to **J3**.

To enter bootloader mode, ESP8266 and ESP32 must start with GPIO0 connected to Gnd. GPIO0 is marked on the back and a Gnd connection can be made from J1.

![Connections]({{ site.baseurl }}{% link assets/img/210322-SonoffTX-2.png %}){: .max-width-100}

- make the connections, no soldering is required if you bend the pins a little
- connect the USB to UART convertor to the PC. The board should *start*, you may see the signal LED blink
- disconnect the red wire
- with the green wire connect the pin marked **GND** on **J1** with the **GPIO0** (TP2) pin
- connect the red wire
- wait a few seconds and remove the green wire

Now the ESP8266 MCU should be in serial bootloader mode, the signal LED should **NOT** blink.

## Flash the chip

Replacing `wizard_config.yaml`, execute:

```sh
podman run --rm -v "${PWD}":/config --net=host --device=/dev/ttyUSB0 -it esphome/esphome wizard_config.yaml run
```

The **run** command will execute these steps:

- validates the configuration
- compiles a firmware
- uploads the firmware (over OTA or USB)
- starts the log view

Or you can do it in steps:

```sh
# validate the configuration file
podman run --rm -v "${PWD}":/config -it esphome/esphome wizard_config.yaml config

# compile
podman run --rm -v "${PWD}":/config -it esphome/esphome wizard_config.yaml compile
# ...
# RAM:   [====      ]  43.5% (used 35620 bytes from 81920 bytes)
# Flash: [====      ]  38.4% (used 393308 bytes from 1023984 bytes)
# Building .pioenvs/wizard_config/firmware.bin

# upload with the USB to UART convertor
podman run --rm -v "${PWD}":/config --device=/dev/ttyUSB0 -it esphome/esphome wizard_config.yaml upload

# reset the board
# disconnect the red cable for a few seconds

# show logs from running node using the network connection 
podman run --rm -v "${PWD}":/config --net=host -it esphome/esphome wizard_config.yaml logs

# clean build files
podman run --rm -v "${PWD}":/config -it esphome/esphome wizard_config.yaml clean
```

## More information

ESPHome:

- [Getting Started with ESPHome](https://esphome.io/guides/getting_started_command_line.html)
- [Configuration Types](https://esphome.io/guides/configuration-types.html)
- [Automations and Templates](https://esphome.io/guides/automations.html)
- [Frequently Asked Questions](https://esphome.io/guides/faq.html)

ESPHome with [Sonoff T3 EU 3 Gang](https://esphome.io/devices/sonoff_t3_eu_3gang_v1.0.html)

Serial bootloader details:

- [ESP8266 Boot Mode Selection](https://github.com/espressif/esptool/wiki/ESP8266-Boot-Mode-Selection)
- [ESP32 Boot Mode Selection](https://github.com/espressif/esptool/wiki/ESP32-Boot-Mode-Selection)
