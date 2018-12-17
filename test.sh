#!/bin/sh


./src/iris.native tests/pass_test_inputint.ir > source.llvm
llc source.llvm -o source.s
<<<<<<< HEAD
#clang -c src/lib/liblist.c
clang source.s src/lib/liblist.o src/lib/libstr.o -o main
=======
clang source.s src/inputint.o src/inputfile.o src/inputgui.o src/sendmail.o -o main `pkg-config --libs gtk+-3.0`
>>>>>>> external function
rm source.s source.llvm
./main
