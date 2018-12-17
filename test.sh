#!/bin/sh


./src/iris.native tests/test_bin_search.ir> source.llvm
llc source.llvm -o source.s

clang source.s src/inputint.o src/inputfile.o src/lib/*.o src/cmd.o src/inputstring.o src/sendmail.o src/inputfloat.o -o main
rm source.s source.llvm
./main
