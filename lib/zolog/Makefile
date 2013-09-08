CAMLP4=
OCAMLC_OPTS=-package regen_event,core,async,async_core
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

LIB_MODULES=zolog.ml zolog_std_event.ml zolog_event.ml
NON_LIB_MODULES=

BYTE_TARGETS=zolog.cma
NATIVE_TARGETS=zolog.cmxa

.PHONY: all test

all: native-code byte-code

test:

# Dependencies
include ../Ocamlrules.mk.in
