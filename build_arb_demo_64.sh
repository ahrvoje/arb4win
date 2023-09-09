#!/usr/bin/env bash

gcc -Ibuild/x86_64/include -Ibuild/x86_64/include/flint arb_demo.c -obuild/x86_64/bin/static_demo.exe -Lbuild/x86_64/lib -lflint -lmpfr -lgmp
