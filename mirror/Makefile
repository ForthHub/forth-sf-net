
include ../mk/M-subdir.mk

mirror:
	for i in * ; do : \
	; if test -f $$i/Makefile  \
	; then $(MAKE) -C $$i mirror \
	; fi \
	; done


