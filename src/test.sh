#!/bin/sh

./iris.native -l file.ir> source.llvm
llc source.llvm -o source.s
clang source.s -o main
rm source.s source.llvm
./main
