
SUBDIRS = people mirror system website word wordset
LINKS = from/people sys/system web/website ws/wordset

default: web

web: index links

index:
	for i in $(SUBDIRS) ; do : \
	; if test -f $$i/Makefile  \
	; then $(MAKE) -C $$i index \
	; else $(MAKE) -C $$i -f ../mk/M-subdir.mk index \
	; fi \
	; (cd $$i && perl ../mk/index-dirs.pl >index.html) \
	; done
	perl mk/index.pl $(SUBDIRS) >index.html

links:
	@ dirname  setting/links         # just testing for
	@ basename setting/links         # their existance
	@ for i in $(LINKS) \
	; do : \
	; echo ln -s `basename $$i` `dirname $$i` \
	;      ln -s `basename $$i` `dirname $$i` \
	; done

clean:
	rm -f *~ */*~ */*/*~

zip:
	test -d $$HOME/pub || mkdir $$HOME/pub
	zip -9r $$HOME/pub/forth-`date +%m%d`.zip $(SUBDIRS) mk/ *.* Makefile




