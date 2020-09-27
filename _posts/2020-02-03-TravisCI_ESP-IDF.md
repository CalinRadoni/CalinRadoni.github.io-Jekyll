---
layout: post
title: "Travis CI and ESP-IDF"
date-modified: 2020-09-27
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "Travis CI", "ESP-IDF" ]
---

Building an [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/) project with [Travis CI](https://travis-ci.org/) is quite straightforward.
Open ESP-IDF's [Get Started](https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html) document,
select the desired version (*latest*, *stable*, *v4.0*, *v3.3.1*, etc.) and take note about the installation of:

- prerequisites
- software libraries
- tools (compiler, debugger, programmer, etc.)

and the setup of the environment variables.<!--more-->

That was the procedure that I have used to build the following `.travis.yml` files:

- the prerequisites, software libraries and tools are installed and set in the **addons**  and **install** sections;
- the `example` project is built in the **script** section;
- if the build is successful the content of the **after_success** section is executed.
- in the **branches** section the build is restricted to the `master` branch only.

## .travis.yml for ESP-IDF v4.1

```yaml
# Travis CI integration file for esp-idf version v4.1

os: linux
dist: focal
language: shell

addons:
  apt:
    packages:
    - git
    - wget
    - flex
    - bison
    - gperf
    - python3
    - python3-pip
    - python3-setuptools
    - python-is-python3
    - cmake
    - ninja-build
    - ccache
    - libffi-dev
    - libssl-dev

install:
  - mkdir ~/esp
  - cd ~/esp
  - git clone -b v4.1 --recursive https://github.com/espressif/esp-idf.git
  - cd ~/esp/esp-idf
  - ./install.sh
  - . ~/esp/esp-idf/export.sh

script:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py reconfigure
  - idf.py app

after_success:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py size

branches:
  only:
  - master
```

## .travis.yml for ESP-IDF v4.0.1

```yaml
# Travis CI integration file for ESP-IDF v4.0.1 release

os: linux
dist: xenial
language: shell

addons:
  apt:
    packages:
    - git
    - wget
    - libncurses-dev
    - flex
    - bison
    - gperf
    - python
    - python-pip
    - python-setuptools
    - cmake
    - ninja-build
    - ccache
    - libffi-dev
    - libssl-dev

install:
  - mkdir ~/esp
  - cd ~/esp
  - git clone -b v4.0.1 --recursive https://github.com/espressif/esp-idf.git
  - cd ~/esp/esp-idf
  - ./install.sh
  - . ~/esp/esp-idf/export.sh

script:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py reconfigure
  - idf.py app

after_success:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py size

branches:
  only:
  - master
```

## .travis.yml for ESP-IDF v3.3.2

```yaml
# Travis CI integration file for ESP-IDF v3.3.2

os: linux
dist: xenial
language: shell

addons:
  apt:
    packages:
    - git
    - wget
    - libncurses-dev
    - flex
    - bison
    - gperf
    - python
    - python-pip
    - python-setuptools
    - python-serial
    - python-cryptography
    - python-future
    - python-pyparsing
    - cmake
    - ninja-build
    - ccache
    - libffi-dev
    - libssl-dev

install:
  - mkdir ~/esp
  - cd ~/esp
  - wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  - tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  - git clone -b v3.3.2 --recursive https://github.com/espressif/esp-idf.git
  - export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"
  - export IDF_PATH=~/esp/esp-idf
  - export PATH="$IDF_PATH/tools:$PATH"
  - python -m pip install --user -r $IDF_PATH/requirements.txt

script:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py reconfigure
  - idf.py app

after_success:
  - cd $TRAVIS_BUILD_DIR/example
  - idf.py size

branches:
  only:
  - master
```
