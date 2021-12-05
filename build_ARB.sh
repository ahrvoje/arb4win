#!/usr/bin/env bash
#
#  author   : Hrvoje Abraham
#  date     : 05.04.2015
#  desc     : Bash script for building static & shared GMP, MPIR, MPFR, FLINT and ARB for Windows
#
#  revisions: 09.10.2015
#             03.04.2017
#             10.02.2020 - use MSYS2 mingw, not Qt
#             05.12.2021 - 64bit, MPIR replace GMP, join static&shared MPFR build, auto ABI, check config & make error
#
#  Configuration used at the latest revision:
#    Windows 11 64-bit
#    msys2-x86_64-20210725
#      - update MSYS2   : pacman -Syu
#      - update MSYS2   : pacman -Su
#      - install devel  : pacman -S base-devel
#      - install mingw32: pacman -S mingw-w64-i686-gcc
#      - install mingw64: pacman -S mingw-w64-x86_64-gcc
#      - install yasm   : pacman -S yasm

[ $(uname -o) != Msys ] && { echo "MSYS environment required. Exiting..."; exit 1; }

# modify if needed
SOURCE=/opt/src

# modify if needed
DELETE_OLD_BUILDS="no"

# modify if needed
GMP=$SOURCE/gmp-6.2.1
BUILD_GMP="no"
CHECK_GMP="no"
CLEAN_GMP="no"

# modify if needed
MPIR=$SOURCE/mpir-3.0.0
BUILD_MPIR="yes"
CHECK_MPIR="yes"
CLEAN_MPIR="no"

# modify if needed
MPFR=$SOURCE/mpfr-4.1.0
BUILD_MPFR="yes"
CHECK_MPFR="yes"
CLEAN_MPFR="no"

# modify if needed
FLINT=$SOURCE/flint-2.8.4
BUILD_FLINT="yes"
CHECK_FLINT="yes"
CLEAN_FLINT="no"

# modify if needed
ARB=$SOURCE/arb-2.21.1
BUILD_ARB="yes"
CHECK_ARB="yes"
CLEAN_ARB="no"

# modify if needed
CLEAN_ALL="no"

# standardized timestamp
function timestamp {
    date --rfc-3339=seconds
}

# adds RFC 3339 compliant timestamp to all logs, and prints in STDOUT, and LOG & TIME files
function LOG {
    STAMPED="$(timestamp) $1"

    echo "$STAMPED"
    echo "$STAMPED" >> $LOGFILE
    echo "$STAMPED" >> $TIMEFILE
}

function exe {
    LOG "$1"
    $1 >> $LOGFILE 2>&1
}

# clean build folder
function clean {
    exe "cd "$1
    exe "make clean"
    exe "make distclean"
    
    # workaround for Arb make clean issue https://github.com/fredrik-johansson/arb/issues/393
    [[ $1 == *"arb"* ]] && [ -f $ARB/libarb-2.dll ] && exe "rm "$ARB/libarb-2.dll
}

# build steps for static & shared libs (make clean, make distclean, configure, make, make check, make install)
function build {
    LOG "BUILDING "$2" "$1

    LOG "CLEANING "$2" "$1
    exe "clean "${!1}

    LOG "CONFIGURING "$2" "$1
    [ $2 == "static"        ] && STATIC_SHARED="--enable-static --disable-shared"
    [ $2 == "shared"        ] && STATIC_SHARED="--disable-static --enable-shared"
    [ $2 == "static&shared" ] && STATIC_SHARED="--enable-static --enable-shared"

    PARAMS=$1"_PARAMS"
    exe "./configure ABI="$ABI" --prefix="$TARGET" ${!PARAMS} $STATIC_SHARED"
    [ $? != 0 ] && { LOG "Configuration error occured. Stopping build process..."; exit 1; }
    
    LOG "MAKING "$2" "$1
    exe "make"
    [ $? != 0 ] && { LOG "Make error occured. Stopping build process..."; exit 1; }

    TO_CHECK="CHECK_"$1
    [ ${!TO_CHECK} == "yes" ] && [[ $2 == *"static"* ]] && {  # only static FLINT and ARB can be checked
        LOG "CHECKING "$2" "$1;
        exe "make check";
        [ $? != 0 ] && { LOG "Check FAILED!"; }
    }

    LOG "INSTALLING "$2" "$1
    exe "make install"
}

