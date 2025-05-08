#!/bin/bash

###########################
# SCRIPT HELPER FUNCTIONS #
###########################
function view_help(){
	echo "Usage: $0 FILE [OPTION]..."
	echo "    -h,	--help		print this help and exit"
	echo "	--status	print version of various libraries and exit"
	echo "	--deps		print list of needed programs and exit"
	echo "	--dependencies	same as --deps"
	echo "    -b,	copy libraries to cwd, but with their absolute path kept"
	echo "    -c,	copy mode - action when copying file with existing filename"
	echo "		a - ask"
	echo "		o - overwrite"
	echo "		n - no-overwrite"
	echo ""
	echo "Binary for copying dependency libraries must be entered as first argument,"
	echo "otherwise the script won't recognize it as pathname."
	echo "It can be both relative or absolute path."
	echo ""
	echo "This script can exit either with success (0), or an error code:"
	echo "	1 - bad format of arguments"
	echo "	2 - dependency not found"
	echo "	3 - entered executable not found or type mismatch"

}
function view_status(){
	echo "this feature is comming soon"
}
function view_dependencies(){
	echo "List of binaries needed for this script: "	
	
	OK=1
	for DEP in ${DEPENDENCIES[@]}; do
		LOCATION=$(command -v $DEP 2> /dev/null)
		if test "$LOCATION" == ""; then
			LOCATION="not found"
			OK=0
		fi
		echo "	$DEP ($LOCATION)"
	done
	echo ""
	if test "$OK" == 0; then
		echo "Some binaries needed for this script are missing."
		echo "You need to install them onto your system for this script to work properly."
		echo "Refer to your distribution/package manager manual if you need help how to install those on your system."
	else
		echo "All needed binaries were found on this system,"
		echo "so this script should work properly."
	fi
}
############################




############################
# SCRIPT CONTROL VARIABLES #
############################
DEPENDENCIES=("readelf" "ldd" "find" "awk" "tr") # array of needed binaries for this script
ABSOLUTE_AS_RELATIVE=0 # whether keep binaries of libraries in their ablosute paths from /, but in current working dir (like ./lib/glibc.so, instead of ./glibc.so)
EXECUTABLE_BINARY=""
COPY_MODE="--interactive"
SYMLINK_FOLLOW_MODE="--dereference"
############################




##################
# INITIALIZATION #
##################
# ARGUMENT PROCESSING #
# check if there are any arguments inserted
if test $# == 0; then
	echo "no arguments entered" >&2
	echo "run $0 --help to show usage" >&2
	exit 1
fi
# check if $1 starts with a - (in this case it's not a pathname, but an arg)
if [[ $1 != "-"* ]]; then
	EXECUTABLE_BINARY="$1"
	shift
fi

# check short arguments, and then set control variables, or call helper functions
while getopts ":bhc:-:" optchar; do
	case ${optchar} in
		b)
			ABSOLUTE_AS_RELATIVE=1
			SYMLINK_FOLLOW_MODE="--copy-contents"
			;;
		h)
			view_help
			exit
			;;
		-)
			case ${OPTARG} in
				"help")
					view_help
					exit
					;;
				"status")
					view_status
					exit
					;;
				"deps")
					view_dependencies
					exit
					;;
				"dependencies")
					view_dependencies
					exit
					;;
				*)
					echo "Unknown argument \"--${OPTARG}\", run $0 --help for usage." 1>&2
					exit 1
					;;
			esac
			;;
			
		c)
			case ${OPTARG} in
				a)
					COPY_MODE="--interactive"
					;;
				o)
					COPY_MODE="--force"
					;;
				n)
					COPY_MODE="--no-clobber"
					;;
			esac
			;;
		?)
			echo "Unknown argument \"-${OPTARG}\", run $0 --help for usage." 1>&2
			exit 1
			;;
	esac
done

# DEPENDENCY CHECK #
# check if all dependencies are installed for this script
for DEP in ${DEPENDENCIES[@]}; do
	LOCATION=$(command -v $DEP 2> /dev/null)
	if test "$LOCATION" == ""; then
		echo "\"$DEP\" was not found in system's PATH, so it's probably not installed." >&2
		echo "To use this script you need to install it first." >&2
		echo "Consult your distro's manual how to do so." >&2
		echo "" >&2
		echo "To view status of all dependencies needed for this script," >&2
		echo "run $0 --deps" >&2
		exit 2
	fi
done
##################



################
# BINARY CHECK #
################
if test "$EXECUTABLE_BINARY" == ""; then
	echo "No executable entered in first position of arguments." >&2
	echo "Note that the pathname of program you want to copy dependencies for must be written in place of first argument." >&2
	exit 1
fi

# now we need to check if program exists
EXECUTABLE=$(find $EXECUTABLE_BINARY 2> /dev/null)
if test "$EXECUTABLE" != "$EXECUTABLE_BINARY"; then
	echo "program at path \"$EXECUTABLE_BINARY\" not found" >&2
	exit 3
fi
unset $EXECUTABLE

# and if it is dynamically linked
EXECUTABLE_TYPE=$(readelf -h $EXECUTABLE_BINARY | tr -s ' ' | awk '/Type/ {print $2}')
if test "$EXECUTABLE_TYPE" != "DYN"; then
	echo "this executable is not dynamically linked, and thus this script cannot copy dependencies for it" >&2
	exit 3
fi
unset $EXECUTABLE_TYPE
################



###############
# SCRIPT CORE #
###############
# read list of all linked libraries
declare -a DEP_PATHS
read -a DEP_PATHS <<< $(ldd $EXECUTABLE_BINARY | awk '/=>/ {print $3}' | tr '\n' ' ')

# now list through list of libraries and copy them to current working directory
DIRECTORIES="/"
ERROR="0"
for I in ${DEP_PATHS[@]}
do
	if test "$ABSOLUTE_AS_RELATIVE" == 1; then
		DIRECTORIES=$(awk -F'/' '{for(i=1; i<NF; i++){printf "%s/", $i}}' <<< $I)
		mkdir -p ".$DIRECTORIES";
		if test "$?" != "0"; then
			echo "Directory creation failed with error," >&2
			echo "ensure that you have proper permissions to write in this folder." >&2
			exit 4
		fi
	fi
	echo "copying: $I to .$(pwd)$DIRECTORIES"
	if test "$?" != "0"; then
		ERROR="1"
	fi
	cp "$I" ".$DIRECTORIES" "$COPY_MODE"
done
unset $DIRECTORIES
unset $ERROR

if test "$ERROR" == "0"; then
	echo "All linked libraries copied successfully."
else
	echo "Not all libraries were successfully copied."
	echo "Review errors above if any and/or check if all libraries"
	echo "needed for the program were copied."
fi
echo "Keep in mind that this script copies only dynamic libraries this app is dependent on."
echo "You may need to copy other application files - depending on your use case."
###############




########################
# CLEAN UP BEFORE EXIT #
########################
unset $EXECUTABLE_BINARY
unset $DEPENDENCIES
unset $ABSOLUTE_AS_RELATIVE
unset $COPY_MODE
unset $SYMLINK_FOLLOW_MODE
########################
