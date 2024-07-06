#!/bin/sh
# This script ($0!) will download the various components of the Backpack
# Programmer's LiveCD/DVD for you. It is recommended that you run it as root
# so that we can use installpkg and mkfs
#
# Credits:
#     Some ideas and code borrowed from Thomas M. of linux-live.org
#     The Dropline Gnome team for an awesome job on building Gnome
#     Patrick and those who make Slackware a reality
#     Linus for creating an open-source *nix kernel
#     God for making this universe
#     (I guess that's about as high up as we can go...)
#
# This work Copyright 2006 Daga <daga@daga.dyndns.org>
# Available under the terms of the GNU GPL v2

bits=32
#bits=64

# Where we should look for an up-to-date list of Dropline packages
DroplineFilesVersion='DroplineFiles2.16'
GetDroplineFilesVersion32="http://droplinegnome.org/$DroplineFilesVersion"

# Hopefully we'll get to Slamd64 sometime soon:
#DroplineFilesVersion='DroplineFiles2.14'
GetDroplineFilesVersion64="http://dlg64.droplinegnome.org/${DroplineFilesVersion}_x86_64"

# Uncomment the mirror closest to you
DROPLINE_MIRROR32='http://switch.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://internap.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://voxel.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://belnet.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://mesh.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://heanet.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://optusnet.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://ovh.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://puzzle.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://kent.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://jaist.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://umn.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://unc.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://aleron.dl.sourceforge.net/sourceforge/dropline-gnome/'
#DROPLINE_MIRROR32='http://osdn.dl.sourceforge.net/sourceforge/dropline-gnome/'

DROPLINE_MIRROR64='http://dlg64.droplinegnome.org/'

# Uncomment the mirror closest to you (or add one of your own)
SLACKWARE_MIRROR32='http://mirror.switch.ch/ftp/mirror/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://mirror.pacific.net.au/linux/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://ftp.riken.jp/Linux/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://ftp.gwdg.de/pub/linux/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://www.mirror.ac.uk/mirror/ftp.slackware.com/slackware-11.0/'
#SLACKWARE_MIRROR32='http://ftp.iasi.roedu.net/mirrors/ftp.slackware.com/slackware-11.0/'
#SLACKWARE_MIRROR32='http://carroll.cac.psu.edu/pub/linux/distributions/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://slackware.osuosl.org/slackware-11.0/'
#SLACKWARE_MIRROR32='http://mirrors.usc.edu/pub/linux/distributions/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://slackware.perespim.ru/pub/slackware-11.0/'
#SLACKWARE_MIRROR32='http://ftp.ntua.gr/pub/linux/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://darkstar.ist.utl.pt/slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://ftp.isu.edu.tw/pub/Linux/Slackware/slackware-11.0/'
#SLACKWARE_MIRROR32='http://slackware.cs.utah.edu/slackware-11.0/'
#SLACKWARE_MIRROR32=''

#SLACKWARE_MIRROR64='http://darkstar.ist.utl.pt/pub/slamd64/slamd64-11.0/'
SLACKWARE_MIRROR64='http://ftp.scarlet.be/pub/slamd64/slamd64-11.0/'

SWORD_MIRROR='ftp://ftp.crosswire.org/pub/sword/packages/rawzip/'

# Miscellaneous settings for live-cd
RELEASE='0.5'
RAMSIZE=9999
UNIONFS='1.3'

###################################################################
# You should be able to ignore most everything below this line... #
# In fact, if you are scared of magic, DON'T read below this.     #
###################################################################

# Variables used internally
EXIT=0
FAST=0
SLEEP=5
VERIFY=0
PACKAGE=0
TESTING=''
CWD="`pwd`"

