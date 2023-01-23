---
layout: post
title: "Arguments and options for your Bash scripts"
description: "Write Bash scripts with options and arguments and use getopts for parsing"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Bash", "Bash options", "Bash arguments", "Bash parameters", "getopts"]
---

`getopts` parses command-line arguments passed to a script. It is defined in POSIX, is a Bash builtin and works with other shells too.<!--more-->

It is usable for simple scripts but:

- for a **more flexible** implementation see [Loop through arguments and options in your Bash scripts]({% post_url 2023-01-23-Bash_Loop_Options_Arguments %})
- the **practical** implementation that I use now is without `getopts` and is presented in [Bash scripting]({% post_url 2023-01-23-Bash_Scripting %}) article

`getopts` allow only single-letter options and performs option splitting (-hv will be processed as -h -v).

## Short note about positional parameters

- `$#` is a special variable that contains the number of arguments passed to the script.
- Positional parameter N may be referenced as `${N}`, or as `$N` when `N` consists of a single digit.
`$0` is reserved and expands to the name of the shell or shell script.
- Use `"$@"` (*keep the quotes*) to get all passed arguments as separate words.

See [Shell Parameters](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameters.html) for more information.

## Options

To get the options passed to the script use `getopts` with an `option_string`.
The `option_string` contains the options to be processed.

If an option is received but not found in `option_string` the result option will be set to the `?` character.
If the first character in `option_string` is `:` then `OPTARG` will be set to the option character found, otherwise a message will be written to the standard error and `OPTARG` will be unset.

If and option in `option_string` is followed by a `:` character that option expects an argument and the argument will be set in `OPTARG`.
If the argument is not passed and the first character in `option_string` is `:` then `OPTARG` will be set to the option character and the result option will be set to `:` character, otherwise the result will be set to the `?` character, a message will be written to the standard error and `OPTARG` will be unset.

After all the options are processed, `OPTIND` will be set to the index of the first argument left.

## The code

```sh
#!/bin/bash

declare -i flag_a=0
declare -i flag_b=0
declare arg_b=''

OPTIND=1

while getopts ":ab:c" option; do
    case $option in
        a)  # a option received
            ((flag_a++));;
        b)  # b option received
            ((flag_b++))
            arg_b="$OPTARG"
            ;;
        \?) printf '[%s] is an invalid option!\n' "$OPTARG"
            exit 1;;
        :)  printf '[%s] needs an argument!\n' "$OPTARG"
            exit 1;;
        *) # this is the default processing case
            printf '[%s] is not processed!\n' "$option"
            exit 1;;
    esac
done

if ((flag_a > 0)); then
    printf 'Received flag [-a]\n'
fi
if ((flag_b > 0)); then
    printf 'The argument for [-b] option is %s\n' "$arg_b"
fi

shift "$((OPTIND-1))"

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
- [POSIX Programmer's Manual - getopts](https://man7.org/linux/man-pages/man1/getopts.1p.html)
- [BashFAQ/035](https://mywiki.wooledge.org/BashFAQ/035)
- search for `getopts` in [Advanced Bash-Scripting Guide - Internal Commands and Builtins](https://tldp.org/LDP/abs/html/internal.html)
- [Bash Guide for Beginners - Using case statements](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html)
- [Bash Guide for Beginners - The shift built-in](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_07.html)
