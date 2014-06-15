CAMLP4=
OCAMLC_OPTS=-package regen_event,zolog
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

NON_LIB_MODULES=simple.ml \
	simple_with_metrics.ml \
	simple_expanded.ml \
	simple_with_extra.ml \
	file_backend.ml

native_bin=$(NON_LIB_MODULES:%.ml=%.native)

byte_bin=$(NON_LIB_MODULES:%.ml=%.byte)

.PHONY: all native-code byte-code test clean

all: native-code byte-code

native-code: $(native_bin)

simple.native: simple.cmx

simple_expanded.native: simple_expanded.cmx

simple_with_extra.native: simple_with_extra.cmx

file_backend.native: file_backend.cmx

byte-code: $(byte_bin)

simple.byte: simple.cmo

simple_expanded.byte: simple_expanded.cmo

simple_with_extra.byte: simple_with_extra.cmo

file_backend.byte: file_backend.cmo

clean: extra_clean

extra_clean:
	-rm -f *.native *.byte *.cmx *.cmo *.o *.cmi

# Dependencies
include ../lib/Ocamlrules.mk.in
