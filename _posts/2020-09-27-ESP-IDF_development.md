---
layout: post
title: "ESP-IDF development"
description: "ESP-IDF development and Visual Studio Code"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "ESP-IDF", "Visual Studio Code" ]
---

ESP-IDF development and Visual Studio Code<!--more-->

## Prerequisites for ESP-IDF

For Ubuntu 20.04 use:

```sh
sudo apt install git wget flex bison gperf python3 python3-pip python3-setuptools python-is-python3 cmake ninja-build ccache libffi-dev libssl-dev
```

See [Install prerequisites](https://docs.espressif.com/projects/esp-idf/en/stable/get-started/index.html#step-1-install-prerequisites) for other operating systems.

## Install ESP-IDF

### Find the latest stable release

Go to [ESP-IDF Releases](https://github.com/espressif/esp-idf/releases) page and find the latest stable release: as of 24 August 2020, the stable release is [v4.1](https://github.com/espressif/esp-idf/releases/tag/v4.1).

### Install the stable release

```sh
#!/bin/bash

# prepare destination directory
baseDir="$HOME/esp"
if [ -d "$baseDir" ]; then
    now=$(/bin/date +%s)
    newDir="${baseDir}.${now}"
    mv "$baseDir" "$newDir"
    echo "$baseDir was saved as $newDir"
fi
mkdir "$baseDir" || exit 1

# get the ESP-IDF repository
cd "$baseDir" || exit 2
git clone -b v4.1 --recursive https://github.com/espressif/esp-idf.git

# install the tools (compiler, debugger, Python packages, etc.)
cd "${baseDir}/esp-idf" || exit 3
./install.sh
```

Before use do not forget to source environment variables:

```sh
. $HOME/esp/esp-idf/export.sh
```

## Update ESP-IDF

For detailed information see [ESP-IDF Versions](https://docs.espressif.com/projects/esp-idf/en/stable/versions.html) document.

To see the installed version use:

```sh
idf.py --version
```

or, for older versions, use:

```sh
(cd ~/esp/esp-idf && git describe --tags --dirty)
```

### Easy way

The easy way is to delete the `~/esp/esp-idf` directory and install desired version.

### Update installed release

Go to [Releases page](http://github.com/espressif/esp-idf/releases) and select desired version then:

```sh
cd ~/esp/esp-idf
git fetch
git checkout vX.Y.Z
git pull
git submodule update --init --recursive
```

### Update the tools

After updating ESP-IDF execute the install script again, in case the new ESP-IDF version requires different versions of tools.

```sh
cd ~/esp/esp-idf
./install.sh
```

## Visual Studio Code

For each project I have a workspace saved in project's directory with the same name.
Example launcher for my `pax-LampD1` project located in `/data/Project` directory:

```sh
#!/bin/bash

# set the project's name, path and workspace
Project="pax-LampD1"
ProjectPath="/data/Projects/$Project"
WorkspaceFile="$ProjectPath/$Project.code-workspace"

# set the path to the code library
export CodeLib_PATH="/data/Projects/CodeLibrary"

# source the ESP-IDF provided script
. ~/esp/esp-idf/export.sh
# define an environment variable needed in "c_cpp_properties.json" file
export IDF_XTENSA_GCC="$(which xtensa-esp32-elf-g++)"
# go to project's directory
cd "$ProjectPath"
# and launch `code` with project's workspace
code "$WorkspaceFile"
```

In the project's `.vscode` directory I have:

- c_cpp_properties.json
- tasks.json

files which need the variables exported from launcher.

The `c_cpp_properties.json` file:

```json
{
    "env" : {
        "idf_path": "${env:IDF_PATH}",
        "codeLib_path": "${env:CodeLib_PATH}"
    },
    "configurations": [
        {
            "name": "Linux",
            "intelliSenseMode": "gcc-x64",
            "compilerPath": "${env:IDF_XTENSA_GCC}",
            "cStandard": "c11",
            "cppStandard": "c++17",
            "defines": [ "ESP32", "ESP_PLATFORM" ],
            "includePath": [
                "${idf_path}/components/**",
                "${codeLib_path}/**",
                "${workspaceFolder}/**"
            ],
            "browse": {
                "path": [
                    "${idf_path}/components",
                    "${codeLib_path}",
                    "${workspaceFolder}"
                ],
                "limitSymbolsToIncludedHeaders": false
            }
        }
    ],
    "version": 4
}
```

and the `tasks.json` file:

```json
{
    "version": "2.0.0",
    "linux": {
        "type": "shell",
        "options": {
            "cwd": "${workspaceFolder}/SW",
            "env": {
                "idf_py": "${env:IDF_PATH}/tools/idf.py",
                "idf_python": "${env:IDF_PYTHON_ENV_PATH}/bin/python"
            }
        },
        "presentation": {
            "echo": true,
            "reveal": "always",
            "focus": true,
            "panel": "shared",
            "showReuseMessage": false,
            "clear": false
        },
    },
    "problemMatcher": [],
    "tasks": [
        {
            "label": "ESP-IDF Build",
            "command": "${idf_python} ${idf_py} build",
            "problemMatcher": [
                {
                    "owner": "cpp",
                    "fileLocation": ["relative", "${workspaceFolder}/SW"],
                    "pattern": {
                        "regexp": "^\\.\\.(.*):(\\d+):(\\d+):\\s+(warning|error):\\s+(.*)$",
                        "file": 1,
                        "line": 2,
                        "column": 3,
                        "severity": 4,
                        "message": 5
                    }
                },
                {
                    "owner": "cpp",
                    "fileLocation": "absolute",
                    "pattern": {
                        "regexp": "^[^\\.](.*):(\\d+):(\\d+):\\s+(warning|error):\\s+(.*)$",
                        "file": 1,
                        "line": 2,
                        "column": 3,
                        "severity": 4,
                        "message": 5
                    }
                }
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
        },
        {
            "label": "ESP-IDF Clean",
            "command": "${idf_python} ${idf_py} fullclean"
        },
        {
            "label": "ESP-IDF Flash",
            "command": "${idf_python} ${idf_py} flash"
        },
        {
            "label": "ESP-IDF Monitor",
            "command": "${idf_python} ${idf_py} monitor"
        },
        {
            "label": "ESP-IDF Partition table Build",
            "command": "${idf_python} ${idf_py} partition_table"
        },
        {
            "label": "ESP-IDF Partition table Flash",
            "command": "${idf_python} ${idf_py} partition_table-flash"
        },
        {
            "label": "ESP-IDF Size information",
            "command": "${idf_python} ${idf_py} size-components"
        },
    ]
}
```

For more information see:

- [VSCode Tasks](https://code.visualstudio.com/docs/editor/tasks)
- [vscode-esp-idf-extension: ONBOARDING](https://github.com/espressif/vscode-esp-idf-extension/blob/master/docs/ONBOARDING.md)
- [vscode-esp-idf-extension: Template tasks.json](https://github.com/espressif/vscode-esp-idf-extension/blob/master/templates/.vscode/tasks.json)
