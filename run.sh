#!/bin/sh

make clean && autoreconf -vif && ./configure  --prefix=/home/quasikote/proj/scheme-ocl/build && make -j8 install
./pre-inst-env sh repl.scm
