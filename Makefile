
SUBDIRS = naming people mirror syntax system website word wordset standard
LINKS = from/people sys/system web/website ws/wordset std/standard
HTDOCS = /home/groups/f/fo/forth/htdocs
HTHOST = shell.sourceforge.net

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

upload-zip:
	zip -9r forth.zip $(SUBDIRS) mk/ *.* Makefile
	scp -prvC forth.zip \
		$(USER)@$(HTHOST):$(HTDOCS)
	rm forth.zip
#	ssh && cd /home/groups/forth/htdocs && unzip forth.zip

upload:
	scp -prvC . $(HTHOST):$(HTDOCS)

copy:
	cp -rf . $(HTDOCS)
	chmod -R --quiet a+rw  $(HTDOCS)
# mlg -- 09.06.2001 -- it seems that now it's on the same server

perms:
	chgrp -R forth $(HTDOCS)
	chmod g+w $(HTDOCS)
	chmod a+r $(HTDOCS)

upload-user:
	scp -prvC . $(USER)@$(HTHOST):$(HTDOCS)
