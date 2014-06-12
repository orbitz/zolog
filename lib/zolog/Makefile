CAMLP4=
OCAMLC_OPTS=-package regen_event,core,async
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

LIB_MODULES= \
	zolog.ml zolog_std_event.ml zolog_event.ml \
	zolog_std_event_writer_backend.ml zolog_std_event_console_backend.ml \
	zolog_std_event_file_backend.ml

NON_LIB_MODULES=

BYTE_TARGETS=zolog.cma
NATIVE_TARGETS=zolog.cmxa

.PHONY: all test

all: native-code byte-code

install: all
	ocamlfind install zolog META $(BYTE_TARGETS) $(NATIVE_TARGETS) zolog.a *.cmx *.cmi *.mli


test:

# Dependencies
include ../Ocamlrules.mk.in
