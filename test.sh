#!/bin/sh

TEST=tests
file=$(ls $TEST)
./src/iris.native -l $1> source.llvm
llc source.llvm -o source.s
clang -c src/lib/liblist.c
clang source.s src/lib/liblist.o -o main
rm source.s source.llvm
./main
