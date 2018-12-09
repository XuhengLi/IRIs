.PHONY : all
all : iris.native inputint.o

iris.native:
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkg llvm -package llvm.analysis iris.native

inputint: inputint.c
	cc -o inputint inputint.c

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
