# GMP, MPFR, FLINT &amp; ARB for Windows

## Introduction

GMP, MPFR, FLINT and ARB are well known numerical libraries for large integer and arbitrary precision floating point arithmetic. A special emphasis is given to _ball arithmetic_ library [ARB](https://github.com/fredrik-johansson/arb/) by Frederik Johansson.

The repository doesn't contribute to the functionality, but is a guide for building 32-bit libs for Windows.

## System and environment

- MSYS2 including **make**, **diffutils** and **mingw-w64-i686-gcc**
- versions used for current builds:
   - GMP v6.2.0 ([ftp://ftp.gnu.org/gnu/gmp/](ftp://ftp.gnu.org/gnu/gmp/))
   - MPFR v4.0.2 ([http://www.mpfr.org/mpfr-current/](http://www.mpfr.org/mpfr-current/))
   - FLINT v2.5.2 ([http://flintlib.org/downloads.html](http://flintlib.org/downloads.html))
   - ARB v2.17.0 ([https://github.com/fredrik-johansson/arb/](https://github.com/fredrik-johansson/arb/))
- **_build_ARB.sh_**
- Windows 10 64-bit
- gcc compiler (via MSYS2):
   - gcc version 9.2.0 (Rev2, Built by MSYS2 project)
   - Target: i686-w64-mingw32
   - Thread model: posix

Cygwin isn't used as it does not handle symbolic links used by some **configure** and **make** scripts in a desirable way. MSYS2 solves this issue by implementing customized **ln** command which simply creates hard-copies.

The libraries are not 64-bit Windows safe so the entire workflow is adapted to 32-bit building process (configuration parameter `ABI=32` is set for all of them). Consequently, if one builds against the static libraries, `-m32` gcc/g++ switch sometimes has to be used to compile target application, as shown in Demo section at the end of the page.

## Workflow

1. Install MSYS2, update and install **make**, **difftools** and **mingw-w64-i686-gcc**
2. Check and adapt `SOURCE` & `TARGET` variables in **_/local/bin/build_ARB.sh_** to set the desired source and target folders. Also, every library can be set to be build in static or shared form and checked by available set of tests. One can control this by setting corresponding `ERASE`, `BUILD`, `CHECK` & `CLEAN` variables to "yes"/"no" value.
3. Finally, after starting MSYS2 shell (**mingw32_shell.bat**), execute the following command and the build process will start:
```
$ /local/bin/build_ARB.sh
```
**_build_ARB.sh_** automatically executes the entire workflow with timing & log files written to **_/var/log_** folder.

Applications built using **_arb_** and **_flint_** static libraries expect to find **_libgmp-10.dll_** and **_libmpfr-6.dll_** in local folder or system **_PATH_**.

## Deliverables

Once built, the following folders contain the files needed to use the libraries.

**_/local/bin_** contains shared libraries (**_libgmp-10.dll_**, **_libgmpxx-4.dll_**, **_libmpfr-6.dll_**, **_flint.dll_**, **_arb.dll_**). They are also included in the **DLL** folder.

**_/local/include_** contains header files needed to build against the libraries.

**_/local/lib_** contains static libraries for compiler and target defined in **_build_ARB.sh_**.
**_/local/shared_** contains some documentation automatically generated during build process.

## Demo

In this demo we evaluate one simple _pandigital approximation_ of natural constant **e** correct to 46 decimal places. ARB also calculates accumulated numerical error so every result is printed as _ball_ containing the result with absolute certainty. Internal computational precision is set to `p=1000`, way more than needed. Both static and dynamic lib versions are presented.

![equation](approx.png)

### Static version
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

	printf("Computed with Arb %s\n", arb_version);

	arb_clear(a);
	arb_clear(b);
	arb_clear(x);
	arb_clear(t);

	return 0;
}
```
Demo is compiled by the following command line. **gcc** has to be available in **_PATH_**. Notice `-m32` switch, although this demo works without it as well.
```
$ gcc -I/var/local/include arb_demo.c -L/var/local/lib -larb -lflint -lmpfr -lgmp
```
Before starting the application make sure **_libgmp-10.dll_** and **_libmpfr-6.dll_** are in local folder or available via **_PATH_**. And the result is:
```
$ ./a.exe
a   = 1.0000000000000000000000132348898008484427979425390731 +/- 0
b   = 75557863725914323419136.5 +/- 0
x   = 2.718281828459045235360287471352662497757247093739638 +/- 1.1407e-300
e   = 2.7182818284590452353602874713526624977572470936999596 +/- 3.7331e-301
x-e = 3.9678376581476207465438603498757884997818078351607135e-47 +/- 1.514e-300
Computed with Arb 2.17.0
```

### Dynamic version for Windows

Expects all DLLs available in local exe folder or **_PATH_**.

```
#include <windows.h>

#include "arb.h"


int main()
{
	HINSTANCE hArb = LoadLibrary(TEXT("arb.dll"));

	char* arb_version_d = *( (char**) GetProcAddress(hArb, "arb_version"));

	typedef void(__cdecl *arb_add_t)      (arb_t, arb_t, arb_t, long);
	typedef void(__cdecl *arb_clear_t)    (arb_t);
	typedef void(__cdecl *arb_const_e_t)  (arb_t, long);
	typedef void(__cdecl *arb_init_t)     (arb_t);
	typedef void(__cdecl *arb_pow_t)      (arb_t, arb_t, arb_t, long);
	typedef void(__cdecl *arb_printd_t)   (arb_t, long);
	typedef void(__cdecl *arb_set_str_t)  (arb_t, const char*, long);
	typedef void(__cdecl *arb_sub_t)      (arb_t, arb_t, arb_t, long);
	typedef void(__cdecl *arb_ui_pow_ui_t)(arb_t, long, long, long);

	arb_add_t       arb_add_d       = (arb_add_t)      GetProcAddress(hArb, "arb_add");
	arb_clear_t     arb_clear_d     = (arb_clear_t)    GetProcAddress(hArb, "arb_clear");
	arb_const_e_t   arb_const_e_d   = (arb_const_e_t)  GetProcAddress(hArb, "arb_const_e");
	arb_init_t      arb_init_d      = (arb_init_t)     GetProcAddress(hArb, "arb_init");
	arb_pow_t       arb_pow_d       = (arb_pow_t)      GetProcAddress(hArb, "arb_pow");
	arb_printd_t    arb_printd_d    = (arb_printd_t)   GetProcAddress(hArb, "arb_printd");
	arb_set_str_t   arb_set_str_d   = (arb_set_str_t)  GetProcAddress(hArb, "arb_set_str");
	arb_sub_t       arb_sub_d       = (arb_sub_t)      GetProcAddress(hArb, "arb_sub");
	arb_ui_pow_ui_t arb_ui_pow_ui_d = (arb_ui_pow_ui_t)GetProcAddress(hArb, "arb_ui_pow_ui");

	long p = 1000;
	long d = 53;
	arb_t a, b, x, t;
	
	arb_init_d(a);
	arb_init_d(b);
	arb_init_d(x);
	arb_init_d(t);

	// a = 1 + 2 ^ -76
	arb_set_str_d(a, "2", p);
	arb_set_str_d(t, "-76", p);
	arb_pow_d(a, a, t, p);
	arb_set_str_d(t, "1", p);
	arb_add_d(a, t, a, p);
	printf("a   = "); arb_printd_d(a, d); printf("\n");

	// b = 4 ^ 38 + 0.5
	arb_set_str_d(b, "0.5", p);
	arb_ui_pow_ui_d(t, 4, 38, p);
	arb_add_d(b, t, b, p);
	printf("b   = "); arb_printd_d(b, d); printf("\n");

	// x = a ^ b
	arb_pow_d(x, a, b, p);
	printf("x   = "); arb_printd_d(x, d); printf("\n");
	arb_const_e_d(t, p);
	printf("e   = "); arb_printd_d(t, d); printf("\n");
	arb_sub_d(t, x, t, p);
	printf("x-e = "); arb_printd_d(t, d); printf("\n");

	printf("Computed with Arb %s\n", arb_version_d);

	arb_clear_d(a);
	arb_clear_d(b);
	arb_clear_d(x);
	arb_clear_d(t);

	FreeLibrary(hArb);

	return 0;
}
```

```
$ gcc -I/var/local/include arb_dll_demo.c
```

```
$ ./a.exe
a   = 1.0000000000000000000000132348898008484427979425390731 +/- 0
b   = 75557863725914323419136.5 +/- 0
x   = 2.718281828459045235360287471352662497757247093739638 +/- 1.1407e-300
e   = 2.7182818284590452353602874713526624977572470936999596 +/- 3.7331e-301
x-e = 3.9678376581476207465438603498757884997818078351607135e-47 +/- 1.514e-300
Computed with Arb 2.17.0
```
