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

## Binaries

/local/bin

/local/lib

## Workflow

ARBpackage.7z contains all sufficient material to simply build all static and dynamic libraries. After unpacking the archive in any desired folder, after starting msys.bat script one must simply execute the following command line in just started shell:

```buildARB.sh
```

This script performs an entire workflow with timing & log files written in /tmp folder. You can check on the process viewing them as they are appended by buildARB.sh script.

## Demo

