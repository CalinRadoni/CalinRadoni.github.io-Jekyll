---
layout: post
title: "Notes on component definition for ESP-IDF stable (v3.3.x) and ESP-IDF v4.x"
categories: [ "Software development" ]
tags: [ "ESP-IDF" ]
---

For an ESP-IDF component, the content of `CMakeLists.txt` differs between versions.<!--more-->
However, I have used the *old* syntax with ESP-IDF v4.x without problems.

`CMakeLists.txt` for ESP-IDF **stable**:

```conf
set(COMPONENT_SRCS "foo.c" "bar.c")
set(COMPONENT_ADD_INCLUDEDIRS ".")
set(COMPONENT_PRIV_REQUIRES componentA componentB)
set(COMPONENT_REQUIRES componentC componentD)
register_component()
```

`CMakeLists.txt` for ESP-IDF **v4.x**:

```conf
idf_component_register(
    SRCS "foo.c" "bar.c"
    INCLUDE_DIRS "."
    PRIV_REQUIRES componentA componentB
    REQUIRES componentC componentD)
```

Explanation:

* Use `COMPONENT_PRIV_REQUIRES / PRIV_REQUIRES` to declare the components needed only for compiling this component;
* Use `COMPONENT_REQUIRES / REQUIRES` to declare the components needed by this component and any projects that includes this component;
* If not needed, `COMPONENT_PRIV_REQUIRES / PRIV_REQUIRES` and `COMPONENT_REQUIRES / REQUIRES` can be omitted;
* For more informations see [Component CMakeLists Files](https://docs.espressif.com/projects/esp-idf/en/stable/api-guides/build-system-cmake.html#component-cmakelists-files) for ESP-IDF stable.

**Note:** As of February 2020, according to [ESP-IDF Release v3.3.1](https://github.com/espressif/esp-idf/releases/tag/v3.3.1), ESP-IDF v3.3.x is the current stable release and should be supported until February 2022.
