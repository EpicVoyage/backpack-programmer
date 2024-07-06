#!/bin/sh

for i in ../sword/*.zip; do
	if [[ ! "$i" =~ '\/(KJV|GerElb1905|FreLSG|SpaRV|StrongsGreek|StrongsHebrew).zip$' ]]; then
		unzip -qq $i -d usr/share/sword
	fi
done
