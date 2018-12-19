.PHONY : all
all : iris.native lib/inputint.o lib/inputfile.o lib/inputstring.o lib/cmd.o lib/inputfloat.o lib/liblist.o lib/libstr.o

.PHONY : GUI
GUI : iris.native lib/inputint.o lib/inputfile.o lib/inputstring.o lib/cmd.o lib/inputfloat.o lib/inputgui.o

iris.native:
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkg llvm -package llvm.analysis iris.native

# inputint: inputint.c
# 	clang -o inputint inputint.c

# inputstring: inputstring.c
# 	clang -o inputstring inputstring.c

# inputfile: inputfile.c
# 	clang -o inputfile inputfile.c

# cmd: cmd.c
# 	clang -o cmd cmd.c

# inputgui.o: inputgui.c
# 	clang `pkg-config --cflags gtk+-3.0` -c inputgui.c `pkg-config --libs gtk+-3.0`=


# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log ocamlllvm *.diff parser.ml parser.mli
	rm -rf *.o

.PHONY : debug
debug:
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkg llvm -package llvm.analysis iris.d.byte

.PHONY : prettyp
parser:
	ocamllex scanner.mll
	ocamlyacc parser.mly
	ocamlc -c ast.mli
	ocamlc -c parser.mli
	ocamlc -c scanner.ml
