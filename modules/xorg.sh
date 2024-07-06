#!/bin/sh

# Patch inittab to auto-start Xorg
patch -p0 etc/inittab ../imports/inittab.patch
