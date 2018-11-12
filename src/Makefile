iris.native:
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkg llvm -package llvm.analysis iris.native

# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log ocamlllvm *.diff parser.ml parser.mli

.PHONY : debug
debug:
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkg llvm -package llvm.analysis iris.d.byte
