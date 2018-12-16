#!/bin/sh


./src/iris.native tests/pass_test_inputgui.ir > source.llvm
llc source.llvm -o source.s
#clang -c src/lib/liblist.c
clang source.s src/lib/liblist.o src/lib/libstr.o -o main
rm source.s source.llvm
./main
