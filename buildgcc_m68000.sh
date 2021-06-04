#!/bin/bash 
#
# This builds the M68000 cross compiler 'suite'.
# - Binutils
# - GCC (C, C++)
# - Newlib
# - libgcc, libstdc++-v3
# - GDB
#
# Prerequisites:
# - MinGW:
#   Download the setup program, and should you have unchecked EVERYTHING including the graphic installer, go to the installation folder and run:
#     bin\mingw-get.exe install msys-base mingw32-base
#  
#   Afterwards, go to the newly created msys\1.0 subfolder and start msys.bat.
#   NOTE: If your user name has a space in it (full name), you should add 'SET USERNAME=SomeUser' to msys.bat before starting.
#
#   In the MSYS prompt, run /postinstall/pi.sh, and set up the MinGW installation folder.
#
# Then copy this script to your home folder and run it.
#
# Packages needed (these are installed as needed by this script):
#   - msys-base (installed above)
#   - mingw32-base (installed above)
#   - msys-wget
#   - mingw32-gmp (dev)
#   - mingw32-mpfr(dev)
#   - mingw32-mpc (dev)
#   - mingw32-gcc-g++
#
# IMPORTANT:
# Probably better to not have MINGW, Msys2 and Cygwin paths in the PATH environement variable
# isl package may have compilation issues with make 4.21 or 4.3; it is better to use make 3.81 instead
# Depend the make version, the .dep files may have a c\: in the list files; it must be replaced by /c
#

# Test for spaces in the current directory.
homefolder=`pwd`
if [[ $homefolder =~ .\ . ]]
then
  echo "Current directory '$homefolder' contains spaces. Compile will fail. Please change to another directory, or set up another user by adding:

  SET USERNAME=SomeUser

in msys.bat"
  exit 1
fi

