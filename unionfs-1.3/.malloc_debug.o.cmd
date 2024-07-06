cmd_/mnt/backpack/unionfs-1.3/malloc_debug.o := gcc -Wp,-MD,/mnt/backpack/unionfs-1.3/.malloc_debug.o.d  -nostdinc -isystem /usr/lib/gcc/i486-slackware-linux/3.4.6/include -D__KERNEL__ -Iinclude  -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -O2 -fomit-frame-pointer -pipe -msoft-float -mpreferred-stack-boundary=2 -fno-unit-at-a-time -march=k8  -ffreestanding -Iinclude/asm-i386/mach-default -Wdeclaration-after-statement  -I/lib/modules/2.6.17.13/build/include -Wall -Werror  -g -O2 -DUNIONFS_VERSION=\"1.3\" -DSUP_MAJOR=2 -DSUP_MINOR=6 -DSUP_PATCH=17  -DMODULE -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(malloc_debug)"  -D"KBUILD_MODNAME=KBUILD_STR(unionfs)" -c -o /mnt/backpack/unionfs-1.3/malloc_debug.o /mnt/backpack/unionfs-1.3/malloc_debug.c

deps_/mnt/backpack/unionfs-1.3/malloc_debug.o := \
  /mnt/backpack/unionfs-1.3/malloc_debug.c \

/mnt/backpack/unionfs-1.3/malloc_debug.o: $(deps_/mnt/backpack/unionfs-1.3/malloc_debug.o)

$(deps_/mnt/backpack/unionfs-1.3/malloc_debug.o):
