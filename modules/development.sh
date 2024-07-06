#!/bin/sh

chown root:root usr/local/bin/javac
chmod 0755 usr/local/bin/javac

(cd home/user/Desktop; ln -s ../Projects/Sample\ code Sample\ code)
TEST="`ls -d /usr/doc/python-*|head -n 1`/Demo"
chroot . bin/ln -s $TEST /home/user/Projects/Sample\ code/Python

echo "<Location /server-status>"	>> etc/apache/httpd.conf
echo "    SetHandler server-status"	>> etc/apache/httpd.conf
echo "    Order deny,allow"		>> etc/apache/httpd.conf
echo "    Deny from all"		>> etc/apache/httpd.conf
echo "    Allow from 127.0.0.1"		>> etc/apache/httpd.conf
echo "</Location>"			>> etc/apache/httpd.conf
echo "<Location /server-info>"		>> etc/apache/httpd.conf
echo "    SetHandler server-info"	>> etc/apache/httpd.conf
echo "    Order deny,allow"		>> etc/apache/httpd.conf
echo "    Deny from all"		>> etc/apache/httpd.conf
echo "    Allow from 127.0.0.1"		>> etc/apache/httpd.conf
echo "</Location>"			>> etc/apache/httpd.conf
echo "Include /etc/apache/mod_php.conf" >> etc/apache/httpd.conf
