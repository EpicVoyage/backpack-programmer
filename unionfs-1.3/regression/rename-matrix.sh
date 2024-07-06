#!/bin/sh

# This file contains the most basic version of the rename matrix (see
# docs/rename.txt). It creates all the files/directories on the left most
# branch, and therefore never tests copyup. It is however useful to see the
# most basic operation succeed before diving into more complex scenarios

source scaffold

function beforefiles {
cat <<FILES
d $LOWER_DIR
d $LOWER_DIR/b0
f $LOWER_DIR/b0/s.file
d $LOWER_DIR/b0/s.dir
d $LOWER_DIR/b0/s.child
f $LOWER_DIR/b0/s.child/foo
d $LOWER_DIR/b0/s.wh
f $LOWER_DIR/b0/s.wh/.wh.foo
f $LOWER_DIR/b0/d.file
d $LOWER_DIR/b0/d.dir
d $LOWER_DIR/b0/d.child
f $LOWER_DIR/b0/d.child/foo
d $LOWER_DIR/b0/d.wh
f $LOWER_DIR/b0/d.wh/.wh.foo
FILES
}

function renamestr {
	EXPR1=`echo $1 | sed -e 's/\//\\\\\//g'`
	EXPR2=`echo $2 | sed -e 's/\//\\\\\//g'`

	echo "s/^\([a-zA-Z]\) $EXPR1/\1 $EXPR2/"
}

# file->none
function file2none {
	./progs/rename $MOUNTPOINT/s.file $MOUNTPOINT/d.none
	return $?
}
function afterfiles_file2none {
	beforefiles | sed -e "`renamestr $LOWER_DIR/b0/s.file $LOWER_DIR/b0/d.none`"
}

# file->file
function file2file {
	./progs/rename $MOUNTPOINT/s.file $MOUNTPOINT/d.file
	return $?
}
function afterfiles_file2file {
	beforefiles | grep -v "$LOWER_DIR/b0/s.file"
}

# file->dir
function file2dir {
	shouldfail ./progs/rename $MOUNTPOINT/s.file $MOUNTPOINT/d.dir
	return $?
}
function afterfiles_file2dir {
	beforefiles
}

# file->child
function file2child {
	shouldfail ./progs/rename $MOUNTPOINT/s.file $MOUNTPOINT/d.child
	return $?
}
function afterfiles_file2child {
	beforefiles
}

# file->wh
function file2wh {
	shouldfail ./progs/rename $MOUNTPOINT/s.file $MOUNTPOINT/d.wh
	return $?
}
function afterfiles_file2wh {
	beforefiles
}


# dir->none
function dir2none {
	./progs/rename $MOUNTPOINT/s.dir $MOUNTPOINT/d.none
	return $?
}
function afterfiles_dir2none {
	beforefiles | sed -e "`renamestr $LOWER_DIR/b0/s.dir $LOWER_DIR/b0/d.none`"
	echo "f $LOWER_DIR/b0/d.none/.wh.__dir_opaque"
}

# dir->file
function dir2file {
	shouldfail ./progs/rename $MOUNTPOINT/s.dir $MOUNTPOINT/d.file
	return $?
}
function afterfiles_dir2file {
	beforefiles
}

# dir->dir
function dir2dir {
	./progs/rename $MOUNTPOINT/s.dir $MOUNTPOINT/d.dir
	return $?
}
function afterfiles_dir2dir {
	beforefiles | grep -v "$LOWER_DIR/b0/s.dir"
	echo "f $LOWER_DIR/b0/d.dir/.wh.__dir_opaque"
}

# dir->child
function dir2child {
	shouldfail ./progs/rename $MOUNTPOINT/s.dir $MOUNTPOINT/d.child
	return $?
}
function afterfiles_dir2child {
	beforefiles
}

