FILES= comus.htm forth.htm
# http://www.albany.net/~hello/comus.htm
x=www.albany.net/%7Ehello
p=http://

mirror:
	@ UPDATED="" \
	; for i in $(FILES) ; do : \
	; wget --timestamping --quiet $p$x/$$i \
	; if cvs diff $$i >/dev/null ; then UPDATED="$$UPDATED $$i" ; fi \
	; done \
	; if test "_$$UPDATED" != "_" ; then : \
	; echo cvs ci -m '"'mirror updated on `date +%Y-%m-%d`'"' $$UPDATED \
	; fi
#	wget --mirror --timestamping --level=1 --no-parent $x/$f

index:
	cat comus.htm | sed \
	-e "/HREF=/s,forth.htm,$p$x/forth.htm," \
	-e "/HREF=/s,hello.htm,$p$x/hello.htm," \
	> index.html



