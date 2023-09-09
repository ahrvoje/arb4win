#!/usr/bin/env bash

gcc -Ibuild/x86_64/include -Ibuild/x86_64/include/flint arb_dll_demo.c -obuild/x86_64/bin/shared_demo.exe
