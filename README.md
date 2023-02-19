# DCopy
Linux dependency copy script
***
This simple script allows you to copy all .so libraries linked to a program to your current working directory. This feature is udeful when you want to move a program from one distro to another one, which has not all dependencies available for it.
***
It uses `ldd` to fetch list of libraries, and `awk`, `tr` and `column` to process the output from ldd as string.
***
## Usage
`./dcopy.sh /bin/bash` < you can put path to any dynamic linked program you want in place of </bin/bash> and the script will copy all dynamic libraries linked to it to your current working directory.
