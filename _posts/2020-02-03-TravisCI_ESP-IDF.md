---
layout: post
title: "Travis CI and ESP-IDF"
date-modified: 2020-05-31
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "Travis CI", "ESP-IDF" ]
---

Building an [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/) project with [Travis CI](https://travis-ci.org/) is quite straightforward.
Open ESP-IDF's [Get Started](https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html) document,
select the desired version (*latest*, *stable*, *v4.0*, *v3.3.1*, etc.) and take note <!--more--> about the installation of:

- prerequisites
- software libraries
- tools (compiler, debugger, programmer, etc.)

and the setup of the environment variables.

That was the procedure that I have used to build the following `.travis.yml` files:

- the prerequisites, software libraries and tools are installed and set in the **addons**  and **install** sections;
- the `example` project is built in the **script** section;
- if the build is successful the content of the **after_success** section is executed.
- in the **branches** section the build is restricted to the `master` branch only.

## .travis.yml for ESP-IDF stable (v3.x)

```yaml
# Travis CI integration file for
# esp-idf "stable" release
#
# In 2020.02.11 the stable release was v3.3.1

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

install:
  - mkdir ~/esp
  - cd ~/esp
  - wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  - tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  - git clone -b v3.3.1 --recursive https://github.com/espressif/esp-idf.git
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

## .travis.yml for ESP-IDF stable (v4.x)

```yaml
# Travis CI integration file for
# esp-idf v4.0 release

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
    - python-click
    - python-cryptography
    - python-future
    - python-pyparsing
    - python-pyelftools
    - cmake
    - ninja-build
    - ccache

install:
  - mkdir ~/esp
  - cd ~/esp
  - git clone -b release/v4.0 --recursive https://github.com/espressif/esp-idf.git
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
