all:
	@echo call make index directly

index:
	@ for i in * ; do : \
	; if test -f $$i/Makefile  \
	; then $(MAKE) -C $$i index \
	; elif test -f $$i/index-v.txt  \
	; then echo $$i/index-v.txt '->' $$i/index.html \
	; (cd $$i && perl ../../mk/index-v.pl index-v.txt >index.html) \
	; fi \
	; done

