---
layout: post
title: "Extract certificates from a HTTPS server"
description: "Extract the certificates from a HTTPS server using openssl and sed"
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Certificates", "openssl", "sed", "Bash"]
---

Here are step by step operations from displaying certificates to extract only the last one in a format compatible with a "C" program.

Last paragraph contains the explanation of sed commands.

## Display certificates

```sh
server="raw.githubusercontent.com"
echo | openssl s_client -showcerts -connect "$server":443 2>/dev/null
```

## Extract only the certificates

```sh
server="raw.githubusercontent.com"
echo | \
    openssl s_client -showcerts -connect "$server":443 2>/dev/null | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'
```

## Extract only the last certificate

```sh
server="raw.githubusercontent.com"
echo | \
    openssl s_client -showcerts -connect "$server":443 2>/dev/null | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/H; /-----BEGIN CERTIFICATE-----/h; ${g;p};'
```

## Extract only the last certificate, "C" compatible format

```sh
server="raw.githubusercontent.com"
echo | \
    openssl s_client -showcerts -connect "$server":443 2>/dev/null | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/H; /-----BEGIN CERTIFICATE-----/h; ${g;p};' | \
    sed 's/^/"/; $!s/$/\\n" \\/; $s/$/"/'
```

## Explanation of sed commands

This line extracts the LAST block:

```sh
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/H; /-----BEGIN CERTIFICATE-----/h; ${g;p};'
```

- `-n`, `--quiet` or `--silent` suppresses automatic printing of pattern space;
- `/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/H` appends that matching block to hold space;
- `/-----BEGIN CERTIFICATE-----/h` copy this pattern to hold space (replacing everything that was there, of course);
- (`$`) at the end (`g`) copies hold space to pattern space and (`p`) prints current pattern space.

This line formats the certificate in a "C" compatible format:

```sh
sed 's/^/"/; $!s/$/\\n" \\/; $s/$/"/'
```

- `s/^/"/` insert `"` at the beginning of each line;
- `$!s/$/\\n" \\/` if is not the last line (`$!`) insert `\n" \` at the end of line;
- `$s/$/"/` if is the last line (`$`) insert `"` at the end of the line.
