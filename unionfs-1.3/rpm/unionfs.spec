%{!?kernel: %{expand: %%define kernel %(uname -r)}}
%define kversion %(echo %{kernel} | sed -e s/-[a-z]*$// - )
%define krelver %(echo %{kversion} | tr -s '-' '_')
%if %(echo %{kernel} | egrep -c [a-z])
   %{expand:%%define ktype -%(echo %{kernel} | sed 's/[0-9]//g; s/\.//g; s/-//g')}
%endif

%define unionfsrel 1

BuildRequires: e2fsprogs-devel

Summary: Unionfs is a stackable unification file system.
Name: unionfs
Version: 1.2
License: GPL
Release: %{unionfsrel}_%{krelver}
Requires: kernel%{?ktype} = %{kversion}, /sbin/depmod
Group: System/Filesystem
Source: ftp://ftp.fsl.cs.sunysb.edu/pub/unionfs/unionfs-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-root

%description
Unionfs is a stackable unification file system, which can appear to
merge the contents of several directories (branches), while keeping
their physical content separate.  Unionfs is useful for unified source
tree management, merged contents of split CD-ROM, merged separate
software package directories, data grids, and more.  Unionfs allows
any mix of read-only and read-write branches, as well as insertion and
deletion of branches anywhere in the fan-out.

This package contains the kernel-module for unionfs support.

%package tools
Summary:     Unionfs control tools
Group:       System/Filesystem
AutoReqProv: on
Release:     %{unionfsrel}

%description tools
Unionfs is a stackable unification file system, which can appear to
merge the contents of several directories (branches), while keeping
their physical content separate.  Unionfs is useful for unified source
tree management, merged contents of split CD-ROM, merged separate
software package directories, data grids, and more.  Unionfs allows
any mix of read-only and read-write branches, as well as insertion and
deletion of branches anywhere in the fan-out.

This package contains the tools used to control a unionfs mount.

%prep
%setup

%build
make

%install
mkdir -p $RPM_BUILD_ROOT/lib/modules/%{kernel}/kernel/fs
make install PREFIX=$RPM_BUILD_ROOT MODPREFIX=$RPM_BUILD_ROOT

%clean
make clean

%files
%defattr(-,root,root)
%dir /lib/modules/%{kernel}/kernel/fs/unionfs
%if %(echo %{kernel} | grep -c '^2.6')
/lib/modules/%{kernel}/kernel/fs/unionfs/unionfs.ko
%else
/lib/modules/%{kernel}/kernel/fs/unionfs/unionfs.o
%endif

%files tools
%defattr(-,root,root)
/sbin/unionctl
/sbin/uniondbg
/sbin/unionimap

%doc AUTHORS ChangeLog COPYING NEWS README
/man/man4/unionfs.4
/man/man8/unionctl.8
/man/man8/uniondbg.8
/man/man8/unionimap.8

%changelog