# dir->wh
function dir2wh {
	./progs/rename $MOUNTPOINT/s.dir $MOUNTPOINT/d.wh
	return $?
}
function afterfiles_dir2wh {
	beforefiles | grep -v "$LOWER_DIR/b0/s.dir" | grep -v "$LOWER_DIR/b0/d.wh/.wh.foo"
	echo "f $LOWER_DIR/b0/d.wh/.wh.__dir_opaque"
}


# child->none
function child2none {
	./progs/rename $MOUNTPOINT/s.child $MOUNTPOINT/d.none
	return $?
}
function afterfiles_child2none {
	beforefiles | grep -v "$LOWER_DIR/b0/s.child"
	echo "d $LOWER_DIR/b0/d.none"
	echo "f $LOWER_DIR/b0/d.none/foo"
	echo "f $LOWER_DIR/b0/d.none/.wh.__dir_opaque"
}

# child->file
function child2file {
	shouldfail ./progs/rename $MOUNTPOINT/s.child $MOUNTPOINT/d.file
	return $?
}
function afterfiles_child2file {
	beforefiles
}

# child->dir
function child2dir {
	./progs/rename $MOUNTPOINT/s.child $MOUNTPOINT/d.dir
	return $?
}
function afterfiles_child2dir {
	beforefiles | grep -v "$LOWER_DIR/b0/s.child"
	echo "f $LOWER_DIR/b0/d.dir/foo"
	echo "f $LOWER_DIR/b0/d.dir/.wh.__dir_opaque"
}

# child->child
function child2child {
	shouldfail ./progs/rename $MOUNTPOINT/s.child $MOUNTPOINT/d.child
	return $?
}
function afterfiles_child2child {
	beforefiles
}

# child->wh
function child2wh {
	./progs/rename $MOUNTPOINT/s.child $MOUNTPOINT/d.wh
	return $?
}
function afterfiles_child2wh {
	beforefiles | grep -v "$LOWER_DIR/b0/s.child" | grep -v "$LOWER_DIR/b0/d.wh/.wh.foo"
	echo "f $LOWER_DIR/b0/d.wh/foo"
	echo "f $LOWER_DIR/b0/d.wh/.wh.__dir_opaque"
}


# wh->none
function wh2none {
	./progs/rename $MOUNTPOINT/s.wh $MOUNTPOINT/d.none
	return $?
}
function afterfiles_wh2none {
	beforefiles | sed -e 's/s\.wh/d\.none/'
	echo "f $LOWER_DIR/b0/d.none/.wh.__dir_opaque"
}

# wh->file
function wh2file {
	shouldfail ./progs/rename $MOUNTPOINT/s.wh $MOUNTPOINT/d.file
	return $?
}
function afterfiles_wh2file {
	beforefiles
}

# wh->dir
function wh2dir {
	./progs/rename $MOUNTPOINT/s.wh $MOUNTPOINT/d.dir
	return $?
}
function afterfiles_wh2dir {
	beforefiles | grep -v "$LOWER_DIR/b0/s.wh"
	echo "f $LOWER_DIR/b0/d.dir/.wh.foo"
	echo "f $LOWER_DIR/b0/d.dir/.wh.__dir_opaque"
}

# wh->child
function wh2child {
	shouldfail ./progs/rename $MOUNTPOINT/s.wh $MOUNTPOINT/d.child
	return $?
}
function afterfiles_wh2child {
	beforefiles
}

# wh->wh
function wh2wh {
	./progs/rename $MOUNTPOINT/s.wh $MOUNTPOINT/d.wh
	return $?
}
function afterfiles_wh2wh {
	beforefiles | grep -v "$LOWER_DIR/b0/s.wh"
	echo "f $LOWER_DIR/b0/d.wh/.wh.__dir_opaque"
}

SRC="file dir child wh"
DST="none file dir child wh"

for s in $SRC
do
	for d in $DST
	do
		beforefiles | create_hierarchy
		mount_union "" $LOWER_DIR/b0

		${s}2${d}

		afterfiles_${s}2${d}  | check_hierarchy $LOWER_DIR
		unmount_union

		echo -n "[${s} ${d}] "
	done
done


complete_test

