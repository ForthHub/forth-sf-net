VTXT = index-v.txt locals-star-or.txt

index: index.html

index.html : $(VTXT)
	for i in $? ; do : \
	; perl ../../mk/index-v.pl $$i >tmp.html \
	; test -f tmp.html && mv tmp.html `basename $$i .txt`.html \
	; done
	mv index-v.html index.html