# log files
mkdir -p /var/log
LOGFILE=/var/log/build_ARB.log
[ -f $LOGFILE ] && rm $LOGFILE
TIMEFILE=/var/log/build_ARB_time.log
[ -f $TIMEFILE ] && rm $TIMEFILE

[[ $(uname) == MINGW32* ]] && { ABI=32; TARGET=/opt/i686; }
[[ $(uname) == MINGW64* ]] && { ABI=64; TARGET=/opt/x86_64; }

# expand PATH to make new libs available for tests
PATH=$PATH:$TARGET/lib:$TARGET/bin

LOG "Compiler info:"
LOG "    $(gcc -v 2>&1 | grep "gcc version")"
LOG "    $(gcc -v 2>&1 | grep "Target")"
LOG "    $(gcc -v 2>&1 | grep "Thread")"

LOG "SOURCE="$SOURCE
LOG "TARGET="$TARGET
LOG "ABI="$ABI
LOG "PATH="$PATH

# delete old builds
[ $DELETE_OLD_BUILDS == "yes" ] && [ -d $TARGET ] && { LOG "Deleting old builds..."; exe "rm -r "$TARGET; }

# configure parameters
GMP_PARAMS="--enable-cxx"
MPIR_PARAMS="--enable-gmpcompat"
MPFR_PARAMS="--with-gmp="$TARGET
FLINT_PARAMS="--with-mpir="$TARGET" --with-mpfr="$TARGET
ARB_PARAMS="--with-mpir="$TARGET" --with-mpfr="$TARGET" --with-flint="$TARGET" CFLAGS=-Wno-long-long"

# build libs
[ $BUILD_GMP   == "yes" ] && { build "GMP" "static"; build "GMP" "shared"; }
[ $BUILD_MPIR  == "yes" ] && { build "MPIR" "static"; build "MPIR" "shared"; }
[ $BUILD_MPFR  == "yes" ] && { build "MPFR" "static&shared"; }
[ $BUILD_FLINT == "yes" ] && { build "FLINT" "static"; build "FLINT" "shared"; }
[ $BUILD_ARB   == "yes" ] && { build "ARB" "static"; build "ARB" "shared"; }

# copy FLINT and ARB shared libraries to bin folder
[ $BUILD_FLINT == "yes" ] && [ -f $TARGET/lib/libflint.dll ] && exe "cp "$TARGET/lib/libflint.dll" "$TARGET/bin/flint.dll
[ $BUILD_ARB   == "yes" ] && [ -f $TARGET/lib/libarb.dll   ] && exe "cp "$TARGET/lib/libarb.dll" "$TARGET/bin/arb.dll

# clean builds
[ $CLEAN_ALL == "yes" ] || [ $CLEAN_GMP   == "yes" ] && exe "clean "$GMP
[ $CLEAN_ALL == "yes" ] || [ $CLEAN_MPIR  == "yes" ] && exe "clean "$MPIR
[ $CLEAN_ALL == "yes" ] || [ $CLEAN_MPFR  == "yes" ] && exe "clean "$MPFR
[ $CLEAN_ALL == "yes" ] || [ $CLEAN_FLINT == "yes" ] && exe "clean "$FLINT
[ $CLEAN_ALL == "yes" ] || [ $CLEAN_ARB   == "yes" ] && exe "clean "$ARB

LOG "Build finished. Output:"
LOG "headers: "$TARGET/include
LOG "libs:    "$TARGET/lib
LOG "DLLs:    "$TARGET/bin
LOG "docs:    "$TARGET/share
LOG "Done."
