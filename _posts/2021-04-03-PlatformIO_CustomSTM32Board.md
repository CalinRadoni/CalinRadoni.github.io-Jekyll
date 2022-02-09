---
layout: post
title: "Custom STM32 board for PlatformIO and Arduino, CMSIS, STM32Cube and LibOpenCM3"
description: "Workflow and configuration files for custom STM32 board to be used with PlatformIO and Arduino, CMSIS, STM32Cube and LibOpenCM3 frameworks"
#image: /assets/img/.png
date-modified: 2022-02-09
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "PlatformIO", "Custom board", "STM32", "Arduino", "CMSIS", "STM32Cube", "LibOpenCM3" ]
---

To use a custom board with PlatformIO you need to create a JSON definition file. For Arduino framework you need an Arduino Variant. To test it with multiple frameworks you need an elaborate `plaformio.ini`.<!--more-->

This document shows all the steps and the [pax-BB5](https://github.com/CalinRadoni/pax-BB5) repository contains all that, and more.

## Intro

Example working configuration for this document:

- in the project's root directory create two directories, `boards` and `variants`.
- put `pax_bb5.json` in `boards` directory
- copy the `PAX_BB5` directory in `variants` directory. `PAX_BB5` contains the custom definitions for this Arduino variant and should have these files: `variant_PAX_BB5.h`, `variant_PAX_BB5.cpp`, `PinNamesVar.h`, `PeripheralPins.c` and `ldscript.ld`.
- configure PlatformIO to use the custom board. Basically set the `board`, `board_build.variant` and `board_build.variants_dir` for this configuration (see included `platformio.ini` file).

**Note:** At least since `ST STM32 (15.2.0)` with `framework-arduinoststm32 4.20100.211028 (2.1.0)` the *variant* files must be named `variant_`*board_name* and not `variant` as in older versions.

## platformio.ini

Here is a `platformio.ini` for a custom board that also allow source directories for every framework:

```ini
[platformio]
; default_envs = pax_bb5_a

[common]
src_filter = -<*>
build_flags = -Wall

[env]
platform = ststm32
board = pax_bb5
build_flags = ${common.build_flags}

[env:pax_bb5_a]
framework = arduino
board_build.variant = PAX_BB5
board_build.variants_dir = variants
src_filter = ${common.src_filter} +<arduino>

[env:pax_bb5_c]
framework = cmsis
src_filter = ${common.src_filter} +<cmsis>

[env:pax_bb5_s]
framework = stm32cube
src_filter = ${common.src_filter} +<stm32cube>

[env:pax_bb5_l]
framework = libopencm3
src_filter = ${common.src_filter} +<libopencm3>
```

## PlatformIO Board definition

Each project can have custom boards. The default location for project-specific board definitions is the `boards` directory in the root of the project.

With the default settings, PlatformIO looks for boards in this order:

- project's `boards` directory
- `~/.platformio/boards` directory
- `~/.platformio/platforms/*/boards` directory

You can add a board in `~/.platformio/boards` or in the `~/.platformio/platforms/*/boards` to be available for multiple projects.

Here is a working example file, `pax_bb5.json`:

```json
{
  "build": {
    "cpu": "cortex-m0plus",
    "extra_flags": "-DSTM32L051xx",
    "f_cpu": "32000000L",
    "mcu": "stm32l051k8t7",
    "product_line": "STM32L051xx",
    "platform": "ststm32",
    "variant": "PAX_BB5",
    "framework_extra_flags": {
      "arduino": "-D__CORTEX_SC=0 -DARDUINO_PAX5_BB"
    }
  },
  "debug": {
    "jlink_device": "STM32L051K8",
    "openocd_target": "stm32l0",
    "svd_path": "STM32L051x.svd",
    "default_tools": [
      "stlink"
    ]
  },
  "frameworks": [
    "arduino",
    "cmsis",
    "stm32cube",
    "libopencm3"
  ],
  "name": "PAx BaseBoard STM32L051",
  "upload": {
    "maximum_ram_size": 8192,
    "maximum_size": 65536,
    "protocol": "stlink",
    "protocols": [
      "jlink",
      "cmsis-dap",
      "stlink",
      "blackmagic"
    ]
  },
  "url": "https://github.com/CalinRadoni",
  "vendor": "CalinRadoni"
}
```

## Arduino variant

For all STM32 MCU, these files:

- `PeripheralPins.c`
- `PinNamesVar.h`
- `variant_PAX_BB5.cpp`
- `variant_PAX_BB5.h`

can be taken from [Arduino_Tools/genpinmap/Arduino](https://github.com/stm32duino/Arduino_Tools/tree/master/src/genpinmap/Arduino) or can be generated with [genpinmap](https://github.com/stm32duino/wiki/wiki/genpinmap).

### Modifications for the custom board

Those files should be analyzed and modified for your board.

#### variant_PAX_BB5.h

I have `defined` all the pins from D0 - D22 and changed all other `defines` for the board.

#### variant_PAX_BB5.cpp

**1:** `digitalPin` array declares all digital pins, in order, from D0 to D22

**2:** `analogInputPin` array declares all analog input pins. It contains the number of each pin from `digitalPin` array.

**3:** define the `SystemClock_Config` function. See further in this document.

#### PeripheralPins.c

Set the content of all arrays according to your board:

- `PinMap_ADC`
- `PinMap_I2C_SDA`
- `PinMap_I2C_SCL`
- `PinMap_PWM`
- `PinMap_UART_TX` I have used the order USART1, USART2
- `PinMap_UART_RX` I have used the order USART1, USART2
- `PinMap_UART_RTS` I have used the order USART1, USART2
- `PinMap_UART_CTS` I have used the order USART1, USART2
- `PinMap_SPI_MOSI`
- `PinMap_SPI_MISO`
- `PinMap_SPI_SCLK`
- `PinMap_SPI_SSEL`

#### PinNamesVar.h

I have removed the definitions for alternative pins.

### System Clock configuration

`void SystemClock_Config(void)` from `variant_PAX_BB5.cpp` must be defined and can be generated with [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html) application.

### Linker script

The `ldscript.ld` is processor dependent and can be generated with  [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html) application.

## Test run

For [pax-BB5](https://github.com/CalinRadoni/pax-BB5) here are the results of `pio run` for the blinky test project:

{: .hcdr}
| | Arduino | CMSIS | STM32Cube | LibOpenCM3 |
| --- | --- | --- | --- | --- |
| **RAM usage:** | 920 bytes | 28 bytes | 44 bytes | 0 bytes |
| **Flash usage:** | 9944 bytes | 456 bytes | 1448 bytes |516 bytes|
| **Build time:** | 9.12 s | 0.58 s | 3.91 s | 1.80 s |

no comments because is not the same code, just the same functionality. A bigger project probably will level the results.

## More information

- [Custom Embedded Boards](https://docs.platformio.org/en/latest/platforms/creating_board.html)
- [stm32duino wiki Add a new variant (board)](https://github.com/stm32duino/wiki/wiki/Add-a-new-variant-(board))
- [Add changes that allow use of a portable variants file #74](https://github.com/platformio/platform-atmelsam/pull/74)
