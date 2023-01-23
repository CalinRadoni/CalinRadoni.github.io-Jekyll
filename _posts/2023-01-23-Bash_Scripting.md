---
layout: post
title: "Bash scripting"
description: "A template, some notes and links about Bash scripts"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Bash", "Bash script"]
---

This post contains a **practical** template script and some useful links for Bash scripts.

- [Template script](#template-script)
- [Using the script](#using-the-script)
- [Notes and important links](#notes-and-important-links)

and my [posts related to Bash](/pages/tags.html#bash).

## Template script

```sh
#!/bin/bash
#
# Template script that handle options and arguments
#
# Version: 0.9.0
# Copyright (C) 2023 Calin Radoni
# License GNU GPLv3 (https://choosealicense.com/licenses/gpl-3.0/)

# Initialize all option and argument variables, this operation
# prevents a possible contamination from the environment.
# These variables are set by the 'parse_options' function.
declare -a ARGS=()
declare -i verbose=0
declare infile=''

# Print a message then exit the program
# Arguments:
#   - exit code (optional), defaults to 1.
#     If the passed exit code is not numeric an error message is printed.
#   - message (optional), requires exit code to be provided.
exit_with_message() {
    declare exit_code="${1:-1}"
    if [[ -n "$2" ]]; then
        printf '%s\n' "$2" >&2
    fi
    if [[ "$exit_code" != +([[:digit:]]) ]]; then
        printf 'Incorrect exit code!\n' >&2
        exit 1
    fi
    exit "$exit_code"
}

# Show the usage (help) for this script
show_usage() {
    cat << EOF
Usage: ${0##*/} [-h] [-v] [-f INFILE] [ARGs] ...
Description of what this script does
Options:
    -h, --help         display this help message and exit
    -v, --verbose      verbose mode. Use multipletimes for increased verbosity
    -f, --file INFILE  select INFILE as the input file
EOF
}

# Parse options and their arguments
# Globals:
#   ARGS will hold the arguments
# Arguments:
#   the options to be parsed
# Example:
#   parse_options "$@"
parse_options() {
    while :; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                ((verbose++));;
            -f|--file)
                if [[ -z "$2" ]]; then
                    exit_with_message 1 "[$1] needs an argument!\n"
                    exit 1
                fi
                if [[ "$2" == '--' ]]; then
                    exit_with_message 1 "[$1] needs an argument!\n"
                    exit 1
                fi
                infile="$2"
                shift
                ;;
            --) # explicit end of all options, break out of the loop
                shift
                break
                ;;
            -?*)
                exit_with_message 1 "[$1] is an invalid option!\n"
                exit 1
                ;;
            *)  # this is the default processing case
                # there are no more options, break out of the loop
                break
        esac
        shift
    done

    if (($# > 0)); then
        ARGS=("$@")
    else
        ARGS=()
    fi
}

parse_options "$@"

# demo usage code start

if ((verbose > 0)); then
    printf 'Verbosity level is set to %d\n' "$verbose"
fi

if [[ -n "$infile" ]]; then
    printf 'The input file is %s\n' "$infile"

    # test if the file is readable (use -w to test if the file is writable)
    if [[ ! -r "$infile" ]]; then
        printf '%s is not readable !\n' "$infile" >&2
    fi
fi

if ((${#ARGS[@]} > 0)); then
    printf 'The are %d remaining arguments:\n' "${#ARGS[@]}"
    printf '%s\n' "${ARGS[*]}"
fi
for arg in "${ARGS[@]}"; do
    printf '<%s>\n' "$arg"
done
for ((i=0; i<"${#ARGS[@]}"; i++)); do
    printf '%d: <%s>\n' "$i" "${ARGS[$i]}"
done

# demo usage code end

exit 0
```

Running the script with these options and arguments: `-v -v -f aaa bbb ccc` or `-v -v -f aaa -- bbb ccc` will output:

```txt
Verbosity level is set to 2
The input file is aaa
aaa is not readable !
The are 2 remaining arguments:
bbb ccc
<bbb>
<ccc>
0: <bbb>
1: <ccc>
```

## Using the script

**1.** Declare variables for options and for arguments expected by options. In the template script the declarations are:

```sh
declare -i verbose=0
declare infile=''
```

 Use [declare](https://www.gnu.org/software/bash/manual/bash.html#index-declare):

- `declare -i` for integers
- `declare -a` for indexed arrays
- `declare -A` for associative arrays
- `declare` for other types

**2.** Update the `show_usage` function for your options and arguments.

**3.** Update the `parse_options` function for your options and arguments.

**4.** Replace the *demo usage code* with your code.

## Notes and important links

**1.** As with any programming language try to follow a coding style guide for that language.
Here is the [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

**2.** Use a static code analysis tool, a linter, to check your code.
[ShellCheck](https://www.shellcheck.net/) or [ShellCheck](https://github.com/koalaman/shellcheck) *is a GPLv3 tool that gives warnings and suggestions for bash/sh shell scripts*.

**3.** Start with the basics, do not reinvent the wheel, evolve as needed.

From the huge number of available resources:

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Bash FAQ](https://mywiki.wooledge.org/BashFAQ), [BashGuide](https://mywiki.wooledge.org/BashGuide), [Bash Programming](https://mywiki.wooledge.org/BashProgramming) and [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [13 resources for learning to write better Bash code](https://www.redhat.com/sysadmin/learn-bash-scripting)
- [The Bash Hackers Wiki](https://wiki.bash-hackers.org/start)
- [Awesome Bash](https://github.com/awesome-lists/awesome-bash)
- [Bash on opensource.com](https://opensource.com/tags/bash)
- Search for `bash` on [LinuxConfig.org](https://linuxconfig.org/). Here is a [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial)
- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/index.html) and [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/index.html) from [The Linux Documentation Project](https://tldp.org/)
