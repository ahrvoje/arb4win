# GMP, MPFR, FLINT &amp; ARB for Windows

## Introduction

GMP, MPFR, FLINT and ARB are well known numerical libraries for large integer and arbitrary precision floating point arithmetic. A special emphasis is given to _ball arithmetic_ library [ARB](https://github.com/fredrik-johansson/arb/) by Frederik Johansson.

This repository does not contribute to their functionalities, but is a mere guide and resource container for porting to Windows.

## System and environment

Used and included in **_ARB_for_MinGW.7z_**:
- reduced MSYS2 environment including **make 4.1-4** and **diffutils 3.3-3**
- sources with patched tests in **_/local/src_** folder:
   - GMP v6.0.0a ([ftp://ftp.gnu.org/gnu/gmp/](ftp://ftp.gnu.org/gnu/gmp/))
   - MPFR v3.1.3 ([http://www.mpfr.org/mpfr-current/](http://www.mpfr.org/mpfr-current/))
   - FLINT v2.5.2 ([http://flintlib.org/downloads.html](http://flintlib.org/downloads.html))
   - ARB v2.7.0+ (commit aaa4d86) ([https://github.com/fredrik-johansson/arb/](https://github.com/fredrik-johansson/arb/))
- **_build_ARB.sh_** in **_local/bin_**

Used, but not included in **_ARB_for_MinGW.7z_**:
- Windows 7
- gcc compiler:
   - gcc version v4.9.2 (i686-posix-dwarf-rev2, Built by MinGW-W64 project)
   - target: i686-w64-mingw32
   - thread model: posix
   - used as part of Qt 5.5.0

Cygwin is not used as it does not handle symbolic links used by some **configure** and **make** scripts in a desirable way. MSYS2 solves this issue by implementing customized **ln** command which simply hard-copies the file.

The libraries are not 64-bit Windows safe so the entire workflow is adapted to 32-bit building process (configuration parameter `ABI=32` is set for all of them). Consequently, if one builds against the static libraries, `-m32` gcc/g++ switch sometimes has to be used to compile target application, as shown in Demo section at the end of this page.

## Patches

The following two patches fix a few issues with some tests in GMP and ARB. They are already applied to the source in **_ARB_for_MinGW.7z_**.

#### GMP

File **_gmp-6.0.0/tests/cxx/clocale.c_** was patched to avoid MinGW problem with redeclaration of `localeconv` method. This patch enables an execution of a few tests which otherwise fail, without influencing any numerical procedures or results.
```
gmp-6.0.0/tests/cxx/clocale.c
ln. 44-54

#if !defined(__MINGW32__) /* PATCH!: this line added to avoid redeclaration problem in MinGW */
#if HAVE_LOCALECONV
struct lconv *
localeconv (void)
{
   static struct lconv  l;
   l.decimal_point = decimal_point;
   return &l;
}
#endif
#endif /* PATCH!: this line added to avoid redeclaration problem in MinGW */
```
#### ARB

File **_arb-master/arb/test/t-set_str.c_** was patched to avoid MinGW problem with conversion of "inf"/"nan" strings to float. Despite the fact that GCC converts them to INF/NAN doubles, just as C standard states (e.g. ISO/IEC 9899:1999, sections 7.20.1.1 & 7.20.1.3), MinGW converts them to 0.0. This fact causes ARB's original version of **_t-set_str.c_** test to always fail and stop the testing process.

Make sure you take this facts into consideration if you use `atof` or deserialize "inf"/"nan" strings under MinGW. This cases have to be handled separately.
```
arb-master/arb/test/t-set_str.c
ln. 115-127

    /* PATCH!: this block is commented out to avoid MinGW problem with atof("inf")=0.0 atof("nan")=0.0 */
    /*
    "inf",
    "-inf",
    "+inf",
    "Inf",
    "-INF",
    "+Inf",

    "NAN",
    "-NaN",
    "+NAN",
    */
```
## Deliverables

Once built, the following folders contain the files needed to use the libraries.

**_/local/bin_** contains shared libraries (**_libgmp-10.dll_**, **_libgmpxx-4.dll_**, **_libmpfr-4.dll_**, **_flint.dll_**, **_arb.dll_**). They are also included in **DLLs** folder of this repository.

**_/local/lib_** contains static libraries for compiler and target defined in **_build_ARB.sh_**. I decided not to include them in **_ARB_for_MinGW.7z_** as everybody needs to build them using their own compiler and target anyway.

**_/local/include_** contains header files needed to build against the static libraries, also not included in **_ARB_for_MinGW.7z_**.

**_/local/shared_** contains some documentation automatically generated during the build process.

## Workflow

1. **_ARB_for_MinGW.7z_** contains all sufficient material to build described static and dynamic libraries. Download and unpack it into any desired folder.
2. Check and adapt `COMPILER`, `HOST` & `BUILD` variables at ln. 27-29 of **_/local/bin/build_ARB.sh_** according to your setting and preferences. Also, every library can be set to be build in static or shared form and checked by the available set of tests. One can control this by setting corresponding `ERASE`, `BUILD`, `CHECK` & `CLEAN` variables to "yes"/"no" value at ln. 34-56 of **_build_ARB.sh_**.
3. Finally, after starting MSYS2 shell (**mingw32_shell.bat**), one simply has to execute the following command and the build process will start:
```
$ /local/bin/build_ARB.sh
```
**_build_ARB.sh_** automatically executes the entire workflow with timing & log files written to **_/var/log_** folder. You can check on the process viewing them as they are appended.

Applications built using **_arb_** and **_flint_** static libraries expect to find **_libgmp-10.dll_** and **_libmpfr-4.dll_** in local folder or system **_PATH_**.
## Demo

In this demo we evaluate one simple pandigital approximation of natural constant **e** correct to 46 decimal places. ARB also calculates accumulated numerical error so every result is printed as _ball_ containing the result with absolute certainty. Internal computational precision is set to `p=1000`, way more than needed.

![equation](approx.png)
```
#include "arb.h"

int main()
{
	long p = 1000;
	long d = 53;
	arb_t a, b, x, t;
	
	arb_init(a);
	arb_init(b);
	arb_init(x);
	arb_init(t);

	// a = 1 + 2 ^ -76
	arb_set_str(a, "2", p);
	arb_set_str(t, "-76", p);
	arb_pow(a, a, t, p);
	arb_set_str(t, "1", p);
	arb_add(a, t, a, p);
	printf("a   = "); arb_printd(a, d); printf("\n");

	// b = 4 ^ 38 + 0.5
	arb_set_str(b, "0.5", p);
	arb_ui_pow_ui(t, 4, 38, p);
	arb_add(b, t, b, p);
	printf("b   = "); arb_printd(b, d); printf("\n");

	// x = a ^ b
	arb_pow(x, a, b, p);
	printf("x   = "); arb_printd(x, d); printf("\n");
	arb_const_e(t, p);
	printf("e   = "); arb_printd(t, d); printf("\n");
	arb_sub(t, x, t, p);
	printf("x-e = "); arb_printd(t, d); printf("\n");

	printf("Computed with arb-%s\n", arb_version);

	arb_clear(a);
	arb_clear(b);
	arb_clear(x);
	arb_clear(t);
}
```
Demo is compiled by the following command line. Notice `-m32` switch, although it turns out the demo works without it as well.
```
$ g++ -m32 -I/local/include -I/local/include/flint -I/local/include/flintxx arb_demo.cpp -L/local/lib -larb -lflint -lmpfr -lgmp
```
Before starting the application make sure **_libgmp-10.dll_** and **_libmpfr-4.dll_** are in local folder or available via **_PATH_**. And the result is:
```
$ ./a.exe
a   = 1.0000000000000000000000132348898008484427979425390731 +/- 0
b   = 75557863725914323419136.5 +/- 0
x   = 2.718281828459045235360287471352662497757247093739638 +/- 1.1407e-300
e   = 2.7182818284590452353602874713526624977572470936999596 +/- 3.7331e-301
x-e = 3.9678376581476207465438603498757884997818078351607135e-47 +/- 1.514e-300
Computed with arb-2.7.0
```
