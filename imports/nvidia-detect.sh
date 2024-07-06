#!/bin/sh

# The purpose of this script is to do the following:
#
#  1. Detect the presence of any nVidia-supported PCI/AGP video cards
#
#  TODO:
#  2. Check to see if the nVidia kernel drivers have been installed.
#  3. Check to see if the kernel-source package is present
#  4. Attempt to download the proper driver package to /var/lib/nvidia
#  5. Display the licence agreement and install the nvidia driver

#/lib/modules/`/bin/uname -r`/kernel/drivers/video/nvidia.ko

# Set this to 1 if you want this to be moderately verbose
DEBUG=1


# Be sure we have a PCI bus support (and some machines are headless)
/sbin/lspci >& /dev/null
if [ ! $? ] ; then
  # This machine has no PCI bus, and I'm fairly sure there aren't any ISA,
  # VLB, or EISA cards that are supported by the nVidia driver.
  if [ $DEBUG -ne 0 ]; then
    echo "No PCI bus detected."
  fi
  exit
fi


# Look for video cards with the nVidia vendor ID
BUSIDS=`/sbin/lspci -mn | awk '{ if ($3 == "0300\"") { if ($4 == "\"10de\"") print $1 }}'`
for item in $BUSIDS; do
  DETECTED=`/sbin/lspci | grep "^$item" | sed 's/.* VGA compatible controller: \(.*\)/\1/g'`
  if [ $DEBUG -ne 0 ]; then
    echo "Detected: $DETECTED"
  fi
done


unset BUSIDS