# Information.
# To check:
# binutils 2.8.1, gcc 2.7.2.2, isl, cloog, newlib 1.8.0
# binutils 2.9.1, gcc 2.95, isl , cloog ,
# binutils 2.10.1, gcc 2.95.3, isl , cloog ,
# binutils 2.11.2a, gcc 2.95.3, isl , cloog ,
# binutils 2.13.2.1a, gcc 3.1.1, isl , cloog ,
# binutils 2.13.2.1a, gcc 2.95.3
# binutils 2.22     , gcc 4.7.0, isl N/A, cloog N/A, newlib 1.20.0  , GDB 7.4
# binutils 2.23.1   , gcc 4.8.0, isl N/A, cloog N/A, newlib 2.0.0   , GDB 7.5.1                       
# binutils 2.15 (?) , gcc 3.4.2
# binutils 2.16.1(?), gcc 3.4.6, isl N/A, cloog N/A, newlib 2.1.0(?)
# binutils 2.24(?)  , gcc 4.9.4, isl 0.20(?), cloog 0.18.1, newlib 2.1.0(?)
# binutils 2.24(?)  , gcc 5.5.0, isl 0.20(?), cloog 0.18.1, newlib 2.1.0(?)
# binutils 2.28(?)  , gcc 7.3.0, isl 0.20(?), cloog 0.18.1, newlib 2.5.0(?)
#
# 'Claimed' tested with:
# binutils 2.24, gcc 4.9.0, isl 0.12.2, cloog 0.18.1, newlib 2.1.0
# binutils 2.27, gcc 6.1.0, isl 0.16.1, cloog 0.18.1, newlib 2.4.0
# binutils 2.28, gcc 7.1.0, isl 0.16.1, cloog 0.18.1, newlib 2.5.0
#
# Used with:
# binutils    , gcc  , isl , cloog ,             , GDB 
# binutils 2.36   , gcc 4.5.4 , isl 0.12.2, cloog 0.16.1,             , GDB 
# binutils 2.16.1 , gcc 4.9.4 , isl 0.12.2, cloog 0.18.1,             , GDB 8.2.1
# binutils 2.31.1 , gcc 5.5.0 , isl 0.18  , cloog 0.18.1, newlib 3.1.0, GDB 8.2.1
# binutils 2.27   , gcc 6.4.0 , isl 0.18  , cloog 0.18.1
# binutils 2.30   , gcc 6.5.0 , isl 0.18  , cloog 0.18.1
# binutils 2.28   , gcc 7.1.0 , isl 0.16.1, cloog 0.18.1
# binutils 2.31.1 , gcc 7.3.0 , isl 0.16.1, cloog 0.18.1
# binutils 2.31.1 , gcc 7.4.0 , isl 0.18  , cloog 0.18.1
# binutils 2.33.1 , gcc 7.5.0 , isl 0.22  , cloog 0.18.4, newlib 3.1.0, GDB 8.3.1
# binutils 2.32   , gcc 8.1.0 , isl 0.21  , cloog 0.18.4,             , GDB 8.2.1
# binutils 2.30   , gcc 8.2.0 , isl 0.18  , cloog 0.18.1,             , GDB 8.2.1
# binutils 2.31.1 , gcc 8.3.0 , isl 0.18  , cloog 0.18.1, newlib 3.1.0, GDB 8.2.1
# binutils 2.34   , gcc 8.4.0 , isl 0.22.1, cloog 0.18.4, newlib 3.3.0, GDB 9.1
# binutils 2.36   , gcc 8.5.0 , isl N/A   , cloog N/A   , newlib 4.1.0
# binutils 2.31.1 , gcc 9.0.1 , isl 0.18  , cloog 0.18.1, newlib 3.1.0, GDB 8.2.1
# binutils 2.32   , gcc 9.0.1 , isl 0.21  , cloog 0.18.4, newlib 3.1.0, GDB 8.2.1                    [WiP]
# binutils 2.32   , gcc 9.1.0 , isl 0.21  , cloog 0.18.4, newlib 3.1.0, GDB 8.2.1
# binutils 2.32   , gcc 9.2.0 , isl 0.21  , cloog 0.18.4, newlib 3.1.0, GDB 8.3
# binutils 2.34   , gcc 9.3.0 , isl 0.22.1, cloog 0.18.4,             , GDB 9.2
# binutils 2.35.2 , gcc 9.4.0 , isl N/A   , cloog N/A   , newlib 4.1.0, GDB 10.2
# binutils 2.32   , gcc 10.0.0, isl 0.21  , cloog 0.18.4, newlib 3.1.0, GDB 8.2.1					[WiP]
# binutils 2.34   , gcc 10.1.0, isl 0.22  , cloog 0.18.4, newlib 3.3.0, GDB 9.2
# binutils 2.34   , gcc 10.2.0, isl 0.22.1, cloog 0.18.4, newlib 3.3.0, GDB 9.2
# binutils 2.36   , gcc 10.3.0, isl 0.18  , cloog 0.18.1, newlib 4.1.0, GDB 
# binutils 2.36   , gcc 11.1.0, isl 0.18  , cloog 0.18.1, newlib 4.1.0, GDB 10.2
#
# libgcc, and libstdc++-v3, are incuded in the GCC package
#
# Additional dependencies
# gmp, mpfr, and mpc
#
# cloog, last version is 0.18.4
# Last version used by GNU is 0.18.1
# Version above the one available in the gcc\infrastructure must be manualy downloaded
# 0.18.4 needs aclocal-1.14 and automake-1.14
# It is recommended to keep the cloog version from the gcc package to avoid compilation error
#
# isl, last version is 0.24
# Version 0.13 (or later) of ISL is incompatible with CLooG 0.18.1 release (and older). Use version 0.12.2 of ISL or the build will fail.
# Last version used by GNU is 0.18
# Version above the one available in the gcc\infrastructure must be manualy downloaded
# 0.18 needs aclocal-1.15 and automake-1.15
# It is recommended to keep the isl version from the gcc package to avoid compilation error
#
# GDB, last version is 10.2
#
# binutils, last version is 2.36.1
# Version 2.11.2a, 2.12.1a, 2.13.2.1a require to be patched.
# Version 2.36.1 has compilation error; 2.36 must be avoid for the M68K due to the new bfd-plugins
# Dave Shepperd reported that the last binutils version to support the m68k-coff target is 2.16.1.
# Last binutils version to support the m68k-coff target is 2.16.1, it was removed in 2.17
#
# gcc:
# It is claimed that GCC 2.95 generates better M68k code than GCC 3.x.
# gcc 3.4.6 still supports coff target, but no longer maintained in 4.4 and scheduled for removal
#
# newlib, last version is 4.1.0
# No compilation was successful to generate strict 68000 package

