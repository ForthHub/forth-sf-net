VTXT = locals-star-or.txt

index: index.html

index.html : $(VTXT)
	@ TOPDIR=$(TOPDIR) ; test -z "$$TOPDIR" && TOPDIR="../.." \
	; for i in $? ; do : \
	; echo perl "*TOPDIR/mk/index-v.pl $$i >tmp.html" \
	;      perl $$TOPDIR/mk/index-v.pl $$i >tmp.html \
	; test -f tmp.html && mv tmp.html `basename $$i .txt`.html \
	; done \
	; echo perl "*TOPDIR/mk/index-v.pl index-v.txt >$@"  \
	;      perl $$TOPDIR/mk/index-v.pl index-v.txt >$@

