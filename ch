#!/bin/bash

# catch uninitialized variables
set -u

###############################################
# extract from line starting with search word
# upto newline or line starting with -
# f=2 patch for
#   options spread over 2 lines (ex: ch wget -o, ch awk -v)
#   sed which has an empty line in between option and description

# builtin command help pages usually do not
# have newline separating option descriptions
###############################################
extract_text ()
{
    awk -v cmd="$cmd" -v regex="^\\\s*$1\\\>" '
        $0 ~ regex{f=2; print; next}
        f==2 && /^\s*--/{f=1; print; next}
        f==2 && cmd=="sed" && /^\s*$/{f=1; print; next}
        (/^\s*$/  || /^\s*-/) && f{exit}
        f' "$file"
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
cmd_type=$(type -t "$cmd")
if [[ "$cmd_type" == 'builtin' ]]; then
    help -m "$cmd" > "$file"
elif [[ "$cmd_type" == 'file' ]]; then
    man "$cmd" | col -bx > "$file"
else
    echo "Error: $cmd is not a valid command" 1>&2 && exit 1
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
    elif grep -q "^\s*$arg\b" "$file" ; then
        extract_text "$arg"
    # perl based rename has -f, -force; -n, -nono; etc
    elif grep -q "^\s*-[a-zA-Z],\s*$arg\b" "$file" ; then
        arg_mod="-[a-zA-Z],\\\s*${arg%%=*}"
        extract_text "$arg_mod"
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

