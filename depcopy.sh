#!/bin/bash

# read list of all linked libraries
declare -a DEP_PATHS
read -a DEP_PATHS <<< $(ldd $1 | column -t -s "=> (" -H 1 | awk  '{print $1}' | tr '\n' ' ')

# now list through list of libraries and copy them to current working directory
for I in ${DEP_PATHS[@]}
do
	cp $I ./
done
