#!/bin/sh
# TEST: Branches: b0
#       copy creat-open to the lower filesystem (before mount)
# TEST: run creat-open
# TEST: creat-open should be non-zero length

source scaffold

function files {
cat <<FILES
d $LOWER_DIR
d $LOWER_DIR/b
FILES
}

function afterfiles {
cat <<FILES
d $LOWER_DIR
d $LOWER_DIR/b
f $LOWER_DIR/b/creat-open
FILES
}

( files ) | create_hierarchy

EXPECTED_SIZE=`ls -l progs/creat-open | awk '{print $5}'`
cp progs/creat-open $LOWER_DIR/b/

mount_union "" $LOWER_DIR/b

RET=0
$MOUNTPOINT/creat-open || RET="$?"

if [ $RET -ne 26 ]; then
	echo "creat(2) returned $RET, expected 26 (ETXTBSY)"
fi

ACTUAL_SIZE=`ls -l $MOUNTPOINT/creat-open | awk '{print $5}'`
if [ $EXPECTED_SIZE -ne $ACTUAL_SIZE ]; then
	echo "File size: $ACTUAL_SIZE, expected $EXPECTED_SIZE"
fi

unmount_union

( afterfiles ) | check_hierarchy $LOWER_DIR

complete_test
