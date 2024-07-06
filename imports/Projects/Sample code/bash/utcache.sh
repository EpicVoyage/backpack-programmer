#!/bin/sh
# Written by Daga <daga@daga.dyndns.org>
# Released under the terms of the GNU license agreement.

# Usage information - Shown if no parameters are passed
if [ ! "$1" ]; then
	echo "Usage: $0 Cache_Dir UT_PATH"
	echo
	echo " This script should move files from Cache_Dir to their proper"
	echo " sub-paths in UT_PATH"
	echo
	exit
fi

# Set up variables with the paths we need
CACHE=$1
UT_PATH=$2
if [ "`echo ${CACHE} | tail -c 2`" != "/" ]; then
	CACHE=${CACHE}/
fi
if [ "`echo ${UT_PATH} | tail -c 2`" != "/" ]; then
	UT_PATH=${UT_PATH}/
fi

# Process each line in a while loop
cut -d= -f1,2 ${CACHE}cache.ini | while read LINE
do
	# if the line does not start with a [
	if [ "`echo ${LINE} | head -c 1`" != "[" ]; then
	{
		HASH=`echo ${LINE} | cut -d= -f1 -`
		FILE=`echo ${LINE} | cut -d= -f2 -`

		SUB="`echo ${FILE} | tail -c 5 | head -c 3`"
		if [ "${SUB}" == "unr" ]; then
			SUB="Maps/";
		elif [ "${SUB}" == "utx" ]; then
			SUB="Textures/";
		elif [ "${SUB}" == "umx" ]; then
			SUB="Music/";
		elif [ "${SUB}" == "uax" ]; then
			SUB="Sounds/";
		else
			SUB="System/";
		fi
		
		echo "${HASH}.uxx => ${SUB}${FILE}"
		mv ${CACHE}${HASH}.uxx ${UT_PATH}${SUB}${FILE}
	}
	fi
done

