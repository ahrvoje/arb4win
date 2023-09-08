/* src/flint-config.h.  Generated from config.h.in by configure.  */
/* src/config.h.in.  Generated from configure.ac by autoheader.  */

/*
    Copyright (C) 2023 Albin Ahlbäck

    This file is part of FLINT.

    FLINT is free software: you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License (LGPL) as published
    by the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.  See <http://www.gnu.org/licenses/>.
*/

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Define if system is big endian. */
/* #undef FLINT_BIG_ENDIAN */

/* Define if compiler has CLZ intrinsics */
#define FLINT_HAS_CLZ 1

/* Define if compiler has CTZ intrinsics */
#define FLINT_HAS_CTZ 1

/* Define if compiler has popcount intrinsics */
#define FLINT_HAS_POPCNT 1

/* Define if system has AVX2 */
/* #undef FLINT_HAVE_AVX2 */

/* Define if system has AVX512 */
/* #undef FLINT_HAVE_AVX512 */

/* Define if compiler has __builtin_constant_p */
#define FLINT_HAVE_CONSTANT_P 1

/* Define to use the fft_small module */
/* #undef FLINT_HAVE_FFT_SMALL */

/* Define to enable reentrant. */
/* #undef FLINT_REENTRANT */

/* Define to set the default directory for temporary files */
#define FLINT_TMPDIR "/tmp"

/* Define to enable BLAS. */
/* #undef FLINT_USES_BLAS */

/* Define if system has cpu_set_t */
/* #undef FLINT_USES_CPUSET */

/* Define to enable the Boehm-Demers-Weise garbage collector. */
/* #undef FLINT_USES_GC */

/* Define to enable the use of pthread. */
#define FLINT_USES_PTHREAD 1

/* Define to enable thread-local storage. */
#define FLINT_USES_TLS 1

/* Define to enable use of asserts. */
/* #undef FLINT_WANT_ASSERT */

/* Define to enable use of GMP internals. */
#define FLINT_WANT_GMP_INTERNALS 1

/* Define to 1 if you have the <alloca.h> header file. */
/* #undef HAVE_ALLOCA_H */

/* Define to 1 if you have the <arm_neon.h> header file. */
/* #undef HAVE_ARM_NEON_H */

/* Define to 1 if you have the <dlfcn.h> header file. */
/* #undef HAVE_DLFCN_H */

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the <fenv.h> header file. */
#define HAVE_FENV_H 1

/* Define to 1 if you have the <float.h> header file. */
#define HAVE_FLOAT_H 1

/* Define to 1 if you have the <gmp.h> header file. */
#define HAVE_GMP_H 1

/* Define to 1 if you have the <immintrin.h> header file. */
#define HAVE_IMMINTRIN_H 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the <malloc.h> header file. */
#define HAVE_MALLOC_H 1

/* Define to 1 if you have the <math.h> header file. */
#define HAVE_MATH_H 1

/* Define to 1 if you have the <mpfr.h> header file. */
#define HAVE_MPFR_H 1

/* Define to 1 if you have the <stdarg.h> header file. */
#define HAVE_STDARG_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/param.h> header file. */
#define HAVE_SYS_PARAM_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the <windows.h> header file. */
#define HAVE_WINDOWS_H 1

/* Define to 1 if you have the <x86intrin.h> header file. */
#define HAVE_X86INTRIN_H 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "https://github.com/flintlib/flint2/issues/"

/* Define to the full name of this package. */
#define PACKAGE_NAME "FLINT"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "FLINT 3.0.0-alpha1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "flint"

/* Define to the home page for this package. */
#define PACKAGE_URL "https://flintlib.org/"

/* Define to the version of this package. */
#define PACKAGE_VERSION "3.0.0-alpha1"

/* Define to 1 if all of the C90 standard headers exist (not just the ones
   required in a freestanding environment). This macro is provided for
   backward compatibility; new code need not use it. */
#define STDC_HEADERS 1

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif
