#!/bin/sh

TEST=tests
file=$(ls $TEST)
./src/iris.native -l $1> source.llvm
llc source.llvm -o source.s
clang source.s -o main
rm source.s source.llvm
./main
