
SUBDIRS = naming people mirror syntax system website word wordset standard
LINKS = from:people sys:system web:website ws:wordset std:standard
HTGROUP= groups/f/fo/forth/htdocs
HTDOCS = /home/$(HTGROUP)
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
	@ for i in $(LINKS) ; do : \
	; FRM=`echo $$i | sed s/.*://` ; TGT=`echo $$i | sed s/:.*//`
	; echo ln -s $$FRM $$TGT \
	;      ln -s $$FRM $$TGT || break \
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
	scp -rC . $(HTHOST):$(HTDOCS)
updone:
	ssh $(HTHOST) make perms -C $(HTDOCS)


perms:
	-chgrp -R forth $(HTDOCS)
	-chmod -R g+w $(HTDOCS)
	-chmod -R a+r $(HTDOCS)
	@ for i in `find $(HTDOCS) -name CVS` ; do : \
	; test ! -f $$i/Entries || rm $$i/Entries \
	; test ! -f $$i/Repository || rm $$i/Repository \
	; test ! -f $$i/Root || rm $$i/Root \
	; rmdir $$i \
	; done ; true

copy:
	cp -rf . $(HTDOCS)
	-chmod -R --quiet g+rw  $(HTDOCS)
	-chmod -R --quiet a+r $(HTDOCS)
	-chgrp -R --quiet forth $(HTDOCS)
	@ for i in `find $(HTDOCS) -name CVS` ; do : \
	; test ! -f $$i/Entries || rm $$i/Entries \
	; test ! -f $$i/Repository || rm $$i/Repository \
	; test ! -f $$i/Root || rm $$i/Root \
	; rmdir $$i \
	; done ; true

uploads:
	zip -9r forth-$(USER).zip $(SUBDIRS) mk/ *.* Makefile
	scp -prvC forth-$(USER).zip \
		$(USER)@$(HTHOST):$(HTDOCS)
	rm forth-$(USER).zip
	ssh $(USER)@$(HTDOCS) \
	"cd $(HTDDOCS) && unzip forth-$(USER).zip && make perms"

upload-user:
	scp -rC . $(USER)@$(HTHOST):$(HTDOCS)




# -------------------------------------------------------------------
# different approach: choose "make install" to put the wealth
# of pages into a directory path of the local system. Then, assemble
# the files installed into a dist-tarball/rpm, and carry elsewhere.
DISTFILES= forth.css forth2.css bg.gif 4ring.gif Makefile \
	index-l.txt index-l.htm index-r.txt index-r.htm index.header \
	mkinstalldirs

DOCDIR=/usr/share
FORTHDOC=$(DOCDIR)/$(HTGROUP)
INDEXFILE=index.html
install:
	test -d $(DESTDIR)$(FORTHDOC) || mkinstalldirs $(DESTDIR)$(FORTHDOC)
	@ if test -n "$(DISTFILES)" ; then : \
	;    echo cp $(DISTFILES) $(DESTDIR)$(FORTHDOC) \
	;         cp $(DISTFILES) $(DESTDIR)$(FORTHDOC) \
	; fi \
	; true
	@ if test ! -d $(DESTDIR)$(FORTHDOC)/mk ; then : \
	; echo mkdir $(DESTDIR)$(FORTHDOC)/mk \
	;      mkdir $(DESTDIR)$(FORTHDOC)/mk \
	; fi \
	; echo cp 'mk/*.*' $(DESTDIR)$(FORTHDOC)/mk \
	;      cp  mk/*.*  $(DESTDIR)$(FORTHDOC)/mk \
	; true
	@ TOPDIR="$(TOPDIR)" ; test -z "$$TOPDIR" && TOPDIR=`pwd` \
	; for i in $(SUBDIRS) ; do : \
	; echo mkdir $(DESTDIR)$(FORTHDOC)/$$i \
	;      mkdir $(DESTDIR)$(FORTHDOC)/$$i \
	; if test -f $$i/Makefile  \
	; then echo $(MAKE) -C $$i install \
          FORTHDOC=$(FORTHDOC)/$$i UPINDEX=../$(INDEXFILE) TOPDIR=$$TOPDIR \
	;           $(MAKE) -C $$i install \
          FORTHDOC=$(FORTHDOC)/$$i UPINDEX=../$(INDEXFILE) TOPDIR=$$TOPDIR \
	; else echo $(MAKE) -C $$i -f TOPDIR/mk/M-subdir.mk install \
          FORTHDOC=$(FORTHDOC)/$$i UPINDEX=../$(INDEXFILE) TOPDIR=$$TOPDIR \
	;           $(MAKE) -C $$i -f $$TOPDIR/mk/M-subdir.mk install \
          FORTHDOC=$(FORTHDOC)/$$i UPINDEX=../$(INDEXFILE) TOPDIR=$$TOPDIR \
	; fi \
	; for k in bg.gif ; do : \
	; if test ! -f $(DESTDIR)$(FORTHDOC)/$$i/bg.gif \
	; then echo cp bg.gif $(DESTDIR)$(FORTHDOC)/$$i/ \
	;           cp bg.gif $(DESTDIR)$(FORTHDOC)/$$i/ \
	; fi ; done \
	; echo "(cd $(DESTDIR)$(FORTHDOC)/$$i" \
               " && perl **TOPDIR/mk/index-dirs.pl >$(INDEXFILE) )" \
	;       (cd $(DESTDIR)$(FORTHDOC)/$$i \
	         && perl $$TOPDIR/mk/index-dirs.pl >$(INDEXFILE) ) \
	; done \
	; echo "(cd $(DESTDIR)$(FORTHDOC) && perl $$TOPDIR/mk/index-dirs.pl)" \
	;       (cd $(DESTDIR)$(FORTHDOC) && perl $$TOPDIR/mk/index-dirs.pl \
			>$(INDEXFILE) )

DISTNAME=forth-repository
DATECODE=%Y%m%d
TEMP=/tmp
dist:
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` \
	; if test -d $(TEMP)/$$PKG \
	; then echo rm -rf $(TEMP)/$$PKG \
	;           rm -rf $(TEMP)/$$PKG \
	; else true ; fi
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` \
	; echo mkdir $(TEMP)/$$PKG \
	;      mkdir $(TEMP)/$$PKG
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` \
	; echo $(MAKE) install DESTDIR=$(TEMP)/$$PKG FORTHDOC=/.  \
	;      $(MAKE) install DESTDIR=$(TEMP)/$$PKG FORTHDOC=/.
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` ; BUILD=`pwd` \
	; echo "(cd $(TEMP)/$$PKG && zip -9r $$BUILD/$$PKG.zip .)" \
	;       (cd $(TEMP)/$$PKG && zip -9r $$BUILD/$$PKG.zip .)
	@ for i in $(LINKS) ; do : \
	; FRM=`echo $$i | sed s/.*://` ; TGT=`echo $$i | sed s/:.*//` \
	; echo ln -s $$FRM $$TGT \
	;      ln -s $$FRM $$TGT || break \
	; done
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` ; BUILD=`pwd` \
	; echo "(cd $(TEMP) && tar cvf $$BUILD/$$PKG.tar $$PKG)" \
	;       (cd $(TEMP) && tar cvf $$BUILD/$$PKG.tar $$PKG)
	@ PKG="$(DISTNAME)-"`date +$(DATECODE)` \
	; echo "bzip2 -9k $$PKG.tar ; gzip -9 -f $$PKG.tar" \
	; bzip2 -9 --keep $$PKG.tar ; gzip -9 -f $$PKG.tar
