#!/bin/bash

###############################################
# extract from line starting with search word
# upto newline or line starting with -

# builtin command help pages usually do not
# have newline separating option descriptions
###############################################
extract_text ()
{
    awk -v regex="^\\\s*$1\\\>" '$0 ~ regex{f=1; print; next} (/^\s*$/  || /^\s*-/) && f{exit} f' "$file"
}


###############################################
# variable to save command name
# shift, for rest of arguments to be looped
# variable for temporary file
###############################################
cmd="$1"
shift
file='/tmp/command_help.txt'


###############################################
# Save help/man page to file variable
###############################################
if builtin "$cmd" &> /dev/null ; then
    help -m "$cmd" > "$file"
else
    man "$cmd" | col -bx > "$file"
fi


###############################################
# extract NAME section, equivalent to whatis

# extract relevant text for arguments
###############################################
awk '/^NAME$/{f=1; next} /^\s*$/ && f{exit} f' "$file"
echo

for arg in "$@" ; do
    # options starting with --
    if [[ $arg =~ ^-- ]] ; then
        # for options like --color=auto, remove string after =
        # add regex for options like ls -a, --all; grep -e PATTERN, --regexp=PATTERN; etc
        arg_mod="(-[a-zA-Z](\\\s*[^,]*)?,\\\s*)?${arg%%=*}"
        extract_text "$arg_mod"
    # for cases like find -path
    # won't work for cases like \a %% for printf
    # and perl based rename has -f, -force; -n, -nono; etc... smh
    elif grep -q "^\s*$arg\b" "$file" ; then
        extract_text "$arg"
    # single letter options starting with -
    elif [[ $arg =~ ^-[^-] ]] ; then
        while read -n1 char; do
            extract_text "-$char"
            echo
        done < <(echo -n "${arg:1}")
    # case-insensitive word search
    # probably try to match closest to an option?
    else
        grep -iw -C3 "$arg" "$file"
    fi
done


###############################################
# remove temporary file
###############################################
rm "$file"
