---
title: About
description: About Calin Radoni
date: 2020-03-19
date-modified: 2020-05-23
---

{% if site.social-links %}
{% capture info-sameAs %}{% for item in site.social-links %}"{{ item.link }}"{% if forloop.last == false %}, {% endif %}{% endfor %}{% endcapture %}
{% endif %}
{% capture info-url %}{% link pages/about.md %}{% endcapture %}
{% include seo-ldjson-person.html
    name = "Călin Rădoni"
    image = "/assets/img/CalinRadoni.png"
    jobTitle = "Systems Engineer by day, ... by night"
    alumniOf = "Faculty of Automation and Computers from Politehnica University Timisoara"
    gender = "male"
    url = info-url
    sameAs = info-sameAs
    %}

## About this site

- built with Markdown, HTML and CSS / SCSS / Liquid and the [simple-purple-theme](https://calinradoni.github.io/simple-purple-theme/) in Visual Studio Code
- generated using <a href="https://jekyllrb.com/">Jekyll
- hosted on <a href="http://pages.github.com/">GitHub Pages

## About the author, Calin Radoni

### Programming, scripting and markup languages

Frequently I am using **C/C++**, **Bash scripting**, **reStructuredText** and **Markdown**.

Not so often, **Powershell scripting**.

Now and then, HTML, CSS / SCSS / Liquid, Python and YAML.

Used in the past: Assembly (x86, PIC and Z80), Brainfuck, C#, Go, Java, Javascript, Lisp, Pascal, PHP, Perl, Python, SQL, Superhack, Textile and few that I forgot about.

### Hardware platforms

Right now I am using **ESP32** and **STM32** devices that I have built.

I have used and played with:

- ATMega and ATTiny - hardware development, software with and without Arduino
- ESP8266, just for testing
- PIC16, PIC18 and PIC32 - hardware development, software in Assembly, C and C++
- Z80 - hardware development, software in Assembly and Basic

### Networking

- Routers and switches: Cisco, Allied Telesys, HP, Huawei, D-Link, TP-Link
- Access Points: UniFi, MikroTik, Linksys
- Security devices: Cisco ASA, Check Point, UniFi Security Gateway Pro, FortiGate

### Linux

- Debian and CentOS: Firewalls, File server, Backup server, Jump Server, NTP Server, Nagios, Suricata + ELK Stack
- Ubuntu: daily driver
- Kali

### Windows

- Hyper-V Server
- Active Directory

### VoIP

- Unify OpenScape, Siemens Hipath
