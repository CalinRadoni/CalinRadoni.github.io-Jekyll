---
layout: post
title: "ESP-IDF in a container"
description: "Installation and usage of Espressif's ESP-IDF container with Podman or Docker"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
categories: [ "System Administration" ]
tags: [ "ESP-IDF", "Podman", "Docker" ]
---

These instructions are valid for Podman and Docker. If you use Docker just replace `podman` with `docker`.

## ESP-IDF Container builds

Check the page of ESP-IDF [releases](https://github.com/espressif/esp-idf/releases) and find:

- latest stable release (v4.0.1)
- Long Term Support release (v3.3.2)

Find the closest [docker image tags](https://hub.docker.com/r/espressif/idf/tags) for these:

- release-v4.0
- v3.3.2

and pull them from [Docker Hub](https://hub.docker.com/) with:

```sh
podman pull espressif/idf:release-v4.0
podman pull espressif/idf:v3.3.2
```

Go to your project's directory then build with one of:

```sh
podman run --rm -v $PWD:/project -w /project espressif/idf:v3.3.2 idf.py build
podman run --rm -v $PWD:/project -w /project espressif/idf:release-v4.0 idf.py build
```

or do an interactive build with one of:

```sh
podman run --rm -v $PWD:/project -w /project -it espressif/idf:v3.3.2
podman run --rm -v $PWD:/project -w /project -it espressif/idf:release-v4.0
```

then execute the commands that you want:

```sh
idf.py menuconfig
idf.py build
```

To use the commands that interact with the serial port like:

- `idf.py flash`
- `idf.py monitor`

**first** connect your board **then** launch the container with the `--device=/dev/ttyUSB0` parameter, assuming dev/ttyUSB0 is for your USB-serial convertor:

```sh
podman run --rm -v $PWD:/project -w /project --device=/dev/ttyUSB0 -it espressif/idf:release-v4.0
```

## Notes for ESP-IDF components

For ESP-IDF components **remember** that the component name is its directory name !
This means that you have to start the container at least one level above component's directory
for it to keep its name.

I have a code library with a structure like this:

```txt
CodeLibrary
├── ESP32
│   ├── ESP32DLEDController
│   │   ├── CMakeLists.txt
│   │   ├── example
│   │   ├── LICENSE-GPLv3.txt
│   │   ├── README.md
│   │   └── src
│   ├── ESP32RMT
│   │   ├── CMakeLists.txt
... ... ...

```

To build the example for `ESP32DLEDController` component I have to preserve that directory name so I launch the
container from `CodeLibrary/ESP32` directory.

```sh
cd the-path-to/CodeLibrary/ESP32
podman run --rm -v $PWD:/project -w /project -it espressif/idf:release-v4.0

# inside the container
cd ESP32DLEDController/example
idf.py build
```

As a side note, this way allows *examples* that need multiple components from the CodeLibrary.

I do **not recommend** it but an alternative would be to use it like this:

```sh
cd the-path-to/CodeLibrary/ESP32/ESP32DLEDController
podman run --rm -v $PWD:/ESP32DLEDController -w /ESP32DLEDController -it espressif/idf:release-v4.0

# inside the container
cd example
idf.py build
```

because it needs a custom command for each component and does not allow applications / examples that need multiple components.