# Download settings
MINGW_INSTALL=NO
DOWNLOAD_PKG=YES

# Build orders (binutils, then GCC, then libs gcc (optional), then newlib (optional), and then GDB
BINUTILS_ORDER=NO
GCC_ORDER=NO
LIBSGCC_ORDER=NO
NEWLIB_ORDER=YES
GDB_ORDER=NO
TESTSUITE_ORDER=NO

# Configure
BINUTILS_CONFIG=NO
ISL_CLOOG_REINTEGRATION=NO
GCC_CONFIG=NO

# Versions
BINUTILS_VERSION=binutils-2.35.2
GCC_VERSION=gcc-9.4.0
ISL_VERSION=isl-0.24
CLOOG_VERSION=cloog-0.18.4
NEWLIB_VERSION=newlib-4.1.0
GDB_VERSION=gdb-10.2

# Compilation settings
# HOST is set for Win32
HOST=i686-pc-mingw32
TARGET=m68k-elf
PREFIX=/c/GNU/$TARGET-$GCC_VERSION
ARCH=m68k
CPU=m68000
TEMPFOLDER=$TARGET-$GCC_VERSION-temp
DNWLFOLDER=downloads
LANGUAGES=c,c++

# Build presentation
echo Building in: $PREFIX
echo Building languages: $LANGUAGES
echo Building target: $TARGET
echo Building architecture: $ARCH
echo Building CPU: $CPU
echo Using temporary folder: $TEMPFOLDER
echo Using downloads folder: $DNWLFOLDER

# This makes sure we exit if anything unexpected happens.
set -e

# Install MinGW components
if [ $MINGW_INSTALL = 'YES' ]
then 
echo Downloading and installing MinGW packages...
mingw-get install msys-wget
# mingw-get install mingw32-binutils (already installed)
# mingw-get install mingw32-gcc (already installed)
fi

# C++/target runtime libs.
if [ $MINGW_INSTALL = 'YES' ]
then
echo Downloading and installing C++/target runtime libs packages... 
mingw-get install mingw32-gcc-g++
mingw-get install mingw32-gmp
mingw-get install mingw32-mpc
mingw-get install mingw32-mpfr
fi

# Redist only
# mingw-get install msys-zip

# Hack: remove temp folder from failed run.
# echo Removing old temporary data...
# rm -r $TEMPFOLDER

# Download everything.
if [ $DOWNLOAD_PKG = 'YES' ]
then
echo Downloading packages...
mkdir -p $DNWLFOLDER
cd $DNWLFOLDER
if [ ! -e "$BINUTILS_VERSION.tar.bz2" ] ; then wget http://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.bz2 ; fi
if [ ! $GCC_VERSION = 'gcc-10.0.0' ]
then
if [ ! -e "$GCC_VERSION.tar.gz" ] ; then wget http://ftp.gnu.org/pub/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz ; fi
fi
if [ ! -e "$ISL_VERSION.tar.bz2" ] ; then wget ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2 ; fi
if [ ! -e "$CLOOG_VERSION.tar.gz" ] ; then wget ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz ; fi
if [ ! -e "$NEWLIB_VERSION.tar.gz" ] ; then wget ftp://sourceware.org/pub/newlib/$NEWLIB_VERSION.tar.gz ; fi
if [ ! -e "$GDB_VERSION.tar.gz" ] ; then wget ftp://sourceware.org/pub/gdb/releases/$GDB_VERSION.tar.gz ; fi
cd ..
fi

# Prepare the temp folder
mkdir -p $TEMPFOLDER
cd $TEMPFOLDER

