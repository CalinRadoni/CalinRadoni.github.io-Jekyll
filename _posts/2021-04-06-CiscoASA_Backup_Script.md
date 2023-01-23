---
layout: post
title: "Cisco ASA backup script"
description: "Backup multiple Cisco ASA using SSH and a Bash script"
#image: /assets/img/.png
date-modified: 2022-09-13
excerpt_separator: <!--more-->
categories: [ "Networking" ]
tags: [ "Cisco ASA", "backup", "SSH" ]
---

The script creates a directory named `ASA-yyyymmdd` and saves the running configuration of each ASA device in a file called `deviceName-yymmdd-running` in that directory.

The script can be easily modified to save the startup config instead.

**Warning:** This script does not work for large configuration files. Cisco ASA will close the connection before the whole data is sent !

## Prerequisite

The devices must use the same `enable` password.

### SSH Access to ASA using a public key

If you have not done it already, configure SSH access to Cisco ASA using a public key.
See [Cisco ASA SSH access with Public Key]({% post_url 2021-04-06-CiscoASA_SSH_Access_PK %}) for more information.

### SSH Config records

If you have not done it already, add records for your Cisco ASA devices in `~/.ssh/config`. Here is an example:

```text
Host asa1
    HostName 192.168.1.1
Host asa2
    HostName 192.168.2.1
Host asa3
    HostName 192.168.3.1

Host asa*
    User sshUser
    IdentitiesOnly yes
    IdentityFile /path_to_keys/asaAccessKey
```

For more information see [SSH Config File]({% post_url 2021-01-26-SSH_Config %}) post.

### The backup script

```sh
#!/bin/bash

# version 2021.04.06
#
# This script checks if a public key with 'ASA' in description is added to ssh-agent.
# To list loaded keys use `ssh-add -l`
# To load a key use `ssh-add path_to_private_key`

enable_pass="the_enable_password_of_ASA"

devices=(
    asa1
    asa2
    asa3
)

if ! ps -p "$SSH_AGENT_PID" > /dev/null; then
    echo "ssh-agent is not started !"
    echo "Use something like: eval \$(ssh-agent -s)"
    echo "then add the private key with 'ssh-add path_to_private_key'"
    exit 1
fi

if ! ssh-add -l | grep -Fiq "ASA"; then
    echo "I didn't found a private key with 'ASA' in description !"
    exit 2
fi

DirName="ASA-$(date +%Y%m%d)"
mkdir -p "$DirName"
cd "$DirName" || exit 3

FileDate=$(date +%y%m%d)
for device in "${devices[@]}"; do
    echo "Backup for $device"
    FileName="${device}-${FileDate}-running"

ssh -tt "$device" << EOF | 
enable
$enable_pass
terminal pager 0
more system:running-config
EOF
sed -n "/# more system:running-config/,/: end/p" > "$FileName"

    FileSize=$(stat -c%s "$FileName")
    if (( FileSize == 0 )); then
        echo ">>> Error: $FileName is empty !"
    fi
done

ls -al
```

### Usage

**Step 1:** Start SSH Agent, if not started already:

```sh
(ps -p "$SSH_AGENT_PID" > /dev/null) || eval $(ssh-agent -s)
```

**Step 2:** Check the loaded keys with `ssh-add -l` and load the key with `ssh-add /path_to_keys/asaAccessKey` if not loaded.
You can also use this one-liner:

```sh
ssh-add -l | \
    grep -q `ssh-keygen -lf /path_to_keys/asaAccessKey | cut -d ' ' -f 2` || \
    ssh-add /path_to_keys/asaAccessKey
```

**Step 3:** Execute the script.

**Note:** you can also add the automatic start of `ssh-agent` and automatic load of the key at the beginning of the backup script.
