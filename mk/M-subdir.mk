all:
	@echo call make index directly

index:
	@ for i in * ; do : \
	; if test -f $$i/Makefile  \
	; then $(MAKE) -C $$i index \
	; fi \
	; if test -f $$i/index-v.txt  \
	; then echo $$i/index-v.txt '->' $$i/index.html \
	; perl ../mk/index-v.pl $$i/index-v.txt >$$i/index.html \
	; fi \
	; done

