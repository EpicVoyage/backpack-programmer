#!/bin/sh

# System and user settings
chroot . ln -s /home/user/.vimrc /root
cp usr/share/zoneinfo/GMT etc/localtime
echo 'usr/share/zoneinfo/GMT' > etc/localtime-copied-from
chroot . ln -sf /usr/share/zoneinfo/GMT /etc/localtime-copied-from
cat ../extra32/hosts|grep -vE '^#|localhost' >> etc/hosts

# Obsoleted by Slack 11.0?:
#chroot . ln -sf /etc/rc.d/rc.modules-2.6.16.16 /etc/rc.d/rc.modules

# Create the user
echo 'backpack.livecd'>etc/HOSTNAME
echo 'user:x:100:0:backpack user:/home/user:/bin/bash'>>etc/passwd
echo 'user::13090:0:99999:7:::'>>etc/shadow
chown 0:0 etc/sudoers etc/HOSTNAME
chmod 0440 etc/sudoers

# Permissions for the home directory
chown -R 100:0 home/user
chmod -R 0755 home home/user
ls -A home/user|grep -E '^\.'|while read FILE; do
	chmod -R 0700 home/user/$FILE
done

# Add the user to some groups :)
sed -e 's/^\(wheel\|bin\|sys\|adm\|disk\|lp\|floppy\|audio\|video\|cdrom\|games\|ftp\|pop\|users\|console\)\(:.*\)$/\1\2,user/g' etc/group>etc/group.new
cat etc/group.new>etc/group
rm etc/group.new

# Skip read-only check for virtual "harddrive"
# Oh, and silence module loading errors
sed -e 's/\(# Test to see if the root partition is read-only\)/if [ ! -e \/tmp\/livecd ]; then\n\1/g' etc/rc.d/rc.S>etc/rc.d/rc.S.new
sed -e 's/\(# Done checking root filesystem\)/\1\nfi # end of "if live-cd" block/g' etc/rc.d/rc.S.new>etc/rc.d/rc.S
sed -e 's/\(\. \/etc\/rc\.d\/rc\.modules.*\)/\1 2>\/dev\/null/g' etc/rc.d/rc.S>etc/rc.d/rc.S.new
cat etc/rc.d/rc.S.new>etc/rc.d/rc.S
rm etc/rc.d/rc.S.new

# Set up DHCP
sed -e 's/\(USE_DHCP\[\d+\]\)=""/\1="yes"/g' etc/rc.d/rc.inet1.conf>etc/rc.d/rc.inet1.conf.new
cat etc/rc.d/rc.inet1.conf.new>etc/rc.d/rc.inet1.conf
rm etc/rc.d/rc.inet1.conf.new

# Shutdown patches
patch -p0 etc/rc.d/rc.6 ../imports/rc.6.patch

# Make some scripts executable
chmod -x etc/rc.d/{rc.sshd,rc.font,rc.serial}
chmod +x usr/local/bin/*.sh

# Custom console title in Xorg
echo 'if [ "$PS1" == "\\u@\\h:\\w\\$ " -a "$TERM" != "linux" ]; then' >> etc/profile
echo ' export PS1="\[\033]2;\w - Backpack Programmer\007\]\u@\h:\w$ "' >> etc/profile
echo 'fi' >> etc/profile

# Making sure kernel modules play nicely
chroot . /sbin/depmod
