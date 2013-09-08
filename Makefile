.PHONY: all clean test

all:
	$(MAKE) -C lib

test: all
	$(MAKE) -C tests test
	$(MAKE) -C lib test

clean:
	$(MAKE) -C lib clean

