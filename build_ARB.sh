#!/usr/bin/env bash
#
#  author   : Hrvoje Abraham
#  date     : 05.04.2015
#  desc     : Bash script for building static and shared GMP, MPFR, FLINT & ARB Win32 libs
#
#  revisions: 09.10.2015
#             03.04.2017
#             10.02.2020 - use MSYS2 mingw, not Qt
#
#  Configuration used at the latest revision:
#    Windows 10 64-bit
#    msys2-i686-20190524
#      - update MSYS2 : pacman -Syu
#      - update MSYS2 : pacman -Su
#      - install make : pacman -S make
#      - install diff : pacman -S diffutils
#      - install mingw: pacman -S mingw-w64-i686-gcc

SOURCE=/var/local/src # posix style path
TARGET=/var/local # posix style path

# modify if needed
ERASE_OLD_BUILDS="no"

# modify if needed
GMP="$SOURCE"/gmp-6.2.0
BUILD_GMP="no"
CHECK_GMP="no"
CLEAN_GMP="no"

# modify if needed
MPFR="$SOURCE"/mpfr-4.0.2
BUILD_MPFR="no"
CHECK_MPFR="no"
CLEAN_MPFR="no"

# modify if needed
FLINT="$SOURCE"/flint-2.5.2
BUILD_FLINT="no"
CHECK_FLINT="no"
CLEAN_FLINT="no"

# modify if needed
ARB="$SOURCE"/arb-2.17.0
BUILD_ARB="no"
CHECK_ARB="yes"
CLEAN_ARB="no"

# modify if needed
CLEAN_ALL="no"

# ABI=32 instead of ABI=64 because ARB is still not Windows 64-bit safe (uses slong instead long, etc.)
ABI=32

# maximally reduced PATH
PATH=.:/usr/bin:/mingw32/bin:"$TARGET"/bin:"$TARGET"/lib

# standardized timestamp
function timestamp {
  date --rfc-3339=seconds
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
	GCC_INFO="/tmp/gcc.info"

	gcc -v > $GCC_INFO 2>&1

  LOG "Compiler info:"
	LOG "    $(cat $GCC_INFO | grep "gcc version")"
	LOG "    $(cat $GCC_INFO | grep "Target")"
	LOG "    $(cat $GCC_INFO | grep "Thread")"

	[[ -f "$GCC_INFO" ]] && rm "$GCC_INFO"
}

function exe {
	LOG "$1"
	$1 >> "$LOGFILE" 2>&1
	LOGLINE
}

# clean build folder
function clean {
	LOG "cleaning $1"
  exe "cd "$1""
  exe "make clean"
  exe "make distclean"
}

# build logistics for static & shared libs (clean, configure, make, make check, make install)
function build {
	echo "$(timestamp) building $2 $1:"
	LOG "$(timestamp) BUILDING $2 $1"

	echo "$(timestamp)   cleaning..."
	LOG "$(timestamp) CLEANING $2 $1"
	exe "clean "${!1}""

	echo "$(timestamp)   configuring..."
	LOG "$(timestamp) CONFIGURING $2 $1"
	if [ "$2" == "static" ]
	  then
      exe "./configure $3 --disable-shared --enable-static"
    else
      exe "./configure $3 --enable-shared --disable-static"
	fi

	echo "$(timestamp)   making..."
	LOG "$(timestamp) MAKING $2 $1"
	exe "make"

  # check only shared libs
	if [ "$2" == "shared" ]; then
    TO_CHECK="CHECK_$1"
    [ "${!TO_CHECK}" == "yes" ] && (echo "$(timestamp)   checking..."; 	LOG "$(timestamp) CHECKING $2 $1"; exe "make check")
	fi

	echo "$(timestamp)   installing..."
	LOG "$(timestamp) INSTALLING $2 $1"
	exe "make install"
}

# log files
mkdir -p /var/log
LOGFILE="/var/log/build_ARB.log"
[[ -f "$LOGFILE" ]] && rm "$LOGFILE"
TIMEFILE="/var/log/build_ARB_time.log"
[[ -f "$TIMEFILE" ]] && rm "$TIMEFILE"

# erase old builds
if [ "$ERASE_OLD_BUILDS" == "yes" ]; then
  echo "$(timestamp) erasing old builds... "

  # shared libs
  if ls "$TARGET/bin/*.dll" 1> /dev/null 2>&1; then
    cd "$TARGET/bin"
    rm *.dll
  fi

  # includes, static libs, shares
	[[ -d "$TARGET/include" ]] && rm -r "$TARGET/include"
	[[ -d "$TARGET/lib" ]]     && rm -r "$TARGET/lib"
	[[ -d "$TARGET/share" ]]   && rm -r "$TARGET/share"
fi

# configure parameters
GMP_PARAMS="--build="$BUILD" --host="$HOST" --prefix="$TARGET" --enable-cxx ABI="$ABI""
MPFR_PARAMS="--build="$BUILD" --host="$HOST" --prefix="$TARGET" --with-gmp="$TARGET" ABI="$ABI""
FLINT_PARAMS="--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" ABI="$ABI""
ARB_PARAMS="--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" --with-flint="$TARGET" ABI="$ABI""

# build static libs
[[ "$BUILD_GMP" == "yes" ]]   && build "GMP" "static" "$GMP_PARAMS"
[[ "$BUILD_MPFR" == "yes" ]]  && build "MPFR" "static" "$MPFR_PARAMS"
[[ "$BUILD_FLINT" == "yes" ]] && build "FLINT" "static" "$FLINT_PARAMS"
[[ "$BUILD_ARB" == "yes" ]]   && build "ARB" "static" "$ARB_PARAMS"

# build & check shared libs (DLLs)
[[ "$BUILD_GMP" == "yes" ]]   && build "GMP" "shared" "$GMP_PARAMS"
[[ "$BUILD_MPFR" == "yes" ]]  && build "MPFR" "shared" "$MPFR_PARAMS"
[[ "$BUILD_FLINT" == "yes" ]] && build "FLINT" "shared" "$FLINT_PARAMS"
[[ "$BUILD_ARB" == "yes" ]]   && build "ARB" "shared" "$ARB_PARAMS"

# copy FLINT and ARB shared libraries to bin folder
[[ -f "$TARGET/lib/libflint.dll" ]] && exe "cp $TARGET/lib/libflint.dll $TARGET/bin/flint.dll"
[[ -f "$TARGET/lib/libarb.dll" ]]   && exe "cp $TARGET/lib/libarb.dll $TARGET/bin/arb.dll"

# clean builds
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_GMP" == "yes") ]]   && exe "clean "$GMP""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_MPFR" == "yes") ]]  && exe "clean "$MPFR""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_FLINT" == "yes") ]] && exe "clean "$FLINT""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_ARB" == "yes") ]]   && exe "clean "$ARB""

LOG "GMP, MPFR, FLINT, ARB libraries are built"
LOG "headers: $TARGET/include"
LOG "libs: $TARGET/lib"
LOG "DLLs: $TARGET/bin"
LOG "docs: $TARGET/share"
echo "$(timestamp) done."
