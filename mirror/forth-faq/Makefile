FILES= books general groups online systems vendors ANSForth
p=ftp://
x=ftp.forth.org/pub/Forth/FAQ/


mirror:
	for i in $(FILES) ; do \
	wget --mirror --timestamping --level=1 --no-parent $p$x/$$i \
	; done

index:
	-cp -f $x/* .
	perl ../../mk/index-v.pl index-v.txt >index.html
