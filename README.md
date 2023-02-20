# DepCopy
Linux dependency copy script

This simple script allows you to copy all .so libraries linked to a program to your current working directory. This feature is useful when you want to move a program from one distro to another one which has not all dependencies available for it.

It uses `ldd` to fetch list of libraries, and `awk`, `tr` and `column` to process the output from ldd as string.

## Usage
`./depcopy.sh /bin/bash` < you can put path to any dynamic linked program you want in place of </bin/bash> and the script will copy all dynamic libraries linked to it to your current working directory.

## What is planned
- better handling of non path strings from ldd, like: `not found`
- more complex parameter reading technique
- option for copying libraries to cwd, but with their absolute paths kept - instead of `./libc.so` it will be `./lib/x86_64-linux-gnu/libc.so` for example
- option for not copying the most basic libraries as:
  - level 1: libc, pthread... and other libraries from standard library collection
  - level 2: x window system and wayland libraries
  - level 3: most known gui libraries - gtk2/3/4, qt...
  - level 4: codecs for audio/video/pictures
- option to generate launch script that uses `LD_LIBRARY_PATH` method for `ld-so` dynamic linker to search for libraries in application folder
