#!/bin/bash
# BUG#501: whiteouts created in wrong directory on "mv dir .."

source scaffold

function files {
cat <<FILES
d $LOWER_DIR
d $LOWER_DIR/b0
d $LOWER_DIR/b1
d $LOWER_DIR/b1/a
FILES
test "$DestExists" && echo $Type $LOWER_DIR/$DestExists/b || :
}

function beforefiles {
echo $Type $LOWER_DIR/b1/a/b
test $Child -eq 1 && echo f $LOWER_DIR/b1/a/b/file || :
}

afterfiles_whiteout_ro()
{
files
beforefiles
cat <<FILES
d $LOWER_DIR/b0/a
f $LOWER_DIR/b0/a/.wh.b
FILES
test "$DestExists" = "b0" || echo $Type $LOWER_DIR/b0/b
test $Type = d && echo f $LOWER_DIR/b0/b/.wh.__dir_opaque || :
test $Child -eq 1 && echo f $LOWER_DIR/b0/b/file || :
}
afterfiles_whiteout_rw()
{
if [ "$DestExists" = "b0" ]
then
	files | fgrep -vw $LOWER_DIR/b0/b || :
else
	files
fi
test "$DestExists" = "b1" || echo $Type $LOWER_DIR/b1/b
test $Type = d && echo f $LOWER_DIR/b1/b/.wh.__dir_opaque || :
test $Child -eq 1 && echo f $LOWER_DIR/b1/b/file || :
}
afterfiles_all_ro()
{
	afterfiles_whiteout_ro
}
afterfiles_all_rw()
{
	afterfiles_whiteout_rw
}

f() # delete_mode branch_mode
{
	echo -n '['$Type $@ $DestExists $Child'] '
	{ files; beforefiles; } | create_hierarchy
	mount_union "delete=$1" $LOWER_DIR/b0 $LOWER_DIR/b1=$2
	cd $MOUNTPOINT/a
	local failure=0
	test $Type = d -a "$DestExists" && failure=1 || :
	if [ $failure -ne 0 ]
	then
		#echo failure
		shouldfail mv b ..
	else
		#echo not failure
		mv b ..
	fi
	cd $OLDPWD
	unmount_union
	if [ $failure -ne 0 ]
	then
		{ files ; beforefiles; } | check_hierarchy $LOWER_DIR
	else
		afterfiles_${1}_$2 | check_hierarchy $LOWER_DIR
	fi
}

g()
{
	Type=f
	Child=0
	f $i $j
	#afterfiles_${i}_$j
	Type=d
	f $i $j
	#afterfiles_${i}_$j
	Child=1
	f $i $j
	#afterfiles_${i}_$j
}

delete_mode=whiteout
test "$DELETE_ALL" -a ! "$DELETE_ALL" = "0" && delete_mode="$delete_mode all"
for i in $delete_mode
do
	for j in ro rw
	do
		for DestExists in "" b0 b1
		do g
		done
	done
done

complete_test
