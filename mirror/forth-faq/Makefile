FILES= books general groups online systems vendors ANSForth README.1
p=ftp://
x=ftp.forth.org/pub/Forth/FAQ/

mirror:
	@ UPDATED="" \
	; for i in $(FILES) ; do : \
	; wget --timestamping --quiet $p$x/$$i \
	; if cvs diff $$i >/dev/null ; then UPDATED="$$UPDATED $$i" ; fi \
	; done \
	; if test "_$$UPDATED" != "_" ; then : \
	; echo cvs ci -m '"'mirror updated on `date +%Y-%m-%d`'"' $$UPDATED \
	; fi

index:
	-cp -f $x/* .
	@ TOPDIR=$(TOPDIR) ; test -z "$$TOPDIR" && TOPDIR="../.." \
	; echo perl "*TOPDIR/mk/index-v.pl index-v.txt >index.html" \
	;      perl $$TOPDIR/mk/index-v.pl index-v.txt >index.html

