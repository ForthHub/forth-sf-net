
SUBDIRS = naming people mirror syntax system website word wordset standard
LINKS = from/people sys/system web/website ws/wordset std/standard

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
		$(USER)@shell.sourceforge.net:/home/groups/forth/htdocs
	rm forth.zip
#	ssh && cd /home/groups/forth/htdocs && unzip forth.zip

upload:
	scp -prvC . shell.sourceforge.net:/home/groups/forth/htdocs

copy:
	cp -rf . /home/groups/f/fo/forth/htdocs
	chmod -R --quiet a+rw  /home/groups/f/fo/forth/htdocs
# mlg -- 09.06.2001 -- it seems that now it's on the same server

upload-user:
	scp -prvC . $(USER)@shell.sourceforge.net:/home/groups/forth/htdocs
