---
layout: post
title: "Tenkeyless-like keyboard layout for Gnome and Ubuntu"
description: "Custom keyboard layout for a 'standard' laptop keyboard, Tenkeyless-like style, applicable for Gnome and Ubuntu"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Custom keyboard layout", "Tenkeyless", "Gnome", "Ubuntu", "Ansible" ]
---

<section class="row-vh limited-width">
  <div class="card-hv card-m1vh">
    <div class="body stretched padding-1h">
      <div class="card-row">
        <p>Transform a *standard* laptop keyboard (with numpad) into a tenkeyless-like keyboard by creating a custom keyboard layout applicable for Gnome and Ubuntu.</p>
        <p>Additionally, reprogram keys for **Audio volume** and **Display brightness** (note that the mapping for display brightness does not actually work).</p>
        <p>The image represents the changed numpad for a better laptop keyboard usage</p>
      </div>
    </div>
  </div>
  <div class="card-hv card-m1vh">
    <div class="body stretched padding-1h">
      <div class="card-row">
        <img src="/assets/img/211101-layout.png"/>
      </div>
    </div>
  </div>
</section>

## Create a custom keyboard layout

Create `/usr/share/X11/xkb/symbols/us_kpnav` like this:

```c
// Remapped keypad keys like navigation keys
// Audio volume and Display brightness on KPSU and KPAD

partial keypad_keys
xkb_symbols "us_kpnav" {
    include "pc+us+inet(evdev)"

    replace key <KPMU> { type= "ONE_LEVEL", symbols[Group1]=[    Prior ] };
    replace key <KPDV> { type= "ONE_LEVEL", symbols[Group1]=[     Home ] };
    replace key  <KP7> { type= "ONE_LEVEL", symbols[Group1]=[   Delete ] };
    replace key  <KP8> { type= "ONE_LEVEL", symbols[Group1]=[      End ] };
    replace key  <KP9> { type= "ONE_LEVEL", symbols[Group1]=[     Next ] };

    replace key  <KP4> { type= "ONE_LEVEL", symbols[Group1]=[  Shift_L ] };
    replace key  <KP5> { type= "ONE_LEVEL", symbols[Group1]=[       Up ] };
    replace key  <KP6> { type= "ONE_LEVEL", symbols[Group1]=[  Shift_R ] };
    replace key  <KP1> { type= "ONE_LEVEL", symbols[Group1]=[     Left ] };
    replace key  <KP2> { type= "ONE_LEVEL", symbols[Group1]=[     Down ] };
    replace key  <KP3> { type= "ONE_LEVEL", symbols[Group1]=[    Right ] };

    replace key <KPSU> { type= "TWO_LEVEL", symbols[Group1]=[ XF86AudioRaiseVolume, XF86MonBrightnessUp ] };
    replace key <KPAD> { type= "TWO_LEVEL", symbols[Group1]=[ XF86AudioLowerVolume, XF86MonBrightnessDown ] };

    replace key  <KP0> { type= "ONE_LEVEL", symbols[Group1]=[  Shift_L ] };
    replace key <KPDL> { type= "ONE_LEVEL", symbols[Group1]=[  Shift_R ] };
    replace key <KPEN> { type= "ONE_LEVEL", symbols[Group1]=[ NoSymbol ] };
};
```

## Add the new keyboard layout to the list of layouts

Edit `/usr/share/X11/xkb/rules/evdev.xml` and add the new layout

```xml
<layout>
    <configItem>
    <name>us_kpnav</name>
    <shortDescription>enr</shortDescription>
    <description>English (US) with keypad as nav</description>
    <languageList>
        <iso639Id>eng</iso639Id>
    </languageList>
    </configItem>
</layout>
```

before the `</layoutList>` line.

## Apply the new layout

```sh
sudo dpkg-reconfigure xkb-data
```

Add the new keyboard layouts in `Settings -> Region & Language -> Input Sources`.

## Ansible

I have created an Ansible role for setting the a new keyboard layout.
Check The **keyboard** role published in the [Ansible Ubuntu Workstation](https://github.com/CalinRadoni/ansible-ubuntu-workstation) repository.
