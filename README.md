# <a name="command-help"></a>Command Help

* [Examples](#examples)
* [Known Issues](#known-issues)
* [Wish list](#wish-list)
* [License](#license)

Inspired by [explainshell](http://explainshell.com/), tried out a `bash` script as a learning exercise. Tested only with **Ubuntu 16.04 LTS**. This is a simple single command search, many features like multiple commands in a pipe, command substitution, etc not implemented

<br>

Was using this simple function for single option search until this script:

```bash
$ ch() { whatis $1; man $1 | sed -n "/^\s*$2/,/^$/p" ; }

$ ch grep -l
grep (1)             - print lines matching a pattern
       -l, --files-with-matches
              Suppress normal output; instead print the name of each input file from which output would normally have
              been printed.  The scanning will stop on the first match.

$ ch ls -v
ls (1)               - list directory contents
       -v     natural sort of (version) numbers within text
```

There is also a command-line implementation called [explain](https://github.com/andysalerno/explain) which works from command line but not as well as **explainshell**

<br>

**A few learnings from this exercise**

* Optimizing the code - had recently read [good taste coding](https://medium.com/@bartobri/applying-the-linus-tarvolds-good-taste-coding-requirement-99749f37684a#.tlduyaygx) and it so happened that I too was able to remove some conditionals
* Initially, I had different code for extracting text for `builtin` commands and `man` pages (a case of [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself)), then was able to combine into unified code
* Saving output of `help` or `man` into a file and using it when needed proved faster
* Check out [earlier versions of the script](https://github.com/learnbyexample/command_help/commits/master/ch) for a snapshot of how things unfolded

<br>

### <a name="examples"></a>Examples

Calling by simple `ch` works for me as the script has been added to a `PATH` directory  
See [Getting started with Bash](https://stackoverflow.com/documentation/bash/300/getting-started-with-bash/1136/hello-world#t=201611220537537799159) for an introduction on `bash` scripting and how to execute it

* Single letter option

```bash
$ ch column -t
     column — columnate lists

     -t      Determine the number of columns the input contains and create a table.  Columns are delimited with
             whitespace, by default, or with the characters supplied using the -s option.  Useful for pretty-printing
             displays.
             
$ ch cd -P
    cd - Change the shell working directory.

        -P	use the physical directory structure without following symbolic
    	links: resolve symbolic links in DIR before processing instances
    	of `..'
```

* Multiple single letter options

```bash
$ ch ls -latrh
       ls - list directory contents

       -l     use a long listing format

       -a, --all
              do not ignore entries starting with .

       -t     sort by modification time, newest first

       -r, --reverse
              reverse order while sorting

       -h, --human-readable
              with -l and/or -s, print human readable sizes (e.g., 1K 234M 2G)

```

* Long options

```bash
$ ch ls --author
       ls - list directory contents

       --author
              with -l, print the author of each file

$ ch grep --color=auto
       grep, egrep, fgrep, rgrep - print lines matching a pattern

       --color[=WHEN], --colour[=WHEN]
              Surround the matched (non-empty) strings, matching lines, context lines, file names, line numbers, byte
              offsets, and separators (for fields and groups of context lines) with escape sequences to display  them
              in  color  on  the  terminal.   The  colors  are  defined by the environment variable GREP_COLORS.  The
              deprecated environment variable GREP_COLOR is still supported, but its setting does not have  priority.
              WHEN is never, always, or auto.

$ ch grep --regexp
       grep, egrep, fgrep, rgrep - print lines matching a pattern

       -e PATTERN, --regexp=PATTERN
              Use PATTERN as the pattern.  If this option is used multiple times or is combined with the -f  (--file)
              option,  search  for  all  patterns given.  This option can be used to protect a pattern beginning with
              “-”.
```

* Multiple character option with single -

```bash
$ ch find -mtime
       find - search for files in a directory hierarchy

       -mtime n
              File's  data  was last modified n*24 hours ago.  See the comments for -atime to understand how rounding
              affects the interpretation of file modification times.
```

* `man` pages with short and long option both starting with single -

```bash
$ ch rename -verbose -n
       rename - renames multiple files

       -v, -verbose
               Verbose: print names of files successfully renamed.
       -n, -nono
               No action: print names of files to be renamed, but don't rename.
```

* Multiple arguments

```bash
$ ch grep -l -ro
       grep, egrep, fgrep, rgrep - print lines matching a pattern

       -l, --files-with-matches
              Suppress normal output; instead print the name of each input file from which output would normally have
              been printed.  The scanning will stop on the first match.
       -r, --recursive
              Read  all  files  under  each  directory, recursively, following symbolic links only if they are on the
              command line.  Note that if no file operand is given, grep searches the  working  directory.   This  is
              equivalent to the -d recurse option.

       -o, --only-matching
              Print  only  the matched (non-empty) parts of a matching line, with each such part on a separate output
              line.
```

* Short and Long options spread over two lines

```bash
$ ch wget -o
       Wget - The non-interactive network downloader.

       -o logfile
       --output-file=logfile
           Log all messages to logfile.  The messages are normally reported to standard error.
```

* Word search

```bash
$ ch grep 'exit status'
       grep, egrep, fgrep, rgrep - print lines matching a pattern

              file name wildcard expansion and therefore  should  not  be  treated  as  options.   This  behavior  is
              available only with the GNU C library, and only when POSIXLY_CORRECT is not set.

EXIT STATUS
       Normally  the exit status is 0 if a line is selected, 1 if no lines were selected, and 2 if an error occurred.
       However, if the -q or --quiet or --silent is used and a line is selected, the exit status  is  0  even  if  an
       error occurred.

COPYRIGHT

$ ch sed NUL
       sed - stream editor for filtering and transforming text


       -z, --null-data

              separate lines by NUL characters

       --help
              display this help and exit
```

<br>

### <a name="known-issues"></a>Known Issues

* option description spread over multiple lines

```bash
$ ch find -type
       find - search for files in a directory hierarchy

       -type c
              File is of type c:
              
$ # ideally, it should be
       find - search for files in a directory hierarchy
       
       -type c
              File is of type c:

              b      block (buffered) special

              c      character (unbuffered) special

              d      directory

              p      named pipe (FIFO)

              f      regular file

              l      symbolic link; this is never true if the -L option or the -follow option is  in  effect,  unless
                     the symbolic link is broken.  If you want to search for symbolic links when -L is in effect, use
                     -xtype.

              s      socket

              D      door (Solaris)
```

* special characters

```bash
$ # should have extracted only option line
$ ch printf %b
    printf - Formats and prints ARGUMENTS under control of the FORMAT.

      %b	expand backslash escape sequences in the corresponding argument
      %q	quote the argument in a way that can be reused as shell input
      %(fmt)T output the date-time string resulting from using FMT as a format
            string for strftime(3)
```

* option matching text of another option description

```bash
$ # depends on width of terminal, this issue seen on 120 as width
$ ch sort -V
       sort - sort lines of text files

              -V
	      
$ # the issue is because another line happened to start with `-V` before the `-V` option definition
$ ch sort version-sort
       sort - sort lines of text files

              sort  according to WORD: general-numeric -g, human-numeric -h, month -M, numeric -n, random -R, version
              -V

       -V, --version-sort
              natural sort of (version) numbers within text

       Other options:
```

<br>

### <a name="wish-list"></a>Wish list

* Script to automatically check that newer changes don't break working cases (Done)
* Error message for wrong usage (command not found done)
* Colored/Formatted output
* Extract section wise
* Edge cases
	* **\a** ; **%%** etc for `printf`
	* **-f, -force** ; **-n, -nono** etc for `perl` based `rename` (Done)
* Command examples
* Try out [groff](https://unix.stackexchange.com/questions/15855/how-to-dump-a-man-page/15859#15859) as suggested by [@Wildcard](https://unix.stackexchange.com/users/135943/wildcard)
* Portable script to work on different flavors of Linux, possibly Unix variants too

<br>

### <a name="license"></a>License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)
