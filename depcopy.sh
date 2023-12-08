#!/bin/bash

function view_help(){
	echo "Usage:	$0 [BINARY], or $0 [ARGUMENT]"
	echo "Copy all libraries that specified [BINARY] is dependent on to current working folder."
	echo ""
	echo "Special arguments that can be used in place of [ARGUMENT]:"
	echo "	--deps		print names of programs whose this script is dependent on"
	echo "	--help		print this help file"
	echo ""
	echo "[BINARY] can be relative or absolute path to a binary that MUST be dynamically linked,"
	echo "otherwise the script will fail with error message."
	echo ""
	echo "Anything in place of first entered argument - [BINARY]/[ARGUMENT]"
	echo "that is not one of those arguments defined in this help file will be"
	echo "processed as pathname."
}
function view_status(){
	echo "this feature is comming soon"
}
function view_dependencies(){
	echo "readelf"
	echo "ldd"
	echo "find"
	echo "awk"
	echo "tr"
}




# check if there are any arguments inserted
if test $# == 0; then
	echo "no arguments entered"
	echo "run $0 --help to show usage"
	exit
fi

# check if $1 is one of check functions
case $1 in
	"--status")
		view_status
		exit
		;;
	"--deps")
		view_dependencies
		exit
		;;
	"--help")
		view_help
		exit
		;;
esac





# if not one of above, $1 is program pathname - either absolute or relative

# now we need to check if program exists
EXECUTABLE=$(find $1 2> /dev/null)
if test "$EXECUTABLE" != "$1"; then
	echo "program at path \"$1\" not found"
	exit
fi

# and if it is dynamically linked
EXECUTABLE_TYPE=$(readelf -h $1 | tr -s ' ' | awk '/Type/ {print $2}')
if test "$EXECUTABLE_TYPE" != "DYN"; then
	echo "this executable is not dynamically linked, and thus this script cannot copy dependencies for it"
	exit
fi





# read list of all linked libraries
declare -a DEP_PATHS
read -a DEP_PATHS <<< $(ldd $1 | awk '/=>/ {print $3}' | tr '\n' ' ')

# now list through list of libraries and copy them to current working directory
for I in ${DEP_PATHS[@]}
do
	cp $I ./
done



unset $EXECUTABLE
unset $EXECUTABLE_TYPE
