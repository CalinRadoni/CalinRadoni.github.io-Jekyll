---
layout: post
title: "Notes about SNMP and Nagios"
description: "Notes about SNMP and usage of check_snmp Nagios plugin"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "SNMP", "Nagios", "check_snmp", "Cisco ASA" ]
---

To query a SNMP server for a specific information `snmpget` is the basic tool.

To *retrieve a subtree of management values* use `snmpwalk`.

If you need to use SNMP then better:

- use SNMPv3 with `authPriv` (authentication and privacy) communication mode;
- different passwords for authentication and encryption;
- SNMPv3 views to limit the available OIDs.

## Examples of snmpwalk usage

To enumerate the `system` node defined in `RFC1158 MIB-II` (.iso.org.dod.internet.mgmt.mib-2.system)

```sh
snmpwalk -v2c -c commBuzzzer IP_of_SNMP_Server 1.3.6.1.2.1.1

snmpwalk -v3 -l authPriv -u userBuzzzer -A passBuzzzer -X passBuzzzer IP_of_SNMP_Server 1.3.6.1.2.1.1

snmpwalk -v3 -l authPriv -u userBuzzzer -a SHA256 -A authBuzzzer -x AES -X passBuzzzer IP_of_SNMP_Server 1.3.6.1.2.1.1
```

## Example for check_snmp Nagios plugin usage

### Define commands

Define a command to query a SNMP v2c server using the `commBuzzzer` community name:

```nagios
define command{
    command_name check_snmp_v2
    command_line $USER1$/check_snmp -H $HOSTADDRESS$ -P 2c -C commBuzzzer -o $_SERVICESNMP_OID$ $ARG1$
}
```

Define a command to query a SNMP v3 server using the username `userBuzzzer` and the `passBuzzzer` password:

```nagios
define command{
    command_name check_snmp_v3
    command_line $USER1$/check_snmp -H $HOSTADDRESS$ -P 3 -L authPriv -U userBuzzzer -A passBuzzzer -X passBuzzzer -o $_SERVICESNMP_OID$ $ARG1$
}
```

Define a command to query a SNMP v3 server using the `userBuzzzer` username, the `authBuzzzer` authentication password, the `passBuzzzer` encryption password and also specifying the authentication and encryption algorithms:

```nagios
define command{
    command_name check_snmp_v3ap
    command_line $USER1$/check_snmp -H $HOSTADDRESS$ -P 3 -L authPriv -U userBuzzzer -a SHA -A authBuzzzer -x AES -X passBuzzzer -o $_SERVICESNMP_OID$ $ARG1$
}
```

### Define service templates

Check CPU temperature of a Cisco ASA,  `OID = 1.3.6.1.2.1.99.1.1.1.4.8`

```nagios
define service{
    name                check_ASA_CPU_Temp
    use                 generic-service
    service_description CPU Temperature
    _snmp_oid           1.3.6.1.2.1.99.1.1.1.4.8
    check_command       check_snmp_v3ap! -w15:60 -c10:71
    register            0
}
```

### Usage of the service template

```nagios
define service{
    use         check_ASA_CPU_Temp
    host_name   ASA23
}

define service{
    use         check_ASA_CPU_Temp
    host_name   ASA24
}
```
