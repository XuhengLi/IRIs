#!/bin/sh


./src/iris.native $1> source.llvm
llc source.llvm -o source.s

clang source.s src/lib/*.o -o main
rm source.s source.llvm
./main
