#!/bin/sh

mkdir -p usr/share/doc/howtos/byteofpython
unzip -qq ../extra32/byteofpython_html_120.zip -d usr/share/doc/howtos/byteofpython

mkdir -p usr/share/doc/howtos/apache
cp ../extra32/adr.pdf -d usr/share/doc/howtos/apache

mkdir -p usr/share/doc/howtos/cpp
unzip -qq ../extra32/TICPP-2nd-ed-Vol-one.zip -d usr/share/doc/howtos/cpp
unzip -qq ../extra32/TICPP-2nd-ed-Vol-two.zip -d usr/share/doc/howtos/cpp

mkdir -p usr/share/doc/howtos/java
unzip -qq ../extra32/TIJ-3rd-edition4.0.zip -d usr/share/doc/howtos/java
unzip -qq ../extra32/tutorial.zip -d usr/share/doc/howtos/java

mkdir -p usr/share/doc/howtos/php
tar -xzf ../extra32/php_manual_en.tar.gz --directory usr/share/doc/howtos/php

unzip -qq ../extra32/TIPatterns-0.9.zip -d usr/share/doc/howtos

chroot . bin/ln -s /usr/share/doc/howtos /home/user/Projects/Sample\ code
