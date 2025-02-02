/* src/flint-config.h.  Generated from flint-config.h.in by configure.  */
/*
    Copyright (C) 2023, 2024 Albin Ahlbäck

    This file is part of FLINT.

    FLINT is free software: you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License (LGPL) as published
    by the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.  See <https://www.gnu.org/licenses/>.
*/

/* Define if system is big endian. */
/* #undef FLINT_BIG_ENDIAN */

/* Define according to the ABI FLINT was compiled with */
#define FLINT_BITS 64

/* Define if Arm v8 assembly is available */
/* #undef FLINT_HAVE_ASSEMBLY_armv8 */

/* Define if x86_64 ADX assembly is available */
/* #undef FLINT_HAVE_ASSEMBLY_x86_64_adx */

/* Define to use the fft_small module */
/* #undef FLINT_HAVE_FFT_SMALL */

/* Define if GMP has mpn_add_n_sub_n */
#define FLINT_HAVE_NATIVE_mpn_add_n_sub_n 1

/* Define if GMP has mpn_add_nc */
#define FLINT_HAVE_NATIVE_mpn_add_nc 1

/* Define if GMP has mpn_addlsh1_n */
#define FLINT_HAVE_NATIVE_mpn_addlsh1_n 1

/* Define if GMP has mpn_addlsh1_n_ip1 */
/* #undef FLINT_HAVE_NATIVE_mpn_addlsh1_n_ip1 */

/* Define if GMP has mpn_addmul_2 */
#define FLINT_HAVE_NATIVE_mpn_addmul_2 1

/* Define if system has mpn_modexact_1_odd */
#define FLINT_HAVE_NATIVE_mpn_modexact_1_odd 1

/* Define if GMP has mpn_rsh1add_n */
#define FLINT_HAVE_NATIVE_mpn_rsh1add_n 1

/* Define if GMP has mpn_rsh1sub_n */
#define FLINT_HAVE_NATIVE_mpn_rsh1sub_n 1

/* Define if GMP has mpn_sub_nc */
#define FLINT_HAVE_NATIVE_mpn_sub_nc 1

/* Define if system is strongly ordered */
#define FLINT_KNOW_STRONG_ORDER 1

/* Define to use long long limbs */
#define FLINT_LONG_LONG 1

/* Define to enable reentrant. */
/* #undef FLINT_REENTRANT */

/* Define to locally unroll some loops */
#define FLINT_UNROLL_LOOPS 1

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

/* Define to enable pretty printing for tests. */
#define FLINT_WANT_PRETTY_TESTS 1