# Unpack binutils.
if [ $DOWNLOAD_PKG = 'YES' ]
then
if [ $BINUTILS_ORDER = 'YES' ]
then 
echo Unpacking binutils...
if [ ! -d "$BINUTILS_VERSION" ] ; then tar jxvf ../downloads/$BINUTILS_VERSION.tar.bz2 ; fi
fi
fi

# Build binutils.
if [ $BINUTILS_ORDER = 'YES' ]
then
echo Building binutils...
mkdir -p $BINUTILS_VERSION-obj
cd $BINUTILS_VERSION-obj
if [ $BINUTILS_CONFIG = YES ]
then
../$BINUTILS_VERSION/configure --enable-static --disable-shared --disable-nls --host=$HOST --prefix=$PREFIX --target=$TARGET --with-cpu=$CPU --with-arch=$ARCH
fi
make
make install
cd ..
fi

# Unpack GCC and prerequisites
if [ $DOWNLOAD_PKG = 'YES' ]
then
if [ $GCC_ORDER = 'YES' ]
then
echo Unpacking GCC and prerequisites...
if [ ! $GCC_VERSION = 'gcc-9' ]
then
if [ ! -d "$GCC_VERSION" ] ; then tar xvf ../downloads/$GCC_VERSION.tar.gz ; fi
fi
if [ ! -d "$ISL_VERSION" ] ; then tar jxvf ../downloads/$ISL_VERSION.tar.bz2 ; fi
if [ ! -d "$CLOOG_VERSION" ] ; then tar xvf ../downloads/$CLOOG_VERSION.tar.gz ; fi
fi
fi

# Remove previous ISL and CLooG from the GCC directory tree.
if [ $GCC_ORDER = 'YES' ]
then
if [ $ISL_CLOOG_REINTEGRATION = YES ]
then
echo Remove ISL and CLooG from the GCC directory tree
if [ -d "$GCC_VERSION/isl" ] ; then rm -r ./$GCC_VERSION/isl ; fi
if [ -d "$GCC_VERSION/cloog" ] ; then rm -r ./$GCC_VERSION/cloog ; fi
fi
fi

# Move ISL and CLooG into the GCC directory tree.
if [ $GCC_ORDER = 'YES' ]
then
if [ $ISL_CLOOG_REINTEGRATION = YES ]
then
echo Copy ISL and CLooG into the GCC directory tree
cp -r $ISL_VERSION ./$GCC_VERSION/isl
cp -r $CLOOG_VERSION ./$GCC_VERSION/cloog
fi
fi

# Configure and build GCC (compilers only)
if [ $GCC_ORDER = 'YES' ]
then
echo Building GCC...
mkdir -p $GCC_VERSION-obj
cd $GCC_VERSION-obj
if [ $GCC_CONFIG = YES ]
then
#if [ $ISL_CLOOG_REINTEGRATION = YES ]
#then
if [ $GCC_VERSION = 'gcc-3.4.6' ] || [ $GCC_VERSION = 'gcc-2.95.3' ]
then
../$GCC_VERSION/configure --prefix=$PREFIX --target=$TARGET --enable-languages=$LANGUAGES --with-newlib --disable-libmudflap --disable-libssp --disable-libgomp --disable-libstdcxx-pch --disable-threads --disable-nls --disable-libquadmath --with-gnu-as --with-gnu-ld --without-headers
# --enable-fixed-point cannot be used due to the lack of support for the M68K
else
../$GCC_VERSION/configure --host=$HOST --prefix=$PREFIX --target=$TARGET --with-cpu=$CPU --with-arch=$ARCH --enable-languages=$LANGUAGES --with-newlib --disable-libmudflap --disable-libssp --disable-libgomp --disable-libstdcxx-pch --disable-threads --disable-nls --disable-libquadmath --with-gnu-as --with-gnu-ld --without-headers
# --enable-fixed-point cannot be used due to the lack of support for the M68K
fi
#fi
fi
make all-gcc
make install-gcc
cd ..
fi

