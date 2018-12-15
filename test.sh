#!/bin/sh

TEST=tests
file=$(ls $TEST)
./src/iris.native -l tests/pass_test_inputint.ir> source.llvm
llc source.llvm -o source.s
clang source.s src/inputint.o -o main
rm source.s source.llvm
./main
