#!/bin/bash

cmd="$1"
shift

#file=$(mktemp)
file='/tmp/tmp_file.txt'

# single awk function
extract_text ()
{
    #echo "pattern to search: $1"
    awk -v regex="^\\\s*$1\\\>" '$0 ~ regex{f=1; print; next} (/^\s*$/  || /^\s*-/) && f{exit} f' "$file"
}

if builtin "$cmd" &> /dev/null ; then
    bltin=1
    help -m "$cmd" > "$file"
else
    bltin=0
    #whatis "$cmd"
    man "$cmd" | col -bx > "$file"
fi
awk -v RS= '/^NAME/' "$file" | tail -n +2
echo

for arg in "$@" ; do
    if [[ $arg =~ ^-- ]] ; then
        # for options like grep --color[=WHEN]
        arg="${arg%%=*}"

        # for options like ls -a, --all, grep -e PATTERN, --regexp=PATTERN, etc
        arg_mod_grp="(-[a-zA-Z](\s*[a-zA-Z]*)?,\s*)?$arg"
        arg_mod_awk="(-[a-zA-Z](\\\s*[a-zA-Z]*)?,\\\s*)?$arg"

        # for cases like grep --color
        if grep -q "^\s*$arg\b" "$file" ; then
            extract_text "$arg"
        # for cases like ls -a, --all, grep -e PATTERN, --regexp=PATTERN, etc
        elif grep -qE "^\s*$arg_mod_grp\b" "$file" ; then
            extract_text "$arg_mod_awk"
        fi
        continue
    fi

    # for cases like find -type
    if grep -q "^\s*$arg\b" "$file" ; then
        extract_text "$arg"
    else
        while read -n1 char; do
            extract_text "-$char"
        done < <(echo -n "${arg:1}")
    fi
done

rm "$file"
