#!/bin/sh

# TEST: lookup(F), where F is:
# TEST: 	File-Directory-File
# TEST:		Directory-File-Directory
# TEST:		Whiteout-Directory

source scaffold

function branch_files {
cat <<FILES
d $LOWER_DIR
d $LOWER_DIR/b0
d $LOWER_DIR/b0/dir
f $LOWER_DIR/b0/dir/ro
d $LOWER_DIR/b1
d $LOWER_DIR/b1/dir
f $LOWER_DIR/b1/dir/.wh.__dir_opaque
f $LOWER_DIR/b1/dir/rw
FILES
}
function cleanup {
	unmount_union
	userdel -f -r $UNPRIV_USER
}

branch_files | create_hierarchy

chmod 777 $LOWER_DIR/b0
chmod 777 $LOWER_DIR/b1
chmod 700 $LOWER_DIR/b0/dir
chmod 700 $LOWER_DIR/b1/dir
chmod 644 $LOWER_DIR/b0/dir/ro
chmod 644 $LOWER_DIR/b1/dir/.wh.__dir_opaque
chmod 644 $LOWER_DIR/b1/dir/rw

PRIV_USER="root"
UNPRIV_USER="unionfs_test"

if [ `cat /etc/passwd | grep $UNPRIV_USER | wc -l` -ne 0 ]; then
	echo "User $UNPRIV_USER exists!"
	exit 1
fi

useradd -d /tmp/$UNPRIV_USER -g nobody -m $UNPRIV_USER

chown $UNPRIV_USER $LOWER_DIR/b0
chown $UNPRIV_USER $LOWER_DIR/b1
chown $PRIV_USER $LOWER_DIR/b0/dir
chown $PRIV_USER $LOWER_DIR/b1/dir
chown $UNPRIV_USER $LOWER_DIR/b0/dir/ro
chown $UNPRIV_USER $LOWER_DIR/b1/dir/.wh.__dir_opaque
chown $UNPRIV_USER $LOWER_DIR/b1/dir/rw

mount_union "delete=whiteout" $LOWER_DIR/b1=rw $LOWER_DIR/b0=ro

su $UNPRIV_USER -c "ls -ald $MOUNTPOINT/dir > /dev/null" || (cleanup && echo "FAILED" && exit 1)
shouldfail su $UNPRIV_USER -c "ls -al $MOUNTPOINT/dir"
ls -ald $MOUNTPOINT/dir > /dev/null
ls -al $MOUNTPOINT/dir > /dev/null
su $UNPRIV_USER -c "ls -ald $MOUNTPOINT/dir > /dev/null" || (cleanup && echo "FAILED" && exit 1)
shouldfail su $UNPRIV_USER -c "ls -al $MOUNTPOINT/dir"

# unmount, remove user, ...
cleanup

branch_files | check_hierarchy $LOWER_DIR

complete_test
