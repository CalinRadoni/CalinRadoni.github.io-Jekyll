---
layout: post
title: "Arrays in Bash scripts"
description: "About using arrays in Bash scripts"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Bash", "Bash arrays"]
---

This document summarize some code I use for Bash arrays.<!--more-->

For more information see [Bash Reference Manual - Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)

To access all the elements of an array, `@`, `*` are used. `#` will get you the number of elements. As a processed short excerpt from that manual:

- `"${arr[@]}"` *expands each element of* `arr` *to a separate word*;
- `"${arr[*]}"` *expands to a single word with the value of each array member separated by the first character of the* [IFS](https://www.gnu.org/software/bash/manual/bash.html#index-IFS) *variable*;
- `"${#arr[*]}"` and `"${#arr[@]}"` *expands to the number of elements in the array*.

To read more about `@`, `*` and `#` in Bash see [Bash Reference Manual - Special Parameters](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html).

## Indexed arrays

```sh
#!/usr/bin/bash

# explicit declaration of an indexed array
declare -a arr

display_array_info() {
    printf "%d elements, keys: %s, values: %s\n" "${#arr[@]}" "${!arr[*]}" "${arr[*]}"
}

# assignment with a sequence of values
arr=(value0 value1 value2)

# display the array's values
echo "${arr[@]}"
# display the array as a string, values delimited by IFS
echo "${arr[*]}"
# ... array keys ...
echo "${!arr[@]}"
# ... and number of elements
echo "${#arr[@]}"

# add an element to the end of the array
arr+=(value3)
display_array_info

# add / change an element
arr[7]=v7
display_array_info

# change the last element (negative indices count back from the end of the array)
arr[-1]=v77
display_array_info

# this actually adds an element because arr[6] was not defined before
arr[-2]=v66
display_array_info

# delete the second element
unset 'arr[1]'
display_array_info

# rebuild the array to use continuous indices
arr=("${arr[@]}")
display_array_info
```

The output of the previous script is:

```txt
value0 value1 value2
value0 value1 value2
0 1 2
3
4 elements, keys: 0 1 2 3, values: value0 value1 value2 value3
5 elements, keys: 0 1 2 3 7, values: value0 value1 value2 value3 v7
5 elements, keys: 0 1 2 3 7, values: value0 value1 value2 value3 v77
6 elements, keys: 0 1 2 3 6 7, values: value0 value1 value2 value3 v66 v77
5 elements, keys: 0 2 3 6 7, values: value0 value2 value3 v66 v77
5 elements, keys: 0 1 2 3 4, values: value0 value2 value3 v66 v77
```

## Associative arrays

```sh
#!/usr/bin/bash

# explicit declaration of an associative array
declare -A arr

display_array_info() {
    for key in "${!arr[@]}"; do
        printf "arr[%s] = %s\n" "$key" "${arr[$key]}"
    done
    printf "%d elements\n\n" "${#arr[@]}"
}

# assignment with statements
arr=([key0]=value0 [key1]=value1 [key2]=value2)

# display the array's values
echo "${arr[@]}"
# display the array as a string, values delimited by IFS
echo "${arr[*]}"
# ... array keys ...
echo "${!arr[@]}"
# ... and number of elements
echo "${#arr[@]}"
echo

# add / change an element
arr[7]=aaa
arr['key7']=bbb
arr[-1]=ccc
arr[key0]=ddd
display_array_info

# delete an element
unset 'arr[key1]'
display_array_info
```

The output of the previous script is:

```txt
value2 value0 value1
value2 value0 value1
key2 key0 key1
3

arr[-1] = ccc
arr[key7] = bbb
arr[key2] = value2
arr[key0] = ddd
arr[key1] = value1
arr[7] = aaa
6 elements

arr[-1] = ccc
arr[key7] = bbb
arr[key2] = value2
arr[key0] = ddd
arr[7] = aaa
5 elements
```
