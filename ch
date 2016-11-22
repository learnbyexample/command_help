#!/bin/bash

cmd="$1"
shift

#file=$(mktemp) #delete the file at end of script?
file='/tmp/tmp_file.txt'

if builtin "$cmd" &> /dev/null ; then
    bltin=1
    help -m "$cmd" > "$file"
else
    bltin=0
    #whatis "$cmd"
    man "$cmd" | col -bx > "$file"
fi
awk -v RS= '/^NAME/' "$file" | tail -n +2

for arg in "$@" ; do
    if (( bltin == 1 )) ; then
        while read -n1 char; do
            grep "^\s*-$char\b" "$file"
        done < <(echo -n "${arg:1}")
    else
        if [[ $arg =~ ^-- ]] ; then
            arg="${arg%%=*}"
        fi

        if grep -q "^\s*$arg\b" "$file" ; then
            awk -v RS= -v rx="^\\\s*$arg\\\>" '$0 ~ rx' "$file"
        elif grep -qE "^\s*(-[a-zA-Z],\s*)?$arg\b" "$file" ; then
            awk -v RS= -v rx="^\\\s*(-[a-zA-Z],\\\s*)?$arg\\\>" '$0 ~ rx' "$file"
        else
            while read -n1 char; do
                awk -v RS= -v rx="^\\\s*-$char\\\>" '$0 ~ rx' "$file"
            done < <(echo -n "${arg:1}")
        fi
    fi
done
