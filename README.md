# DepCopy
Linux dependency copy script

This simple script allows you to copy all .so libraries linked to a program to your current working directory. This feature is useful when you want to move a program from one distro to another one which has not all dependencies available for it.
Only one condition must be met: version of `glibc` on target system cannot be lower than the version on source system.

It uses `ldd` to fetch list of libraries, `readelf` to check whether executable is linked dynamically, `awk`/`tr` to process the output from ldd as string, and of course `bash` as interpreter.

## Usage
`./depcopy.sh FILE [OPTIONS]` < you can put path (relative or absolute) to any dynamic linked program you want in place of `FILE` and the script will copy all dynamic libraries linked to it to your current working directory.

It supports these arguments:
- `-h`|`--help`: print the help file
- `--deps`|`--dependencies`: print names of programs whose this script is dependent on and try to locate them (prints either absolute path, or `not found` string, so they can be easily tracked)
- `-b`|`--absolute`: copy libraries to current working directory, but keep their absolute paths (useful for easy copying on target system)

Executable file must be entered as first argument, otherwise the script won't recognize it as pathname. It can be both relative, or absolute path.
For arguments that it makes sense to be used without file arg (like `--help`, `--deps`, ...), FILE doesn't have to be entered and instead such arg as `--help` can be entered as first.

This script can exit either with success (0), or an error code:
- 1 - bad format of arguments
- 2 - dependency not found
- 3 - entered executable not found or type mismatch

## What is planned
- status arg that will print versions of various core libraries, like: glibc, x/wayland, gtk/qt...
- when source library is not found, write error message in the end specifying what libraries are missing
- copy mode argument: 
	- interactive
	- replace all
	- do not copy existing
- option for not copying library and its dependencies (entering filename of .so, or level)
- copy symlinks with their source files while keeping absolute path of both
