#!/bin/bash
#
# run this script to create a LiveCD in /mnt/sda2/backpack.iso
# Your kernel image has to be in $ROOT/boot/vmlinuz or $ROOT/vmlinuz
# 

export PATH=.:./tools:../tools:/usr/sbin:/usr/bin:/sbin:/bin:/

CHANGEDIR="`dirname \`readlink -f $0\``"
echo "Changing current directory to $CHANGEDIR"
cd $CHANGEDIR

. ./config || exit 1
./install $ROOT

. liblinuxlive || exit 1

VMLINUZ=$ROOT/boot/vmlinuz
if [ -L "$VMLINUZ" ]; then VMLINUZ=`readlink -f $VMLINUZ`; fi
if [ "`ls $VMLINUZ 2>>$DEBUG`" = "" ]; then echo "cannot find $VMLINUZ"; exit 1; fi

header "Creating LiveCD!"
echo "some debug information can be found in $DEBUG"

mkdir -p $CDDATA/base
mkdir -p $CDDATA/modules
mkdir -p $CDDATA/optional
mkdir -p $CDDATA/rootcopy

echo "copying cd-root to $CDDATA, using kernel from $VMLINUZ"
echo "Using kernel modules from /lib/modules/$KERNEL"
cp -R cd-root/* $CDDATA
cp -R tools $CDDATA
cp -R !info/* $CDDATA
cp $VMLINUZ $CDDATA/boot/vmlinuz

echo "creating initrd image..."
cd initrd
./initrd_create
if [ "$?" -ne 0 ]; then exit; fi
cd ..

cp initrd/$INITRDIMG.gz $CDDATA/boot/initrd.gz
rm initrd/$INITRDIMG.gz

echo "creating compressed images..."

#for dir in bin boot etc home lib opt root usr sbin var; do
#    if [ -d $ROOT/$dir ]; then
#      echo "base/$dir.mo"
#      create_module $ROOT/$dir $CDDATA/base/$dir.mo -keep-as-directory
#      if [ $? -ne 0 ]; then exit; fi
#    fi
#done

cd packages
./makemo.sh $CDDATA/base
cd ..

echo "creating Backpack live-cd ISO image..."
cd $CDDATA
./make_iso.sh /mnt/sda2/backpack.iso

cd /tmp
header "Your ISO is created in /mnt/sda2/backpack.iso"
