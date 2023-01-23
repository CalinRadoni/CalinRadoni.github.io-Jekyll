---
layout: post
title: "Loop through arguments and options in your Bash scripts"
description: "Write Bash scripts with long and short options and arguments and use a loop for parsing"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Bash", "Bash options", "Bash arguments" ]
---

This way of handling command line options and arguments is flexible and allows processing of long options (--help) not only single-letter options (-h).<!--more-->

The **practical** implementation and usage, together with a shell script template, is presented in the [Bash scripting]({% post_url 2023-01-23-Bash_Scripting %}) article.

For a simpler implementation based on `getops` see the previous article, [Arguments and options for your Bash scripts]({% post_url 2023-01-14-Bash_Options_Arguments %}).

This implementation does not performs option splitting (-hv will be considered error and not processed as -h -v).

## Short note about positional parameters

- `$#` is a special variable that contains the number of arguments passed to the script.
- Positional parameter N may be referenced as `${N}`, or as `$N` when `N` consists of a single digit.
`$0` is reserved and expands to the name of the shell or shell script.
- Use `"$@"` (*keep the quotes*) to get all passed arguments as separate words.

See [Shell Parameters](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameters.html) for more information.

## The code

```sh
#!/bin/bash

declare -i flag_a=0
declare -i flag_b=0
declare arg_b=''

while :; do
    case $1 in
        -a|--flaga) # a option received
            ((flag_a++));;
        -b|--flagb) # b option received
            ((flag_b++))
            if [[ -z "$2" ]]; then
                printf '[%s] needs an argument!\n' "$1"
                exit 1
            fi
            if [[ "$2" == '--' ]]; then
                printf '[%s] needs an argument!\n' "$1"
                exit 1
            fi
            arg_b=$2
            shift
            ;;
        --) # explicit end of all options, break out of the loop
            shift
            break
            ;;
        -?*)
            printf '[%s] is an invalid option!\n' "$1"
            exit 1
            ;;
        *)  # this is the default processing case
            # there are no more options, break out of the loop
            break
    esac
    shift
done

if ((flag_a > 0)); then
    printf 'Received flag [-a]\n'
fi
if ((flag_b > 0)); then
    printf 'The argument for [-b] option is %s\n' "$arg_b"
fi

if (($# > 0)); then
    printf 'The are %d remaining arguments:\n' "$#"
    printf '%s\n' "$@"
fi
```

When called with `-a -b bbb ccc ddd` options and arguments string, the previous script will print:

```txt
Received flag [-a]
The argument for [-b] option is bbb
The are 2 remaining arguments:
ccc
ddd
```

## Links

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [BashFAQ/035](https://mywiki.wooledge.org/BashFAQ/035)
- [Bash Guide for Beginners - Using case statements](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html)
- [Bash Guide for Beginners - The shift built-in](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_07.html)