# Copying required .dll files
# Depend the MINGW version, some DLLs may be missing or not available
if [ $GCC_ORDER = 'YES' ]
then
cp `where libiconv-2.dll` $PREFIX/bin
cp `where libgmp-10.dll` $PREFIX/bin
cp `where libmpc-3.dll` $PREFIX/bin
cp `where libmpfr-6.dll` $PREFIX/bin
cp `where libgcc_s_dw2-1.dll` $PREFIX/bin
cp `where libmingwex-2.dll` $PREFIX/bin
cp `where libintl-8.dll` $PREFIX/bin
cp `where libisl-21.dll` $PREFIX/bin
cp `where libstdc++-6.dll` $PREFIX/bin
fi

# Add the output folder to our search path. We'll need this if we want to cross compile.
export PATH=$PATH:$PREFIX/bin

# Unpack newlib.
if [ $DOWNLOAD_PKG = 'YES' ]
then
if [ $NEWLIB_ORDER = 'YES' ]
then
echo Unpacking newlib...
if [ ! -d $NEWLIB_VERSION ] ; then tar vxf ../downloads/$NEWLIB_VERSION.tar.gz ; fi
fi
fi

# Patch newlib 2.1.0 compile errors.
# For some reason the -i parameter doesn't work in MinGW, permission errors on the temporary files.
if [ $NEWLIB_ORDER = 'YES' ]
then
if [ $NEWLIB_VERSION = 'newlib-2.1.0' ]
then

	mv $NEWLIB_VERSION/libgloss/m68k/io-read.c $NEWLIB_VERSION/libgloss/m68k/io-read.bak
	sed -e 's/ssize_t/_READ_WRITE_RETURN_TYPE/g' $NEWLIB_VERSION/libgloss/m68k/io-read.bak > $NEWLIB_VERSION/libgloss/m68k/io-read.c
	rm $NEWLIB_VERSION/libgloss/m68k/io-read.bak

	mv $NEWLIB_VERSION/libgloss/m68k/io-write.c $NEWLIB_VERSION/libgloss/m68k/io-write.bak
	sed -e 's/ssize_t/_READ_WRITE_RETURN_TYPE/g' $NEWLIB_VERSION/libgloss/m68k/io-write.bak > $NEWLIB_VERSION/libgloss/m68k/io-write.c
	rm $NEWLIB_VERSION/libgloss/m68k/io-write.bak

fi
fi

# Compile newlib
if [ $NEWLIB_ORDER = 'YES' ]
then
echo Compiling newlib...
mkdir -p $NEWLIB_VERSION-obj
cd $NEWLIB_VERSION-obj
../$NEWLIB_VERSION/configure --disable-nls --prefix=$PREFIX --target=$TARGET --host=$HOST --disable-newlib-multithread --disable-newlib-io-float --enable-lite-exit --disable-newlib-supplied-syscalls
# --with-arch=$ARCH --with-cpu=$CPU
make
make install
cd ..
fi

# Now we can build libgcc and libstdc++-v3
if [ $LIBSGCC_ORDER = 'YES' ]
then
mkdir -p $GCC_VERSION-obj
cd $GCC_VERSION-obj
echo Building libgcc and libstdc++...
make all-target-libgcc all-target-libstdc++-v3
make install-target-libgcc install-target-libstdc++-v3
cd ..
fi

# Unpack GDB.
if [ $DOWNLOAD_PKG = 'YES' ]
then
if [ $GDB_ORDER = 'YES' ]
then
echo Unpacking GDB...
if [ ! -d $GDB_VERSION ] ; then tar vxf ../downloads/$GDB_VERSION.tar.gz ; fi
fi
fi

# Compile GDB
if [ $GDB_ORDER = 'YES' ]
then
echo Compiling GDB...
mkdir -p $GDB_VERSION-obj
cd $GDB_VERSION-obj
../$GDB_VERSION/configure --disable-nls --target $TARGET --prefix $PREFIX --host=$HOST
make -j16
make install
cd ..
fi

# testsuite 
if [ $TESTSUITE_ORDER = 'YES' ]
then
echo testsuite...
#cd ..
fi

# Build redistributable.
# cd $PREFIX
# zip -r -9 outrun-$GCC_VERSION.zip .

echo All done!
echo Output binaries for $TARGET are in $PREFIX
echo It\'s now safe to wipe $TEMPFOLDER
