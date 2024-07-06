#!/bin/sh

mkdir -p usr/lib/codecs
tar -xjf ../extra32/all-20060501.tar.bz2 --directory usr/lib/codecs

# Just for the fun of it:
chroot . bin/ln -s /usr/lib/codecs /usr/lib/win32
