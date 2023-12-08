# DepCopy
Linux dependency copy script

This simple script allows you to copy all .so libraries linked to a program to your current working directory. This feature is useful when you want to move a program from one distro to another one which has not all dependencies available for it.
Only one condition must be met: version of `glibc` on target system cannot be lower than the version on source system.

It uses `find` to search for binaries, `ldd` to fetch list of libraries, `readelf` to check whether executable is linked dynamically, and `awk`/`tr` to process the output from ldd as string.

## Usage
`./depcopy.sh /bin/bash` < you can put path (relative or absolute) to any dynamic linked program you want in place of </bin/bash> and the script will copy all dynamic libraries linked to it to your current working directory.
or you can run it as `./depcopy.sh --argument`, where `--argument` can be:

`--deps`: print names of programs whose this script is dependent on

`--help`: print this help file

Anything in place of first entered argument that is not one of those arguments defined in this help file will be processed as pathname.

## What is planned
- status arg that will print versions of various core libraries, like: glibc, x/wayland, gtk/qt...
- dependency arg upgrade: print also if binaries are found with paths or not
- option for copying libraries to cwd, but with their absolute paths kept - instead of `./libc.so` it will be `./lib/x86_64-linux-gnu/libc.so` for example
- option for not copying library and its dependencies (entering filename of .so)
- option to generate launch script that uses `LD_LIBRARY_PATH` method for `ld-so` dynamic linker to search for libraries in application folder
