# GMP, MPFR, FLINT &amp; ARB for Windows

## Introduction

GMP, MPFR, FLINT and ARB are numerical libraries for large integer and arbitrary precision floating point arithmetic.

## Environment

- MSYS 1.0
- MSYS patch from 2012
- MinGW in short
- buildARB.sh

## Source

- GMP v5.1.3
- MPFR v3.1.2
- FLINT 2.4.5
- ARB v2.5.0+ (master branch head from 06.04.2015.)

## Patches

### GMP

File **_gmp-5.1.3/tests/cxx/clocale.c_** was patched to avoid MinGW problem with redeclaration of `localeconv`. This patch enables an execution of a few tests which otherwise fail.

```
gmp-5.1.3/tests/cxx/clocale.c
ln. 44-54

#if !defined(__MINGW32__) // this line added to avoid redeclaration problem in MinGW
#if HAVE_LOCALECONV
struct lconv *
localeconv (void)
{
   static struct lconv  l;
   l.decimal_point = decimal_point;
   return &l;
}
#endif
#endif // this line added to avoid redeclaration problem in MinGW
```

### ARB

File **_arb-master/test/t-set_str.c_** was patched to avoid MinGW problem with conversion of inf/nan strings to float. Despite the fact that GCC converts "inf" & "nan" strings to INF & NAN doubles respectively, just as C standard states (e.g. ISO/IEC 9899:1999, sections 7.20.1.1 & 7.20.1.3), MinGW converts them to 0.0. This fact causes ARB's set_str test to always fail and stop the testing process.

```
arb-master/test/t-set_str.c
ln. 114-125

/* this line added to avoid MinGW problem of atof("inf")=0.0 atof("nan")=0.0
    "inf",
    "-inf",
    "+inf",
    "Inf",
    "-INF",
    "+Inf",

    "NAN",
    "-NaN",
    "+NAN",
*///  this line added to avoid MinGW problem of atof("inf")=0.0

```
## Binaries

/local/bin

/local/lib

## Workflow

ARB_MinGW_package.7z contains all sufficient material to simply build all static and dynamic libraries. After unpacking the archive and starting msys.bat script, one must simply execute the following command line:

```
$ buildARB.sh
```

buildARB.sh performs the entire workflow with timing & log files written in /tmp folder. You can check on the process viewing them as they are appended by buildARB.sh script.

## Demo

