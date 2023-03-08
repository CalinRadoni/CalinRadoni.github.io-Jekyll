---
layout: post
title: "Ansible notes and quick start"
description: "Practical notes for using Ansible and quick start instruction"
#image: /assets/img/.png
date-modified: 2023-01-29
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Ansible" ]
---

For more information the official [Ansible Documentation](https://docs.ansible.com/ansible/latest/index.html) is invaluable.

The components of a basic Ansible environment are:

- **control node** is the host where Ansible is installed;
- **inventory** contains a list of the managed nodes;
- **managed nodes** the remote systems that are managed from a **control node**.

Article's content:

- [Ansible installation on Ubuntu](#ansible-installation-on-ubuntu)
- [Usage quick start, some explanations and notes](#usage-quick-start-some-explanations-and-notes)
  - [Remote host(s) specification](#remote-hosts-specification)
  - [Example host identity in SSH config](#example-host-identity-in-ssh-config)
  - [Authentication and authorization flags](#authentication-and-authorization-flags)
  - [Ad-hoc commands](#ad-hoc-commands)
  - [Playbooks](#playbooks)
  - [Variables](#variables)
- [Final words](#final-words)

## Ansible installation on Ubuntu

Making a Debian/Ubuntu the control node means installing Ansible:

```sh
sudo apt update
sudo apt install software-properties-common
sudo apt install python3 python3-pip python3-venv python3-jmespath python3-psutil
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible ansible-lint
```

If a playbook requires additional collections:

```sh
# install the collections from a 'requirements.yml' file:
ansible-galaxy collection install -r requirements.yml

# installing a collection by name:
ansible-galaxy collection install <collection_name>

# upgrade all collections from a 'requirements.yml' file:
ansible-galaxy collection install --upgrade -r requirements.yml

# upgrade a single collection:
ansible-galaxy collection install --upgrade <collection_name>
```

## Usage quick start, some explanations and notes

Generally ansible connects to the host with SSH.
It also needs SFTP but it can be restricted to use SCP instead with `ANSIBLE_SCP_IF_SSH=True` option.

The best way to connect with SSH is to use the authentication with public/private key pairs,
*also shown in [Getting started with Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html)* but is not mandatory - after installing an OS, SSH may not be configured to use keys.

When you manage more the one server :) the best recommendation is:

- add the identity of your remote hosts to `~/.ssh/config`. See [SSH Config File]({% post_url 2021-01-26-SSH_Config %}) for information
- add the remote hosts to an inventory file
- load private keys in `ssh-agent` while running Ansible commands

```sh
# list loaded keys
ssh-add -l
# add some keys
ssh-add <x_path_to_key_for_db_servers>
ssh-add <x_path_to_key_for_web_servers>
```

### Remote host(s) specification

The `-i, --inventory` flag specifies either:

- a comma separated host list - **keep** the last comma !
- an inventory file

Use the `--limit` flag to limit the execution to a part of the inventory.

Use the `--list-hosts` flag to only see the list of matching hosts, without executing anything else.

Examples:

```sh
-i 192.168.1.5,
-i 192.168.1.5,192.168.1.23,
-i web_servers.yml
-i inventories/development/web_servers.yml

# limit the execution to the hosts in the group 'internal_web_servers'
-i inventories/development/web_servers.yml --limit internal_web_servers

# limit the execution to the host 'web_servers_2'
-i inventories/development/web_servers.yml --limit web_servers_2

# limit the execution to the hosts that have names like 'web_servers_*'
-i inventories/test/servers.yml --limit web_servers_*
```

Inventory file example:

```yaml
---
all:
  hosts:
    web_server_0:
      ansible_host: 192.168.1.10
      color: red

    web_server_1:
      ansible_host: 192.168.1.11

  children:
    internal_web_servers:
      hosts:
        web_server_0:
        web_server_1:
      vars:
        color: blue
```

### Example host identity in SSH config

Example host identity in `~/.ssh/config`:

```txt
Host web_server_1
    HostName 192.168.1.11
    User supervisor
    IdentityFile ~/my_keys/web_servers
    IdentitiesOnly yes
```

### Authentication and authorization flags

- `-u, --user` specifies remote user. If this flag is omitted, searches `~/.ssh/config` and, if user is not found, uses current user
- `-k, --ask-pass` ask for remote user's password
- `--private-key` specify the private key for authentication

- `--become-user` runs the commands / playbook as this user, default is `root`
- `-K, --ask-become-pass` ask become password
- `--become-method` privilege escalation method, default `sudo`

### Ad-hoc commands

- `-m, --module-name` runs specified module. If this flag is not passed, the default module is `ansible.builtin.command` so you can pass a command with '-a' flag
- `-a, --args` module options

```sh
# authentication with password
ansible all -i x_IP_address, -k -m ping

# authentication with password, remote user name specified
ansible all -i web_servers.yml -u x_remote_user_name -k -a '/sbin/reboot'

# authentication with private key, remote user name specified
ansible all -i x_IP_address, \
    -K -u x_remote_user_name --private-key '<x_path_to_private_key>' \
    -m ansible.builtin.service -a 'name=httpd state=started'

# authentication with private key, user name and private key file name from `~/.ssh/config`
ansible all -i inventories/development/web_servers.yml -m ping
```

### Playbooks

```sh
# authentication with password
ansible-playbook -i x_IP_address, -k test_playbook.yml

# authentication with password, remote user name specified
ansible-playbook -i x_IP_address, -u x_remote_user_name -k test_playbook.yml

# authentication with private key, remote user name specified
# also specify become user (joker) and asks become password
ansible-playbook -i x_IP_address, -u x_remote_user \
    --private-key '<x_path_to_private_key>' \
    --become-user joker --ask-become-pass test_playbook.yml

# authentication with private key, user name and private key file name from `~/.ssh/config`
# execute the playbook for all the hosts defined in 'inventories/development/web_servers.yml'
ansible-playbook -i inventories/development/web_servers.yml test_playbook.yml

# execute the playbook for 'web_server_2' defined in 'inventories/test/web_servers.yml'
ansible-playbook -i inventories/test/web_servers.yml --limit web_server_2 test_playbook.yml
```

### Variables

There are a few ways to pass variables to playbooks, see [Where to set variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#where-to-set-variables) for extended information.

Generally the variables are set in inventory files, there are some in the provided example configuration.

The `-e` or `--extra-vars` flags are used to pass variables in the command line.
For the full reference see [Defining variables at runtime](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#id37).
Here are some examples adapted form that documentation:

```sh
# The key=value format works for strings
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"

# JSON format is needed to pass non-string values such as Booleans, integers,
# floats, lists, and so on. You must escape quotes and other special characters
# appropriately for both your markup (for example, JSON), and for your shell
ansible-playbook release.yml --extra-vars \
    '{"version":"1.23.45","other_variable":"foo","ghosts":["inky","pinky","sue"]}'
```

If you put the variables in a JSON or YAML file, no shell escaping is needed. Pass the file with variables like:

```sh
ansible-playbook release.yml --extra-vars "@some_file.json"
```

## Final words

Again, do yourself a favor and:

- add the identity of your remote hosts to `~/.ssh/config`. See [SSH Config File]({% post_url 2021-01-26-SSH_Config %}) for information
- add the remote hosts to an inventory file
- load private keys in `ssh-agent` while running Ansible commands
- read at least the [Getting started with Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html) article.
