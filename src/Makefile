iris.native:
	opam config exec -- \
	ocamlbuild -use-ocamlfind iris.native

# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log ocamlllvm *.diff parser.ml parser.mli
