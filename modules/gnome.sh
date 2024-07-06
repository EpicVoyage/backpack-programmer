#!/bin/sh

#(cd etc/X11/xinit; ln -s xinitrc.gnome xinitrc)
chmod +x etc/rc.d/rc.udev

sed -e 's/\-D/\-D \-\-no\-chroot/g' etc/rc.d/rc.avahidaemon>etc/rc.d/rc.avahidaemon.new
cat etc/rc.d/rc.avahidaemon.new>etc/rc.d/rc.avahidaemon
rm etc/rc.d/rc.avahidaemon.new

#for i in etc/gconf/schemas/*.schemas; do
#  chroot . /usr/bin/env GCONF_CONFIG_SOURCE="xml::/etc/gconf/gconf.xml.defaults" /usr/bin/gconftool-2 --makefile-install-rule "/$i" >/dev/null
#done

gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders
