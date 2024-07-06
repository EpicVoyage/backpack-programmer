#!/bin/sh
# Written by Daga <daga@daga.dyndns.org>
# Released under the terms of the GNU License Agreement

if [ ! "$1" ]; then
  echo "Usage: $0 /mnt/newhome"
  echo
  echo "Make /mnt/newhome into a home directory that will be"
  echo "automatically mounted in the future when it is available."
  echo
  exit
fi

if [ -z "`cat /etc/mtab|grep $1`" ]; then
  echo "$1 is not a mounted partition!"
  echo
  echo "Try using just '$0' to obtain help"
  echo
  exit
fi

if [ ! -d $1 ]; then
  echo "$1 needs to be a directory!"
  echo
  exit
fi

if [ ! -w $1 ]; then
  echo "$1 is not writable! You may try 'mount -o remount,rw,exec $1'"
  echo
  exit
fi

echo "Copying user home to $1..."
cp -pLR /home/user/* $1 || echo "Oops, couldn't copy files..."; exit

SLASH=''
if [ "`echo $1|tail -c 2`" = "/" ]; then
  SLASH='/'
fi

touch $1$SLASH.backpacker

echo "Remounting $1 as /home/user..."
mount --move $1 /home/user

echo "Done."

