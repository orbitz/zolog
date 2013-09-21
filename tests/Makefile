export OCAMLPATH:=$(OCAMLPATH):../lib

CAMLP4=
OCAMLC_OPTS=-package regen_event,zolog
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

NON_LIB_MODULES= \
	zolog_std_event_writer_backend_tests.ml \
	zolog_std_event_file_backend_tests.ml

native_bin=$(NON_LIB_MODULES:%.ml=%.native)

byte_bin=$(NON_LIB_MODULES:%.ml=%.byte)

.PHONY: all native-code byte-code test clean

all: native-code byte-code

native-code: $(native_bin)

zolog_std_event_writer_backend_tests.native: zolog_std_event_writer_backend_tests.cmx

zolog_std_event_file_backend_tests.native: zolog_std_event_file_backend_tests.cmx

byte-code: $(byte_bin)

zolog_std_event_writer_backend_tests.byte: zolog_std_event_writer_backend_tests.cmo

zolog_std_event_file_backend_tests.byte: zolog_std_event_file_backend_tests.cmo

test: all
	./zolog_std_event_writer_backend_tests.native
	./zolog_std_event_file_backend_tests.native

clean: extra_clean

extra_clean:
	-rm -f *.native *.byte *.cmx *.cmo *.o *.cmi

# Dependencies
include ../lib/Ocamlrules.mk.in
