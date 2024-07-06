# Makefile for the Linux 2.6 unionfs

# this should point to where your kernel headers are
KVERS?=$(shell uname -r)
MODDIR= /lib/modules/$(KVERS)
LINUXSRC = /lib/modules/$(KVERS)/build
TOPINC   = -I${LINUXSRC}/include
# This is where the make install target will put stuff
PREFIX   = /usr/local
MANDIR   = ${PREFIX}/man
MODPREFIX=
VERSION  = 1.3
SUP_MAJOR= 2
SUP_MINOR= 6
SUP_PATCH= 17
SUP_EXTRA=
TAROPTS = czvf
COMPEXT = .gz
UNIONFS_DEBUG_CFLAG = -g
UNIONFS_OPT_CFLAG= -O2
UNIONFS_VERSION_CFLAG=-DUNIONFS_VERSION=\"${VERSION}\" -DSUP_MAJOR=${SUP_MAJOR} -DSUP_MINOR=${SUP_MINOR} -DSUP_PATCH=${SUP_PATCH}

# allow custmom override of TOPINC for fistgen developers
# These options enable extended attribute support
#  EXTRACFLAGS=-DUNIONFS_XATTR
# Some kernels also require FIST_SETXATTR_CONSTVOID
#  EXTRACFLAGS=-DUNIONFS_XATTR -DFIST_SETXATTR_CONSTVOID
ifneq ($(FISTDEVMK),)
-include $(FISTDEVMK)
else
-include fistdev.mk
endif

CC	= gcc
KERNELVERSION=$(shell echo $(KVERS) | cut -d. -f1,2)
EXTRA_CFLAGS += ${TOPINC} -Wall -Werror ${EXTRACFLAGS} ${UNIONFS_DEBUG_CFLAG} ${UNIONFS_OPT_CFLAG} ${UNIONFS_VERSION_CFLAG}
UCFLAGS = -I. ${UNIONFS_DEBUG_CFLAG} ${UNIONFS_OPT_CFLAG} -Wall -Werror ${EXTRAUCFLAGS}  ${UNIONFS_VERSION_CFLAG}

obj-m := unionfs.o
unionfs-objs := subr.o dentry.o file.o inode.o main.o super.o \
	stale_inode.o branchman.o xattr.o rdstate.o copyup.o  \
	dirhelper.o rename.o unlink.o lookup.o persistent_inode.o \
	commonfops.o dirfops.o print.o malloc_debug.o mmap.o

all:	readthereadme unionfs.ko utils

readthereadme:
	@echo "******************************************************************************"
	@echo "If you have questions about or problems building Unionfs, please read INSTALL."
	@echo "******************************************************************************"
	@echo ""

unionfs.ko: FRC
	make -C ${LINUXSRC} SUBDIRS=$(PWD) FISTDEVMK=$(PWD)/fistdev.mk modules

FRC:

${obj-m}: ${unionfs-objs}
	${LD} -o ${obj-m} -r ${unionfs-objs}

memtest:
	perl match-malloc.pl log.txt

TAGS: $(wildcard *.[ch])
	etags -t $^

tags: $(wildcard *.[ch])
	ctags $^

clean:
	-make -C ${LINUXSRC} SUBDIRS=$(PWD) FISTDEVMK=$(PWD)/fistdev.mk clean
	rm -f ${unionfs-objs} ${obj-m} ${obj-m:.o=.ko} *.d .*.flags \#* *~
	rm -f TAGS tags
	rm -f unionfs-${VERSION}.tar${COMPEXT}
	make -C utils clean

kvers:
	@echo "This Unionfs release supports only Linux kernel version:"
	@echo "${SUP_MAJOR}.${SUP_MINOR}.${SUP_PATCH}${SUP_EXTRA}"

sparse:
	sparse $(patsubst, %.o, %.c, $(unionfs-objs)) ${EXTRA_CFLAGS} -D__KERNEL__

${unionfs-objs}: unionfs.h

utils: FRC
	make -C utils all CC=${CC} UCFLAGS='-I.. ${UCFLAGS}'

install-utils: utils
	make -C utils install PREFIX=${PREFIX}
	mkdir -p ${MANDIR}/man4
	mkdir -p ${MANDIR}/man8
	cp man/unionfs.4 ${MANDIR}/man4
	cp man/unionctl.8 ${MANDIR}/man8
	cp man/uniondbg.8 ${MANDIR}/man8
	cp man/unionimap.8 ${MANDIR}/man8

install-mod: unionfs.ko
	mkdir -p ${MODPREFIX}/${MODDIR}/kernel/fs/unionfs
	cp unionfs.ko ${MODPREFIX}/${MODDIR}/kernel/fs/unionfs
	-/sbin/depmod -a

install: install-utils install-mod

uninstall:
	rm ${MODPREFIX}/${MODDIR}/kernel/fs/unionfs.ko
	-/sbin/depmod -a
	rm ${MANDIR}/man8/unionctl.8
	rm ${MANDIR}/man8/uniondbg.8
	rm ${MANDIR}/man4/unionfs.4
	make -C utils uninstall PREFIX=${PREFIX}

release: unionfs-${VERSION}.tar${COMPEXT}

kernel-source-unionfs-${VERSION}.tar${COMPEXT}:
	mkdir kernel-source-unionfs-${VERSION}
	cp -a Makefile *.h *.c kernel-source-unionfs-${VERSION}
	subst "s/\(^all.*\)\(\${BINS}\)/\1/" kernel-source-unionfs-${VERSION}/Makefile
	tar ${TAROPTS} kernel-source-unionfs-${VERSION}.tar${COMPEXT} kernel-source-unionfs-${VERSION}

unionfs-${VERSION}.tar${COMPEXT}:
	mkdir unionfs-${VERSION}
	cp patch-kernel.sh Makefile.kernel COPYING AUTHORS README INSTALL NEWS BUGS ChangeLog doit.sh undoit.sh Makefile *.[ch] misc/snapmerge misc/match-*.pl unionfs-${VERSION}
	cp -r rpm debian unionfs-${VERSION}
	rm -rf unionfs-${VERSION}/rpm/CVS
	rm -rf unionfs-${VERSION}/debian/CVS
	mkdir unionfs-${VERSION}/regression
	mkdir unionfs-${VERSION}/regression/progs
	mkdir unionfs-${VERSION}/utils
	cp regression/Makefile regression/*.sh regression/ChangeLog regression/scaffold regression/README unionfs-${VERSION}/regression
	cp regression/progs/Makefile regression/progs/*.[ch] unionfs-${VERSION}/regression/progs
	cp utils/Makefile utils/*.[ch] unionfs-${VERSION}/utils
	mkdir unionfs-${VERSION}/man
	cp man/*.[0-9] unionfs-${VERSION}/man
	tar ${TAROPTS} unionfs-${VERSION}.tar${COMPEXT} unionfs-${VERSION}
	rm -rf unionfs-${VERSION}
