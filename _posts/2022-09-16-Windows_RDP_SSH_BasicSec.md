---
layout: post
title: "Basic security for Windows including RDP and SSH"
description: "Basic security configuration and measures for Windows including RDP and SSH management"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "RDP", "SSH", "Windows Server", "Windows", "OpenSSH" ]
---

Here I have gathered some basic security measures that should be taken on every Windows installation.
I have used these (and many more) on Windows 10, Windows 11, Windows Server 2016, Windows Server 2019 and Windows Server 2022.

Short description of operations:

- [configure network adapters](#configure-network-adapters)
  - remove unused network protocols
  - remove WINS, NetBIOS and ignore LMHOSTS
  - disable unused adapters
- [configure the firewall](#configure-the-firewall)
- [accounts](#accounts)
- [install OpenSSH server and configure](#openssh-server-installation-and-configuration) it for key based authentication
- [use RDP through a SSH tunnel](#tunnel-rdp-through-ssh)
- for [domain-joined computers](#domain-joined-computers) create GPOs for:
  - access control
  - firewall configuration

## What this guide is

This is a basic, getting started, guide ! After implementing these measures:

- the Windows can be safely managed through SSH and RDP over SSH tunnels;
- lateral movement in a network is heavily restricted, even if the computers have remote exploitable vulnerabilities;
- MITM attacks for SSH can be prevented and detected (don't use `Agent forwarding` for start);
- MITM attacks for RDP are prevented if RDP is used only through SSH tunnels;
- the Windows host cannot be compromised without direct user interaction (for servers, compromising a vulnerable exposed service is still possible). 

## What this guide is not

- this is **not** a very technical guide !
- this is **not** a *complete* security guide.

## Configure network adapters

For every network adapter go to `Ethernet properties` and disable unused protocols.
For most computers I use **only**:

- `Client for Microsoft Networks`
- `QoS Packet Scheduler`
- `Internet Protocol Version 4 (TCP/IPv4)`

Sharing is needed only for file servers and printer servers !

Select `Internet Protocol Version 4 (TCP/IPv4)` and click the `Properties` button then click the `Advanced` button and in the `WINS` tab:

- remove any WINS server
- uncheck `Enable LMHOSTS lookup`
- select `Disable NetBIOS over TCP/IP`

Disable all unused network adapters

## Configure the firewall

For Windows clients you need:

- to allow them to respond to Echo requests, aka *pings*;
- to manage them remotely using RDP or SSH.

For servers:

- you need to determine required ports;
- after the basic configuration presented here add the rules needed to expose those ports;
- restrict the remote address space for exposed ports as much as possible;
- a file server also needs `File and Printer Sharing` protocol to be enabled (was disabled in the previous step).

### Windows PC

Make sure that you have at least some rules for Ping and RDP. Check the following code if want to add rules with PowerShell (replace `192.168.5.3` before use !):

```powershell
$mngStations = @("192.168.5.3")
$icmpAccess = @("LocalSubnet", "192.168.5.3")

New-NetFirewallRule -DisplayName 'StartRule-Ping' -Enabled True -Direction Inbound -Action Allow -Protocol ICMPv4 -IcmpType 8 -RemoteAddress $icmpAccess

New-NetFirewallRule -DisplayName 'StartRule-RDP' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389 -RemoteAddress $mngStations

New-NetFirewallRule -DisplayName 'StartRule-SSH' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 -RemoteAddress $mngStations -Program '%SystemRoot%\system32\OpenSSH\sshd.exe'
```

Enable the firewall for all profiles with these settings:

- Inbound connections: Block (default)
- Outbound connections: Allow (default)

Now delete any other Inbound and Outbound rule.

### Windows File server example

```powershell
$fsClients = @("LocalSubnet")

New-NetFirewallRule -DisplayName 'StartRule-FS' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -RemoteAddress $fsClients
```

### Windows HTTP / HTTPS server example

```powershell
$httpClients = @("LocalSubnet")

# for HTTP
New-NetFirewallRule -DisplayName 'StartRule-HTTP' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 -RemoteAddress $httpClients

# for HTTPS
New-NetFirewallRule -DisplayName 'StartRule-HTTPS' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443 -RemoteAddress $httpClients
```

## Accounts

Use long and strong passwords, preferably random generated. Use a password manager and do not reuse the passwords.

Forget about password expiration policy !
NIST removed the references to periodic password changes in its password guidance since 2017 !
Password expiration policy is not only outdated, is doing more harm than good !
Search the web and use your mind.

Not in the scope of this guide but **use MFA at least for the accounts with administrative rights**.

As a best practice, add an administrative account for every local administrator and disable the built-in `Administrator` account.

For domain-joined computers keep one local administrator account and use it only for emergency cases. Ideally, the local *emergency* administrator should be protected by different passwords (long, strong and random generated) on every computer.

Not in the scope of this guide but maybe Microsoft's `Local Administrator Password Solution` may worth a try. Check [Step-by-Step Guide: How to Configure Microsoft Local Administrator Password Solution (LAPS)](https://techcommunity.microsoft.com/t5/itops-talk-blog/step-by-step-guide-how-to-configure-microsoft-local/ba-p/2806185)

## OpenSSH server installation and configuration

### OpenSSH installation

```powershell
# install the client and the server
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.*' |
ForEach-Object -Process {
    if ($_.State -ne [Microsoft.Dism.Commands.PackageFeatureState]::Installed) {
        Write-Host "Installing" $_.Name
        Add-WindowsCapability -Online -Name $_.Name
    }
}

# start the service and set it to start automatically
Start-Service -Name sshd
Set-Service -Name sshd -StartupType 'Automatic'

# optional, set the default shell to be powershell.exe
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```

### Public key authentication

If you do not have a key pair or wish to generate a new one use execute:

```sh
ssh-keygen -t ed25519 -f my_new_ed25519_key -C "This is my new shiny key"
cat my_new_ed25519_key.pub
```

- `my_new_ed25519_key` contains the private key and MUST be kept secret
- `my_new_ed25519_key.pub` contains the public key

To add the key:

```powershell
# set the value from my_new_ed25519_key.pub
$authorizedKey = "ssh-ed25519 AAA..............................................................xyz This is my new shiny key"

# add it to `administrators_authorized_keys` file
Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value "$authorizedKey"

# make sure the permissions for `administrators_authorized_keys` are correct
icacls.exe "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
```

### OpenSSH configuration

To see if the algorithms from the next `conf` file are supported use:

```powershell
ssh -Q cipher
ssh -Q mac
ssh -Q kex
```

Edit `%programdata%\ssh\sshd_config` and add these **to the beginning** of the file:

```ssh
Protocol 2
PubkeyAuthentication yes
PasswordAuthentication no
AuthenticationMethods publickey

KexAlgorithms curve25519-sha256@libssh.org,curve25519-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

### Regenerate host keys

```powershell
# delete actual keys
Remove-Item -Path $env:ProgramData\ssh\ssh_host_*_key;
Remove-Item -Path $env:ProgramData\ssh\ssh_host_*_key.pub

# restart SSHD service. It will regenerate the keys
Restart-Service -Name sshd
```

To display the SHA256 fingerprint for the new hosts's ed25519 key use:

```powershell
ssh-keygen -lf $env:ProgramData\ssh\ssh_host_ed25519_key
```

**Note:** Installing OpenSSH may require a restart. If the connection is not working then try again after restart.

### Check SSH connection

Connect to the server with your key:

```sh
# for local accounts added to the local Administrators group
ssh localAdmin@ip_of_the_server -i my_new_ed25519_key

#for domain accounts added to the local Administrators group
#ssh account@domain@ip_of_the_server -i my_new_ed25519_key
```

#### First connection

If you never connected before to this host you will receive a warning like this:

```plaintext
The authenticity of host '..............' can't be established.
ED25519 key fingerprint is SHA256:Aaaa........................................
Are you sure you want to continue connecting (yes/no/[fingerprint])? 
```

The fingerprint of the key should be the one you've got in the **Regenerate host keys** section.
If is the same type `yes`.

#### Connection after the host keys were regenerated

If you have regenerated the host keys you will receive a warning like this:

```plaintext
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:Aaaa........................................
Please contact your system administrator.
Add correct host key in ................./known_hosts to get rid of this message.
Offending ED25519 key in ................./known_hosts
  remove with:
  ssh-keygen -f "................./known_hosts" -R "................."
ED25519 host key for ............... has changed and you have requested strict checking.
Host key verification failed.
```

Remove the key as it says (`ssh-keygen -f "..." -R "..."`) and connect again.

## Tunnel RDP through SSH

On your management computer, open a tunnel to the destination computer:

```sh
# for local accounts added to the local Administrators group
ssh -L 9999:127.0.0.1:3389 localAdmin@ip_of_the_server -i my_new_ed25519_key

#for domain accounts added to the local Administrators group
#ssh -L 9999:127.0.0.1:3389 account@domain@ip_of_the_server -i my_new_ed25519_key
```

To connect to the server with tunneled RDP use `127.0.0.1:9999` as your destination address.

On the remote server, executing `netstat -bn` will show the connections:

```plaintext
TCP  127.0.0.1:3389     127.0.0.1:49746             ESTABLISHED
TermService
[svchost.exe]

TCP  127.0.0.1:49746    127.0.0.1:3389              ESTABLISHED
[sshd.exe]

TCP  192.168.server:22  192.168.managementPC:57402  ESTABLISHED
[sshd.exe]
```

Now you can delete / disable the RDP access rule (`StartRule-RDP`) and connect only using SSH tunnels.
Removing that rule will block you to use RDP directly but will also block anyone who may try to attack it.

## Domain-joined computers

You should have at least an `Organizational Unit` (OU) for workstations and OUs for servers.
GPOs can be applied to following Active Directory containers: site, domain, organizational unit.

### Access GPO

Create a GPO for access. Under `Computer Configuration/ Policies` make these settings:

```plaintext
Windows Settings
    Security Settings
        Local Policies / User Rights Assignment
            Allow log on through Terminal Services : add here the accounts that are allowed to connect through RDP
        Restricted Groups
            BUILTIN\Administrators : add here the users that should be members of the local Administrators group
Administrative Templates
    Windows Components / Remote Desktop Services / Remote Desktop Session Host / Connections
        Allow users to connect remotely by using Remote Desktop Services : Enabled
        Restrict Remote Desktop Services users to a single Remote Desktop Services session : Enabled
        Select RDP transport protocols : Enabled, Transport Type = Use only TCP
        Set rules for remote control of Remote Desktop Services user sessions : Enabled, Full Control without user's permission
    Windows Components / Remote Desktop Services / Remote Desktop Session Host / Security
        Require secure RPC communication : Enabled
        Require use of specific security layer for remote (RDP) connections : Enabled, Security Layer = SSL
        Require user authentication for remote connections by using Network Level Authentication : Enabled
        Set client connection encryption level : Enabled, Encryption Level = High Level
```

Apply this GPO to the OUs with computers and servers.

### Firewall GPOs

You should create GPOs with firewall rules for every server group - grouping based on exposed network services / ports - and one for PCs.

The basic skeleton is this:

```plaintext
Windows Settings
    Security Settings
        Windows Firewall with Advanced Security
            Domain Profile Settings, Private Profile Settings and Public Profile Settings
                Firewall state:	On
                Inbound connections: Block
                Outbound connections: Allow
                Apply local firewall rules: No
                Apply local connection security rules: No
                Display notifications: Yes
                Allow unicast responses: No
                Log dropped packets: Yes
                Log successful connections: Yes
                Log file path: %systemroot%\system32\logfiles\firewall\pfirewall.log
                Log file maximum size (KB): 4096
            Inbound Rules
                # add a rule for OpenSSH access
                # add a rule for RDP access
                # add a rule for ICMP Echo Request
Administrative Templates
    Network / Network Connections / Windows Defender Firewall / Domain Profile
        Windows Defender Firewall: Allow logging : Enabled
            Log dropped packets: Enabled
            Log successful connections: Enabled
            Log file path and name: %systemroot%\system32\logfiles\firewall\pfirewall.log
            Size limit (KB): 4096
        Windows Defender Firewall: Prohibit notifications : Disabled
        Windows Defender Firewall: Prohibit unicast response to multicast or broadcast requests : Enabled
        Windows Defender Firewall: Protect all network connections : Enabled
```

and is OK for the computers that does not offer / expose network services.
Apply this to the OUs for computers.

After OpenSSH configuration and RDP through SSH works, the RDP access rule can be eliminated.
As I have said before, removing that rule will block you to use RDP directly but will also block anyone who may try to attack it.

For every server group create dedicated firewall GPOs, based on previous skeleton, and add the required inbound rules.
Apply these to the OUs for servers.

## Closing words

This article cover some minimal security settings and advices that will improve the security configuration of Windows hosts.
In real life you should use scripts to configure the systems and you should take more measures to improve your security posture.

The configuration of OpenSSH server can be improved, but that is another article.

The configuration of your SSH client should be checked. Disabling agent forwarding will protect you from MITM attacks.

The GPOs are minimal. There are a lot more settings that can improve the security of Windows hosts.
