#!/bin/sh

if [ $UID != 0 ]; then
  echo "Must run this script as root!"
  exit 1
fi

echo "General cleanups..."
rm -rf ~user/{.bash_history,.cache,.ssh,.recently-used,.xsession-errors}
rm -rf ~root/{.bash_history,.cache,.ssh,.recently-used,.xsession-errors}
rm -rf ~user/.mozilla/firefox/*/Cache/* ~user/.kde
rm -rf /var/log/Xorg* /var/log/btmp /var/log/cron* /var/log/debug* \
       /var/log/faillog* /var/log/lastlog* /var/log/maillog* \
       /var/log/messages* /var/log/scrollkeeper.log /var/log/secure* \
       /var/log/spooler* /var/log/syslog* /var/log/removed_* \
       /var/log/dmesg /var/cache/dropline-installer/*.tgz \
       live_data_* /usr/share/applications/sda2.desktop

echo "Updating module list and dependencies..."
depmod -a
/sbin/ldconfig

echo "Updating slocate database..."
slocate -u -e /mnt

echo "Removing the previous .iso..."
rm -r backpack*.iso

echo "Starting live-cd compilation..."
cd linux-live-5.1.6
./runme.sh
cd ..

echo "Starting version-specific stuff..."
mv backpack.iso backpack-0.3-beta.iso

echo "Generating md5sum..."
md5sum backpack-0.3-beta.iso>backpack-0.3-beta.iso.md5

echo "Creating torrent..."
maketorrent --tracker_name http://daga.dyndns.org:6969/announce --target backpack-0.3-beta.iso
