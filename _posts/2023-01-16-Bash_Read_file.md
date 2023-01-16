---
layout: post
title: "Read file content in Bash scripts"
description: "Read file content in Bash scripts"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Bash", "read", "read file"]
---

This document contains common code and tests to read a file in Bash.
The code is linted with [ShellCheck](https://www.shellcheck.net/).

[Notes](#notes) is an important section of this document.

## Data file

For testing let's use `data.conf` file with the following content:

```conf
# This is an example file

key0    value0 # example value 0
key1    value1
key2    value2
```

## Read the file line by line

```sh
#!/bin/bash

src_file='data.conf'

while read -r line || [[ -n $line ]]; do
    if [[ -n $line ]]; then
        if [[ ${line:0:1} != '#' ]]; then
            printf '%s\n' "$line"
        fi
    fi
done < "$src_file"
```

will output:

```txt
key0    value0 # example value 0
key1    value1
key2    value2
```

## Read the file lines as fields

```sh
#!/bin/bash

src_file='data.conf'

while read -r v0 v1 _ || [[ -n $v0 ]]; do
    if [[ -n $v0 ]]; then
        if [[ ${v0:0:1} != '#' ]]; then
            printf '%s: %s\n' "$v0" "$v1"
        fi
    fi
done < "$src_file"
```

will output:

```txt
key0: value0
key1: value1
key2: value2
```

## Read the file lines as arrays

```sh
#!/bin/bash

src_file='data.conf'

declare -a arr

while read -r -a arr || [[ "${#arr[@]}" -gt 0 ]]; do
    if [[ "${#arr[@]}" -gt 0 ]]; then
        if [[ ${arr[0]:0:1} != '#' ]]; then
            printf '%d elements\n' "${#arr[@]}"
            printf '%s.' "${arr[@]}"
            printf '\n'
        fi
    fi
done < "$src_file"
```

will output:

```txt
6 elements
key0.value0.#.example.value.0.
4 elements
key1.value1.#.aaa.
2 elements
key2.value2.
```

## Notes

### Fields

If there are more variables than fields in a line, the extra variables will be empty.

If there are fewer variables then fields in a line, the last variable will get the rest of the line.

In the example provided, we are expecting two fields but because there may be more fields (comments after the fields or comment lines), I have used three variables, `v0`, `v1` and `_` as a throwaway variable.

If the fields are not separated by characters from `IFS`, specify another value for `IFS` before calling `read`. Example for ',' as field separator:

```sh
while IFS=, read -r v0 v1 _ || [[ -n $v0 ]]; do
```

### Last line not terminated by a newline character

If the last line is not terminated by a newline character, `read` will read it but return false. To catch this situation in previous scripts, `while`'s check was extended from the classic syntax:

```sh
while read -r line; do
```

to this:

```sh
while read -r line || [[ -n $line ]]; do
```

### Trimming

By default `read` will remove all leading and trailing whitespace characters (the characters present in IFS).
From the output of `echo -n "$IFS" | xxd -p` (20090a) we see that the default value of `IFS` is `space`, `tab` and `line feed`.

To avoid trimming, *empty* the `IFS` for `read`. Use:

```sh
while IFS= read -r line || [[ -n $line ]]; do
```

instead of:

```sh
while read -r line || [[ -n $line ]]; do
```

## Links

For more information see:

- [BashFAQ/001 - How can I read a file (data stream, variable) line-by-line (and/or field-by-field)?](http://mywiki.wooledge.org/BashFAQ/001)
- `help read` in your (Linux) terminal
- [Catching user input](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_08_02.html)
