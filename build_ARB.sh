#! /bin/bash
#
#  author: Hrvoje Abraham
#    date: 05.04.2015
#    desc: Bash script for building static and dynamic GMP, MPFR, FLINT & ARB 32-bit libraries for Windows under MSYS 1.0
#
#  Configuration used at the moment of writing this script:
#    Windows 7 64-bit
#    MSYS 1.0 including the following updates and additions:
#      - msysCORE v1.0.18
#      - bash v3.1.23
#      - grep v2.5.4-2
#      - make v3.81-3
#      - msys-regex-1.dll
#      - msys-termcap-0.dll
#      - msys-intl-8.dll
#      - msys-iconv-2.dll
#    Compiler info:
#      - gcc version v4.9.1 (i686-posix-dwarf-rev2, Built by MinGW-W64 project)
#      - target: i686-w64-mingw32
#      - thread model: posix
#    GMP v5.1.3
#      - GMP v6.0.0a was released, but there are still some issues regarding FLINT v2.4.5
#      - patch: tests/cxx/clocale.c for redeclaration of localeconv
#    MPFR v3.1.2
#    FLINT v2.4.5
#    ARB v2.5.0
#      - master branch head from 06.04.2015
#      - patch: arb/test/t-set_str.c for MinGW issue with atof("inf")=0.0 atof("nan")=0.0
#

# modify according to your setup and preferences
COMPILER=c:/Qt/Qt5.4.1/Tools/mingw491_32 # windows style path!
HOST="i686-w64-mingw32"
BUILD="i686-w64-mingw32"

SOURCE=/local/src # posix style path
TARGET=/local # posix style path

GMP="$SOURCE"/gmp-5.1.3
BUILD_STATIC_GMP="yes"
CHECK_STATIC_GMP="no"
BUILD_SHARED_GMP="yes"
CHECK_SHARED_GMP="no"

MPFR="$SOURCE"/mpfr-3.1.2
BUILD_STATIC_MPFR="yes"
CHECK_STATIC_MPFR="no"
BUILD_SHARED_MPFR="yes"
CHECK_SHARED_MPFR="no"

FLINT="$SOURCE"/flint-2.4.5
BUILD_STATIC_FLINT="yes"
CHECK_STATIC_FLINT="no"
BUILD_SHARED_FLINT="yes"
CHECK_SHARED_FLINT="no"

ARB="$SOURCE"/arb-master
BUILD_STATIC_ARB="yes"
CHECK_STATIC_ARB="no"
BUILD_SHARED_ARB="yes"
CHECK_SHARED_ARB="no"

CLEAN_ALL_BUILDS="yes"

# ABI=32 instead of ABI=64 because ARB is still not Windows 64-bit safe (uses slong instead long, etc.)
ABI=32

# standardized timestamp
function timestamp {
    date --rfc-3339=seconds
}

# convert windows style path to posix
function posix_path {
	echo "/$1" | sed -e 's/\\/\//g' -e 's/://'
}

function ismounted {
	DIR="$1"
	TMP="$(mount | grep "$DIR")"
    if [ -n "$TMP" ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# prints empty line in LOGFILE, for better readability
function LOGLINE {
    echo >> "$LOGFILE"
}

# adds RFC 3339 compliant timestamp to the message and prints to LOG and TIME file
function LOG {
    STAMPED="$(timestamp) $1"
    echo -e "$STAMPED" >> "$LOGFILE"
    echo -e "$STAMPED" >> "$TIMEFILE"
}

# logs compiler info
function LOGcompilerinfo {
    LOG "Compiler info:"
	LOG "    $(gcc -v > /tmp/gcc.info 2>&1 | cat /tmp/gcc.info | grep "gcc version")"
	LOG "    $(gcc -v > /tmp/gcc.info 2>&1 | cat /tmp/gcc.info | grep "Target")"
	LOG "    $(gcc -v > /tmp/gcc.info 2>&1 | cat /tmp/gcc.info | grep "Thread")"
}

function exe {
	LOG "$1"
	$1 >> "$LOGFILE" 2>&1
	LOGLINE
}

# clean build folder
function clean {
    exe "cd "$1""
    exe "make clean"
    exe "make distclean"
}

# build logistics (clean, configure, make, make check, make install)
function build {
	TO_BUILD="BUILD_$2_$1"
    if [ "${!TO_BUILD}" == "yes" ]; then
        LOG "building $2 $1 from ${!1}"
        exe "clean "${!1}""
        exe "./configure $3"
		exe "make"
		TO_CHECK="CHECK_$2_$1"
        [ "${!TO_CHECK}" == "yes" ] && (LOG "checking $2 $1"; exe "make check")
        LOG "installing $2 $1"
		exe "make install"
    fi
}

# maximally reduced PATH
PATH=/bin:"$(posix_path $COMPILER)"/bin:/usr/local/bin

# log files
mkdir -p /usr/tmp
LOGFILE="/usr/tmp/build_ARB.log"
[[ -f "$LOGFILE" ]] && rm "$LOGFILE"
TIMEFILE="/usr/tmp/build_ARB_time.log"
[[ -f "$TIMEFILE" ]] && rm "$TIMEFILE"

# MSYS /mingw mount point with MinGW installed in COMPILER folder
if [ "$(ismounted /mingw)" == "yes" ]; then
  exe "umount /mingw"
fi
exe "mount "$COMPILER" /mingw"

# print environment info, just for case
LOG "PATH: $PATH"
LOG "mingw mount: $(cat /etc/fstab | grep mingw)"
LOGcompilerinfo
LOGLINE

# build libs
build "GMP"   "STATIC" "--build="$BUILD" --host="$HOST" --prefix="$TARGET" --enable-cxx ABI="$ABI" --disable-shared --enable-static"
build "GMP"   "SHARED" "--build="$BUILD" --host="$HOST" --prefix="$TARGET" --enable-cxx ABI="$ABI" --enable-shared --disable-static"
build "MPFR"  "STATIC" "--build="$BUILD" --host="$HOST" --prefix="$TARGET" --with-gmp="$TARGET" ABI="$ABI" --disable-shared --enable-static"
build "MPFR"  "SHARED" "--build="$BUILD" --host="$HOST" --prefix="$TARGET" --with-gmp="$TARGET" ABI="$ABI" --enable-shared --disable-static"
build "FLINT" "STATIC" "--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" ABI="$ABI" --disable-shared --enable-static"
build "FLINT" "SHARED" "--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" ABI="$ABI" --enable-shared --disable-static"
build "ARB"   "STATIC" "--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" --with-flint="$TARGET" ABI="$ABI" --disable-shared --enable-static"
build "ARB"   "SHARED" "--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" --with-flint="$TARGET" ABI="$ABI" --enable-shared --disable-static"

# copy FLINT and ARB shared libraries to bin folder
[[ -f "$TARGET/lib/libflint.so" ]] && exe "cp $TARGET/lib/libflint.so $TARGET/bin/flint.dll"
[[ -f "$TARGET/lib/libarb.so" ]] && exe "cp $TARGET/lib/libarb.so $TARGET/bin/arb.dll"

#clean builds
if [ "$CLEAN_ALL_BUILDS" == "yes" ]; then
    LOG "cleaning all builds"
    exe "clean "$GMP""
    exe "clean "$MPFR""
    exe "clean "$FLINT""
    exe "clean "$ARB""
fi

LOG "GMP, MPFR, FLINT, ARB libraries are built"
LOG "headers: $TARGET/include"
LOG "libs: $TARGET/lib"
LOG "DLLs: $TARGET/bin"
LOG "docs: $TARGET/share"
LOGcompilerinfo