# Create a distribution (backup) tarball of this directory?
if [ "$1" == "--package" -o "$1" == "--backup" ]; then
	rm backpack.tar backpack-scripts.tar backpack.tar.bz2 backpack-scripts.tar.bz2 2>/dev/null

	echo "Creating backpack.tar.bz2..."
	(cd ..;tar -cf backpack/backpack.tar backpack/{base,imports,modules/{*.txt,*.sh},extra*/urls.txt,extra*/*daga.tgz,iso/*.txt,squashfs-tools,unionfs-$UNIONFS,compile.sh,README})
	tar --delete -f backpack.tar backpack/squashfs-tools/{*.o,mksquashfs,unsquashfs}
	bzip2 -9 backpack.tar
	
	echo "Creating backpack-scripts.tar.bz2..."
	(cd ..;tar -cf backpack/backpack-scripts.tar backpack/{base,imports,modules/{*.txt,*.sh},extra*/urls.txt,iso/*.txt,squashfs-tools,unionfs-$UNIONFS,compile.sh,README})
	tar --delete -f backpack-scripts.tar backpack/squashfs-tools/{*.o,mksquashfs,unsquashfs}
	bzip2 -9 backpack-scripts.tar

	echo -e "Finished.\n"
	PACKAGE=1
	EXIT=1
fi

# Are all required mirrors defined?
if [ -z "$DROPLINE_MIRROR32" -a -z "$DROPLINE_MIRROR64" -a $PACKAGE -eq 0 ]; then
	echo "ERROR: Please open $0 in your favorite text editor uncomment or add a"
	echo "Dropline mirror to download from."
	echo
	SLEEP=0
	EXIT=1
fi

if [ -z "$SLACKWARE_MIRROR32" -a -z "$SLACKWARE_MIRROR64" -a $PACKAGE -eq 0 ]; then
	echo "ERROR: Please open $0 in your favorite text editor uncomment or add a"
	echo "Slackware mirror to download from."
	echo
	SLEEP=0
	EXIT=1
fi

# Don't sleep if they are requesting help
if [ "$1" == "--help" -o "$1" == "-h" ]; then
	SLEEP=0
	EXIT=1
fi

# Check if we are running as root (we should be)
if [ $UID -gt 0 -a $PACKAGE -eq 0 ]; then
	echo "WARNING: It is highly recommended that you press ctrl+c and run $0"
	echo "as root. This program will continue in $SLEEP seconds, but will only be"
	echo "able to download and verify that packages exist. Module creation will be"
	echo "impossible."
	echo
	sleep $SLEEP
fi

# Print help and exit?
if [ "$1" == "--help" -o "$1" == "-h" ]; then
	echo "$0 [--help|--package|--verify|--fast|--fast module-name]"
	echo "    --help    This screen."
	echo "    --package Create a tarball of the required directories in order to"
	echo "              distribute this script."
	echo "    --verify  Check packages used and unused for modules"
	echo "    --fast    Do not overwrite existing modules. If a module is named,"
	echo "              delete and recreate it."
	echo
fi

if [ $EXIT == 1 ]; then
	exit
fi

# Quick (skip unnecessary module builds) mode?
if [ "$1" == "--fast" -o "$1" == "--quick" ]; then
	echo "Fast mode enabled. Skipping modules which already exist."
	if [ -n "$2" ]; then
		BASENAME="`basename $2 .mo`.mo"
		echo "    ** REMOVING ${BASENAME}"
		rm -r modules/${BASENAME} 2>/dev/null
	fi
	
	echo
	FAST=1
	TESTING='-N'
fi

# Quick (skip unnecessary module builds) mode?
if [ "$1" == "--verify" -o $UID -gt 0 ]; then
	echo "Verify mode enabled. Only checking to see if all packages are present."
	echo
	VERIFY=1
	TESTING='-N'
fi

START=`date +%s`

if [ "$bits" == '64' ]; then
	GetDroplineFilesVersion=$GetDroplineFilesVersion64
	SLACKWARE_MIRROR=$SLACKWARE_MIRROR64
	DROPLINE_MIRROR=$DROPLINE_MIRROR64

	if [ -z "$GetDroplineFilesVersion" -o -z "$SLACKWARE_MIRROR" -o -z "$DROPLINE_MIRROR" ]; then
		echo "Please make sure \$GetDroplineFilesVersion64, \$SLACKWARE_MIRROR64, and \$DROPLINE_MIRROR64"
		echo "are defined and rerun $0"
		echo
		exit
	fi
else
	GetDroplineFilesVersion=$GetDroplineFilesVersion32
	SLACKWARE_MIRROR=$SLACKWARE_MIRROR32
	DROPLINE_MIRROR=$DROPLINE_MIRROR32

	if [ -z "$GetDroplineFilesVersion" -o -z "$SLACKWARE_MIRROR" -o -z "$DROPLINE_MIRROR" ]; then
		echo "Please make sure \$GetDroplineFilesVersion32, \$SLACKWARE_MIRROR32, and \$DROPLINE_MIRROR32"
		echo "are defined and rerun $0"
		echo
		exit
	fi
fi

# Directories we save files to
rm -r logs/* 2>/dev/null
echo -n '0'>logs/TEMPSIZE
mkdir -p squashfs-tools slackware$bits dropline$bits extra$bits sword logs modules

echo "Making sure we have a clean environment..."
mount|grep `pwd`/squash|cut '-d ' -f 1 | while read LINE; do
	echo "    ** Found SquashFS module `basename $LINE` mounted. Unmounting..."
	umount -l $LINE
done

mount|grep `pwd`/union | while read LINE; do
	echo "    ** One of our UnionFS instances was mounted. Unmounting..."
	umount -l `pwd`/union
done
rm -r temp union squash 2>/dev/null

# Compile squashfs for the current user's system
if [ $FAST -eq 0 -o ! -e "squashfs-tools/mksquashfs" ]; then
	echo "Compiling SquashFS tools for this system..."
	rm squashfs-tools/*.o squashfs-tools/mksquashfs squashfs-tools/unsquashfs 2>/dev/null
	cd squashfs-tools &&
	make >$CWD/logs/squashfs-tools.log 2>&1

	if [ $? -gt 0 ]; then
		cd $CWD
		echo -e "\nAn error occurred while compiling the mksquashfs utility."
		echo -e "Please check logs/squashfs-tools.log for more information.\n"
		exit
	fi
	cd $CWD
fi

# Compile unionfs for the current user's system
if [ $FAST -eq 0 -o ! -e "unionfs-$UNIONFS/utils/unionctl" ]; then
	echo "Compiling UnionFS tools for this system..."
	rm unionfs-$UNIONFS/utils/*.o unionfs-$UNIONFS/utils/unionctl unionfs-$UNIONFS/utils/uniondbg 2>/dev/null
	cd unionfs-$UNIONFS &&
	make >$CWD/logs/unionfs-tools.log 2>&1 # unionctl uniondbg

	if [ $? -gt 0 ]; then
		cd $CWD
		echo -e "\nAn error occurred while compiling the unionctl and uniondbg"
		echo "utilities. Please check logs/unionfs-tools.log for more"
		echo -e "information\n"
		exit
	fi
	cd $CWD
fi

# Compile installwatch for the current user's system
#if [ $FAST -eq 0 -o ! -e "installwatch/installwatch.so" ]; then
#	echo "Compiling installwatch for this system..."
#	rm installwatch/*.o installwatch/*.so 2>/dev/null
#	cd installwatch &&
#	make >$CWD/logs/installwatch.log 2>&1 &&
#	cd $CWD
#
#	if [ $? -gt 0 ]; then
#		echo -e "\nAn error occurred while compiling installwatch. Please"
#		echo -e "check logs/installwatch.log for more information\n"
#		exit
#	fi
#fi

echo -e "\nDownloading $DroplineFilesVersion..."
wget -nd -nH $TESTING -O dropline$bits/$DroplineFilesVersion $GetDroplineFilesVersion >logs/wget.log 2>&1

cat dropline$bits/$DroplineFilesVersion|grep ':replaced:'|cut -d: -s -f 1| while read LINE; do
	if [ -n "$LINE" -a -e "dropline$bits/${LINE}" ]; then
		echo "    *** REMOVING obsolete $LINE"
		rm dropline$bits/$LINE 2>/dev/null
	fi
done

echo "Processing $DroplineFilesVersion..."
cat dropline$bits/$DroplineFilesVersion|grep -v ':replaced:'|cut -d: -s -f 1| while read LINE; do
	if [ -n "$LINE" -a ! -e "dropline$bits/$LINE" ]; then
		echo "    --> dropline$bits/$LINE"
		DELETE=${LINE/\-[[:digit:]I].*}
		DELETE="`ls dropline$bits|grep -E ^${DELETE}\-[[:digit:]I]`"
		if [ -n "$DELETE" ]; then
			echo "    *** REMOVING $DELETE"
			rm dropline$bits/$DELETE
		fi
		wget -nv -nd -nH -nc -P dropline$bits "${DROPLINE_MIRROR}$LINE" >>logs/wget.log 2>&1
	fi
done

echo -e "\nDownloading Slackware file list..."
wget -nv -nd -nH $TESTING -O slackware$bits/FILELIST.TXT ${SLACKWARE_MIRROR}FILELIST.TXT >>logs/wget.log 2>&1
wget -nv -nd -nH $TESTING -O slackware$bits/PACKAGES.TXT ${SLACKWARE_MIRROR}PACKAGES.TXT >>logs/wget.log 2>&1

echo "Processing Slackware file list..."
cat slackware$bits/FILELIST.TXT|sed -e 's/^.*[[:space:]]\.\///g'|grep -E 'slackware'|grep 'tgz$'>slackware$bits/TOGRAB.TXT
cat slackware$bits/TOGRAB.TXT | while read LINE; do
	BASENAME="`basename $LINE`"
	TEMP=${BASENAME/\-[[:digit:]I].*}
	if [ -n "$TEMP" ]; then
		ls slackware$bits | grep -E ^${TEMP}\-[[:digit:]I] | while read DELETE; do
			if [ "$BASENAME" != "$DELETE" ]; then
				echo "    *** REMOVING $DELETE"
				rm slackware$bits/$DELETE
			fi
		done

		if [ ! -e "slackware$bits/$BASENAME" ]; then
			echo "    --> slackware$bits/$BASENAME"
			wget -nv -nd -nH -nc -P slackware$bits "${SLACKWARE_MIRROR}$LINE" >>logs/wget.log 2>&1
		fi
	fi
done

echo -e "\nProcessing extra$bits/urls.txt for extra$bits packages..."
cat extra$bits/urls.txt|grep -v -E '^[[:space:]]*#|^[[:space:]]*$'| while read LINE; do
	if [ -n "$LINE" -a "${LINE:1:1}" != '#' ]; then
		BASENAME="`basename $LINE`"
		if [ ! -e "extra$bits/${BASENAME}" ]; then
			DELETE=${BASENAME/\-[[:digit:]I].*}
			DELETE="`ls extra$bits|grep -E ${DELETE}\-[[:digit:]I]`"
			if [ -n "$DELETE" -a -e "$DELETE" ]; then
				echo "    *** REMOVING outdated extra$bits/${DELETE}"
				rm extra$bits/$DELETE 2>/dev/null
			fi

			echo "    --> Downloading extra$bits/${BASENAME}..."
			wget -nv -nd -nH -nc -P extra$bits "$LINE" >>logs/wget.log 2>&1
		fi
	fi
done

echo -e "\nProcessing sword modules..."
wget -r -nv -nd -nH -nc -l 1 -P sword $SWORD_MIRROR >>logs/wget.log 2>&1

echo -e "\nMaking sure we are building all modules..."
for i in modules/*.txt; do
	i="`basename $i .txt`"
	if [ -z "`grep ^$i$ modules/order.txt`" -a "$i" != "order" ]; then
		echo "$i">>modules/order.txt
	fi
done

if [ $VERIFY -eq 1 ]; then
	PACKAGES=(`ls {extra$bits,dropline$bits,slackware$bits}/*.tgz`)
	COUNT=${#PACKAGES[*]}

	# Look for packages that aren't being packed up...
	for i in modules/*.txt; do
		if [ "$i" = 'modules/order.txt' ]; then
			continue
		fi

		echo -e "\n*** Package list: $i"
		MASTER=(`cat "$i"|grep -v -E '^[[:space:]]*#|^[[:space:]]*$'`)


		if [ "$bits" == '32' ]; then
			MASTER=(${MASTER[*]/64:[^[:space:]]*})
		else
			MASTER=(${MASTER[*]/32:[^[:space:]]*})
		fi
		if [ "${FILE:0:6}" == 'EXTRA:' ]; then
			DIRS="extra$bits"
			FILE=(${FILE/EXTRA:})
		elif [ "${FILE:0:9}" = 'DROPLINE:' ]; then
			DIRS="dropline$bits"
			FILE=(${FILE/DROPLINE:})
		elif [ "${FILE:0:10}" = 'SLACKWARE:' ]; then
			DIRS="slackware$bits"
			FILE=(${FILE/SLACKWARE:})
		fi

		MASTER=(${MASTER[*]/IMPORT:[^[:space:]]*})
		MASTER=(${MASTER[*]/CMD:[^[:space:]]*})
		MASTER=(${MASTER[*]/SLACKWARE:})
		MASTER=(${MASTER[*]/DROPLINE:})
		MASTER=(${MASTER[*]/EXTRA:})
		MASTER=(${MASTER[*]/64:})
		MASTER=(${MASTER[*]/32:})
		SIZE=${#MASTER[*]}

		for (( y = 0 ; y < SIZE ; y++ )); do
			if [ "${MASTER[$y]:0:7}" == 'IGNORE:' ]; then
				MASTER[$y]="`echo ${MASTER[$y]}|cut -d: -f 2`"
				echo "    --> Removing ${MASTER[$y]} from list, ignored"
				PACKAGES=(${PACKAGES[*]/[^[:space:]]*\/${MASTER[$y]}\-[[:digit:]I][^[:space:]]*})
				unset MASTER[$y]
			elif [ -n "`echo ${PACKAGES[*]}|grep \/${MASTER[$y]}\-[[:digit:]I]`" ]; then
				echo "    --> Found ${MASTER[$y]}"
				PACKAGES=(${PACKAGES[*]/[^[:space:]]*\/${MASTER[$y]}\-[[:digit:]I][^[:space:]]*})
				unset MASTER[$y]
			fi
		done

		for (( y = 0 ; y < SIZE ; y++ )); do
			if [ -n "${MASTER[$y]}" ]; then
				echo "    --> Could not find ${MASTER[$y]}"
				EXIT=1
			fi
		done
	done

	# If there are any, print the name and exit
	COUNT=${#PACKAGES[*]}

	echo -e "\n\nPackages not used by modules ($COUNT):"
	for (( x = 0 ; x < COUNT ; x++ )); do
		if [ -n "${PACKAGES[$x]}" ]; then
			SIZE="`ls -lh ${PACKAGES[$x]}|sed -e 's/[[:space:]]\+/_/g'|cut -d_ -f 5`"
			echo "    ${PACKAGES[$x]} (${SIZE})"
		fi
	done

	# Exit if needed, otherwise, we're continuing
	if [ $EXIT == 1 ]; then
		echo -e "\nWe were unable to find one or more of the packages listed in module"
		echo -e "lists. Please scroll up to see what packages are missing.\n"
	else
		echo -e "\n\nAll required packages have been matched with files."
	fi

	exit
fi

if [ $UID -gt 0 ]; then
	echo "This is where the train stops. If you want to make the modules, please"
	echo -e "re-run this script as root\n"
	exit
else
	echo -e "Starting to add packages to modules..."
fi

if [ -z "`lsmod|grep unionfs`" -o -z "`lsmod|grep squashfs`" ]; then
	echo "    !!! WARNING: Please make sure UnionFS and SquashFS are loaded as"
	echo "    !!!          modules or compiled into the kernel."
fi

rm -r union temp squash 2>/dev/null
mkdir -p union temp squash
echo "    *** UnionFS is being mounted on union/ with changes sent to temp/"
ERROR="`mount -t unionfs -o dirs=temp=rw unionfs union 2>&1`"
if [ $? -ne 0 ]; then
	echo -e "        !!! ERROR: $ERROR\n"
	exit
fi
echo

MAX=0
STATS=0
GENERATED=0
cat modules/order.txt | while read i; do
	i="modules/`basename $i .txt`.txt"
	FILENAME="`basename $i .txt`.mo"
	MASTER=(`cat "$i"|grep -v -E '^[[:space:]]*#|^[[:space:]]*$'`)
	SIZE=${#MASTER[*]}

	if [ $FAST -eq 1 -a -e "modules/$FILENAME" ]; then
		if [ $GENERATED -gt 0 ]; then
			echo
			GENERATED=0
		fi
		echo "    *** Mounting $FILENAME..."
		mkdir -p squash/$FILENAME
		ERROR="`mount -t squashfs -o loop,ro modules/$FILENAME squash/$FILENAME 2>&1`"
		if [ $? -ne 0 ]; then
			echo "        !!! WARNING: $ERROR"
			rm -r squash/$FILENAME
		else
			ERROR="`unionfs-$UNIONFS/utils/unionctl union --add --after 0 --mode ro squash/$FILENAME 2>&1`"
			if [ $? -ne 0 ]; then
				echo "        !!! WARNING: unionctl: $ERROR"
			fi
		fi
		continue
	fi

	if [ ! -e union/dev/null ]; then
		mkdir -p union/dev
		mknod union/dev/null c 1 3
		chmod 666 union/dev/null
	fi

	echo -e "\nAdding these to $FILENAME:"
	GENERATED=1
	for (( x = 0 ; x < SIZE ; x++ )); do
		if [ "${MASTER[$x]:0:4}" == 'CMD:' ]; then
			WHAT=`echo ${MASTER[$x]:4}|sed -e 's/;;/ /g'`
			echo "    *** Command: ${WHAT}"
			(cd union; ${WHAT} 2>&1 | while read LINE; do echo "        --> Output: $LINE"; done)
		elif [ "${MASTER[$x]:0:7}" == 'IMPORT:' ]; then
			WHAT="imports/`echo ${MASTER[$x]:7}|sed -e 's/;;/ union\//g'`"
			echo "    *** Import: ${WHAT}"
			ERROR="`cp -a $WHAT 2>&1`"
			if [ -n "$ERROR" ]; then echo "        !!! Error: $ERROR"; fi
		elif [ "${MASTER[$x]:0:7}" == 'IGNORE:' ]; then
			# Yes, bandwidth theft. But easier on us :)
			WHAT="`echo ${MASTER[$x]}|cut -d: -f 3|sed -e 's/;;/ /g'`"
			if [ -z "$WHAT" ]; then
				WHAT='no reason given'
			fi
			echo "    *** Ignoring `echo ${MASTER[$x]}|cut -d: -f 2` ($WHAT)"
		else
			FILE=${MASTER[$x]}
			if [ "$bits" != '32' -a "${FILE:0:3}" == '32:' ]; then
				continue
			elif [ "$bits" != '64' -a "${FILE:0:3}" == '64:' ]; then
				continue
			fi
			FILE=(${FILE/32:})
			FILE=(${FILE/64:})
			DIRS="{slackware$bits,dropline$bits,extra$bits}"
			if [ "${FILE:0:6}" == 'EXTRA:' ]; then
				DIRS="extra$bits"
				FILE=(${FILE/EXTRA:})
			elif [ "${FILE:0:9}" = 'DROPLINE:' ]; then
				DIRS="dropline$bits"
				FILE=(${FILE/DROPLINE:})
			elif [ "${FILE:0:10}" = 'SLACKWARE:' ]; then
				DIRS="slackware$bits"
				FILE=(${FILE/SLACKWARE:})
			fi

			if [ `eval ls $DIRS/*.tgz 2>/dev/null|grep "\/${FILE}\-[[:digit:]I]"|wc -l` -gt 1 ]; then
				echo "    !!! Having to choose between these:"
				eval ls $DIRS/*.tgz 2>/dev/null|grep "\/${FILE}\-[[:digit:]I]" | while read LINE; do
					echo "        --> $LINE"
				done
			fi
			PACKAGE=`eval ls $DIRS/*.tgz 2>/dev/null|grep "\/${FILE}\-[[:digit:]I]"|tail -n 1`
			if [ -z "$PACKAGE" ]; then
				echo "    !!! Could not find package ${FILE}"
			else
				echo "    --> $PACKAGE"
				if [ -x union/usr/bin/chroot -a -x union/sbin/installpkg ]; then
					mkdir -p union/tmp
					cp $PACKAGE union/tmp/`basename $PACKAGE`
					#chroot union installwatch installpkg tmp/`basename $PACKAGE` 2>&1 >>logs/packages | while read LINE; do
					chroot union installpkg tmp/`basename $PACKAGE` 2>&1 >>logs/packages | while read LINE; do
						echo "        !!! $LINE"
					done
					rm -f union/tmp/*.tgz
				else
					#if [ ! -e "union/usr/lib/installwatch.so" ]; then
					#	mkdir -p union/usr/{lib,bin}
					#	cp installwatch/installwatch.so union/usr/lib/
					#	cp installwatch/installwatch union/usr/bin/
					#fi
					installpkg -root ./union $PACKAGE 2>&1 >>logs/packages | while read LINE; do
						echo "        !!! $LINE"
					done
				fi
			fi
		fi
	done

	echo "    *** Sanitizing some directory permissions..."
	for d in temp/*; do
		if [ "$d" != 'temp/*' -a "$d" != 'temp/tmp' -a "$d" != 'temp/root' ]; then
			chmod 0755 union/${d:5}
		fi
	done
	if [ -d temp/root ]; then
		chmod 0750 union/root 2>&1
	fi
	chmod 0777 union/tmp 2>&1

	echo "    *** Looking for new configuration files..."
	find union -name '*.new'|sed -e 's/\.new//' | while read LINE; do
		if [ -e $LINE ]; then
			echo "        --> Overwriting $LINE"
		else
			echo "        --> Found $LINE.new"
		fi
		mv -f $LINE.new $LINE
	done

	WHAT="`basename $i .txt`.sh"
	echo "    *** Attempting to execute modules/$WHAT"
	if [ -e "modules/$WHAT" ]; then
		(cd union;
		 env PS4='        --> ' sh -x $CWD/modules/$WHAT 2>&1 | while read LINE; do
		 	echo "           ==> $LINE";
		 done
		)
	else
		echo "        --> Not found (Don't Panic. You did bring your towel, right?)"
	fi

	WHAT="`basename $i .txt`-deps.log"
	rm logs/$WHAT 2>/dev/null
	mkdir -p union/var/log/packages
	echo "    *** Checking for missing dependencies (logs/$WHAT)..."
	find temp/ -perm -222 | sed -e 's/^temp//' | while read LINE; do
		if [ -z "$LINE" -o -L "$LINE" ]; then
			continue;
		fi
		
		FOUND=0
		chroot union /usr/bin/ldd $LINE 2>/dev/null | grep 'not found' | while read DEP; do
			if [ $FOUND -eq 0 ]; then
				echo "$LINE:">>logs/$WHAT
				LINE="`basename $LINE`"
				grep $LINE union/var/log/packages/* | cut -d: -f 1 | uniq | while read TEMP; do
					echo "    *** Required by: `basename $TEMP`">>logs/$WHAT
					FOUND=1
				done
				if [ $FOUND -eq 0 ]; then
					grep $LINE union/var/log/scripts/* | cut -d: -f 1 | uniq | while read TEMP; do
						echo "    *** Required by: `basename $TEMP`">>logs/$WHAT
					done
				fi
				FOUND=1
			fi
			echo "    $DEP">>logs/$WHAT
		done
	done

	echo "    *** Creating module file listing..."
	(cd temp; tree -aRifF -ugsD > $CWD/logs/$FILENAME.FILES)
	cp logs/$FILENAME.FILES union/var/log/

	echo "    *** Packing everything up..."
	rm modules/$FILENAME 2>/dev/null
	squashfs-tools/mksquashfs temp modules/$FILENAME > logs/$FILENAME.log
	chmod -x modules/$FILENAME

	STATS=$(((`du --max-depth=0 temp 2>/dev/null|cut -f 1`/1024) + 1))
	SIZE="`ls -lh modules/$FILENAME|sed -e 's/[[:space:]]\+/_/g'|cut -d_ -f 5`"
	MAX=`cat logs/TEMPSIZE`
	if [ $MAX -lt $STATS ]; then MAX=$STATS; fi
	echo -n "$MAX">logs/TEMPSIZE
	echo "        --> Work area was ${STATS}M. It compressed to $SIZE."

	if [ ! -e modules/$FILENAME ]; then
		echo -e "\nError creating modules/$FILENAME!"
		echo -e "(if we knew why, we'd tell you)\n"
		exit
	fi

	echo "    *** Mounting $FILENAME..."
	mkdir -p squash/$FILENAME
	ERROR="`mount -t squashfs -o loop,ro modules/$FILENAME squash/$FILENAME 2>&1`"
	if [ $? -ne 0 ]; then
		echo "        !!! WARNING: $ERROR"
		rm -r squash/$FILENAME
	else
		ERROR="`unionfs-$UNIONFS/utils/unionctl union --add --after 0 --mode ro squash/$FILENAME 2>&1`"
		if [ $? -ne 0 ]; then
			echo "        !!! WARNING: unionctl: $ERROR"
		fi
	fi
	
	rm -r temp/*
done

if [ $GENERATED -eq 1 ]; then
	echo -e "\nFinished generating modules!"
else
	echo -e "\nAll required modules exist!"
fi
if [ $UID -gt 0 ]; then
	echo "This is the end of the line. Next time, please try the train marked \"UID 0\"."
	EXIT=1
fi

echo "    ** Unmounting UnionFS filesystem..."
for i in squash/*; do
	if [ "$i" != 'squash/*' ]; then
		unionfs-$UNIONFS/utils/unionctl --remove "$i" 2>/dev/null
	fi
done
umount union
for i in squash/*; do
	if [ "$i" != 'squash/*' ]; then
		umount "$i"
		rm -r "$i"
	fi
done

if [ $EXIT -ne 0 ]; then
	echo
	exit
fi

# Order of preference in kernel choices...
echo -e "\nFinding vmlinuz and creating the root of the CD..."
VMLINUZ=`ls extra$bits/kernel-*.tgz`
if [ -z "$VMLINUZ" ]; then VMLINUZ=`ls dropline$bits/kernel-*.tgz`; fi
if [ -z "$VMLINUZ" ]; then VMLINUZ=`ls slackware$bits/kernel-*.tgz`; fi

UNIONFS=`ls extra$bits/unionfs-*.tgz`
if [ -z "$UNIONFS" ]; then UNIONFS=`ls dropline$bits/unionfs-*.tgz`; fi
if [ -z "$UNIONFS" ]; then UNIONFS=`ls slackware$bits/unionfs-*.tgz`; fi

echo "    ** Creating working copy of CD in temp/iso-work..."
mkdir -p temp/iso-work/{base,modules,optional,rootcopy,boot}
cp -R base/cd-root/* temp/iso-work/ 2>&1

KERNEL="`echo $VMLINUZ|sed -e 's/^.*\-\([.[:digit:]I]\+\)\-.*$/\1/'`"
installpkg -root ./temp $VMLINUZ >/dev/null 2>&1
KERNEL="`ls -d temp/lib/modules/$KERNEL*`"
KERNEL="`basename $KERNEL`"
echo "    ** Kernel version is $KERNEL"

VMLINUZ="temp/boot/vmlinuz"
if [ -L "$VMLINUZ" ]; then
	VMLINUZ=`readlink -f $VMLINUZ`
fi
if [ ! -f "$VMLINUZ" ]; then
	echo -e "    ** Cannot find vmlinuz: $VMLINUZ!\n"
	exit 1
fi
CONFIG="temp/boot/config"
if [ -L "$CONFIG" ]; then
	CONFIG=`readlink -f $CONFIG`
fi
if [ ! -f "$CONFIG" ]; then
	echo -e "    ** Cannot find config: $CONFIG!\n"
	exit 1
fi

echo "    ** Found vmlinuz: `basename $VMLINUZ`"
cp $VMLINUZ temp/iso-work/boot/vmlinuz 2>&1

echo -e "\nCreating initramfs under temp/ramfs..."
rm -r temp/ramfs 2>/dev/null
mkdir -p temp/ramfs/{etc,boot,dev,bin,mnt,proc,lib,sbin,sys,tmp,var/log}

echo "    ** Device nodes..."
mknod temp/ramfs/dev/console c 5 1
mknod temp/ramfs/dev/null c 1 3
mknod temp/ramfs/dev/ram b 1 1
mknod temp/ramfs/dev/systty c 4 0
mknod temp/ramfs/dev/tty c 5 0

LOOP=63
while [ $LOOP -ge 0 ]; do
	mknod temp/ramfs/dev/tty$LOOP c 4 $LOOP
	let LOOP--
done

LOOP=255
while [ $LOOP -ge 0 ]; do
	mknod temp/ramfs/dev/loop$LOOP b 7 $LOOP
	let LOOP--
done

echo "    ** Copying utilities..."
touch temp/ramfs/etc/{fs,m}tab
cp -a base/ramfs/* modules/order.txt temp/ramfs 2>&1
chmod +x temp/ramfs/init

(cd temp/ramfs; ln -s bin sbin)
cat temp/ramfs/bin/busybox.links | while read LINE; do
	if [ "${LINE:1:4}" == 'sbin' ]; then
		(cd temp/ramfs/bin; ln -sf busybox ${LINE:6})
	else
		(cd temp/ramfs/bin; ln -sf busybox ${LINE:5})
	fi
done
rm temp/ramfs/bin/busybox.links

echo "    ** Copying modules..."

copy_m()
{
	mkdir -p "$2"
	if [ -L "$1" ]; then
		REALPATH="`readlink -f \"$1\"`"
		cp -R "$REALPATH" "$2" 2>/dev/null
		ln -sf "$REALPATH" "$2/`basename $1`"
	else
		cp -R "$1" "$2" 2>/dev/null
	fi
	RET="$?"

	if [ -n "$CONFIG" ]; then
		if [ "$RET" -eq 0 ]; then MODE='module'; fi

		if [ "$RET" -ne 0 -a -n "`grep 'CONFIG_'$3'=y' $CONFIG`" ]; then
			MODE='built-in'
			RET=0
		fi

		if [ -z "$MODE" ]; then MODE="`grep CONFIG_$3= $CONFIG`"; fi
		if [ -z "$MODE" ]; then MODE="$3"; fi
		if [ -n "$MODE" ]; then MODE="($MODE)"; fi
	fi

	if [ "$RET" -ne 0 ]; then
		if [ -z "$CONFIG" ]; then
			echo "        !!! WARNING: Did not find `basename $1` and /boot/config was unavailable"
		else
			echo "        !!! WARNING: Did not find `basename $1` $MODE"
		fi
	else
		echo "        --> `basename $1` $MODE"
	fi
}

KERNELPATH="lib/modules/${KERNEL}/kernel"
# Required modules
copy_m temp/${KERNELPATH}/fs/unionfs temp/ramfs/${KERNELPATH}/fs
copy_m temp/${KERNELPATH}/fs/squashfs temp/ramfs/${KERNELPATH}/fs SQUASHFS

# File system support
copy_m temp/${KERNELPATH}/lib/zlib_inflate temp/ramfs/${KERNELPATH}/lib ZLIB_INFLATE
copy_m temp/${KERNELPATH}/drivers/block/loop* temp/ramfs/${KERNELPATH}/drivers/block BLK_DEV_LOOP

copy_m temp/${KERNELPATH}/fs/isofs temp/ramfs/${KERNELPATH}/fs ISO9660_FS
copy_m temp/${KERNELPATH}/fs/ext3 temp/ramfs/${KERNELPATH}/fs EXT3_FS
copy_m temp/${KERNELPATH}/fs/reiserfs temp/ramfs/${KERNELPATH}/fs REISERFS_FS
copy_m temp/${KERNELPATH}/fs/ntfs temp/ramfs/${KERNELPATH}/fs NTFS_FS
copy_m temp/${KERNELPATH}/fs/fat temp/ramfs/${KERNELPATH}/fs MSDOS_FS
copy_m temp/${KERNELPATH}/fs/vfat temp/ramfs/${KERNELPATH}/fs FAT_FS

# Language Support
copy_m temp/${KERNELPATH}/fs/nls temp/ramfs/${KERNELPATH}/fs NLS

# usb modules
copy_m temp/${KERNELPATH}/drivers/usb/storage temp/ramfs/${KERNELPATH}/drivers/usb USB_STORAGE
copy_m temp/${KERNELPATH}/drivers/usb/host/ehci-hcd* temp/ramfs/${KERNELPATH}/drivers/usb/host USB_EHCI_HCD
copy_m temp/${KERNELPATH}/drivers/usb/host/ohci-hcd* temp/ramfs/${KERNELPATH}/drivers/usb/host USB_OHCI_HCD
copy_m temp/${KERNELPATH}/drivers/usb/host/uhci-hcd* temp/ramfs/${KERNELPATH}/drivers/usb/host USB_UHCI_HCD

# disk access
copy_m temp/${KERNELPATH}/drivers/scsi temp/ramfs/${KERNELPATH}/drivers SCSI
copy_m temp/${KERNELPATH}/drivers/sata temp/ramfs/${KERNELPATH}/drivers SCSI_SATA
copy_m temp/${KERNELPATH}/drivers/ide temp/ramfs/${KERNELPATH}/drivers IDE_GENERIC
copy_m temp/${KERNELPATH}/drivers/pcmcia temp/ramfs/${KERNELPATH}/drivers PCMCIA

echo "    ** Compressing modules..."
find temp/ramfs -name "*.ko"|xargs -r gzip --best

echo "    ** Generating dependency files..."
depmod -b temp/ramfs ${KERNEL}

echo "    ** Creating initramfs..."
(cd temp/ramfs; find .|cpio --quiet -o -H newc|gzip -9 >$CWD/temp/iso-work/boot/ramfs.gz)

(cd modules; ls *.mo > $CWD/iso/dvd.txt)

for i in iso/*.txt; do
	WHAT="`basename $i .txt`"
	MASTER=(`cat "$i"`)
	SIZE=${#MASTER[*]}

	echo "    ** Compiling iso/backpack-$WHAT-$RELEASE-beta.iso"
	rm -r temp/iso-work/base/* 2>/dev/null
	for (( x = 0 ; x < SIZE ; x++ )); do
		echo "        --> Adding ${MASTER[$x]}"
		ln -n modules/${MASTER[$x]} temp/iso-work/base/
	done

	(cd temp/iso-work; ./make_iso.sh $CWD/iso/backpack-$WHAT-$RELEASE-beta.iso >$CWD/logs/make-iso-$WHAT.log 2>&1)

	echo "        --> Generating MD5 sum of image..."
	(cd iso; md5sum backpack-$WHAT-$RELEASE-beta.iso >backpack-$WHAT-$RELEASE-beta.iso.md5)

	echo "        --> Generating Torrent file..."
	(cd iso; maketorrent-console http://daga.dyndns.org:6969/announce "backpack-$WHAT-$RELEASE-beta.iso" >/dev/null)
	
	MD5="`cut -d' ' -f 1 iso/backpack-$WHAT-$RELEASE-beta.iso.md5`"
	SIZE="`ls -lh iso/backpack-$WHAT-$RELEASE-beta.iso|sed -e 's/[[:space:]]\+/_/g'|cut -d_ -f 5`"
	echo -e "        --> Size: $SIZE, MD5 sum: $MD5\n"
done

# Cleanup and tell the user we've made it
if [ "$FAST" -eq 0 ]; then
	echo "    ** Cleaning up..."
	rm -r temp union squash
fi

SIZE=0
COUNT=0
du --max-depth=0 slackware$bits dropline$bits extra$bits sword 2>/dev/null | cut -f 1 | while read LINE; do
	if [ -n "$LINE" ]; then
		let COUNT++
		SIZE=$((SIZE + LINE))
	fi
	if [ "$COUNT" = 4 ]; then
		echo -e "\n    ** STATS: Downloaded packages use: $(($SIZE / 1024))M"
	fi
done

MAX="`cat logs/TEMPSIZE`"
rm logs/TEMPSIZE
let MAX++
if [ "$MAX" -ne 1 ]; then echo "    ** STATS: Disk space used temporarily: ${MAX}M"; fi
echo "    ** STATS: Total disk space used by build: $(($MAX + (`du --max-depth=0 . 2>/dev/null|cut -f 1`/1024)))M"
END=`date +%s`
echo "    ** STATS: Build time was roughly $(((($END - $START) / 60) + 1)) minutes"

echo -e "\nCongratulations! Everything has been built. Please check the iso"
echo 'directory for your CD/DVD image(s).'
echo
