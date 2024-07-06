#!/bin/sh
# Port-knocking SCP shell
# Written by Daga <daga@daga.dyndns.org>

# Not much, but it is released under the terms of the GNU GPL v2

PORTS='1 2 3 4 5 6 7 8'  	# To knock on
PORT='26'			# To connect on

if [ -z "$2" ]; then 		# Print usage information for scp
	scp
	exit
fi

SERVER=''
for i in $@; do
	if [ -n "`echo $i|grep :`" ]; then
		SERVER="`echo $i|cut -d: -f 1`"
	fi
done

if [ -n "$SERVER" ]; then
	for i in $PORTS; do
		echo "Hitting port $i"
		nc -w 1 $SERVER $i
	done
fi
eval "scp -P $PORT $@"
