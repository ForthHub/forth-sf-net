
SUBDIRS = naming people mirror syntax system website word wordset standard Standard+ techniques reversal-word about algorithm
LINKS = from:people sys:system web:website ws:wordset std:standard
HTGROUP= groups/f/fo/forth/htdocs
HTDOCS = /home/$(HTGROUP)
HTHOST = shell.sourceforge.net

# * DOCDIR is the prefix path to "make install" the webserver files into and
#   on a real unix system it shall go into /usr/share - on shell.sf.net the
#   prefix would be /home i.e. you could use `make install DOCDIR=/home` to
#   install directly to the webserver while being ssh'd to shell.sf.net
# * the top index.html will end up in /usr/share/groups/f/fo/forth/htdocs
#   but you can override it using `make install FORTHDOC=$HOME/forth-r` to
#   let it end up as ~/forth-r/index.html
# * you can try a test-install in a subdirectory of the normal webserver
#   place by overriding SUFFIX, e.g `make install SUFFIX=/test` and the
#   toplevel index.html should end up in xxx/forth/htdocs/test/
DOCDIR=/usr/share
SUFFIX=
FORTHDOC=$(DOCDIR)/$(HTGROUP)$(SUFFIX)

# ---------------------------------------------------------------------------
SHELL = sh
mkinstalldirs = $(SHELL) mkinstalldirs
# ---------------------------------------------------------------------------
default: web
it: # install while being on shell.sf.net
	$(MAKE) install DOCDIR=/home "IGNORED= : "
	@ for i in $(HTDOCS)/* ; do : \
	; if test -d $$i ; then if test ! -f $$i/mkinstalldirs ; then : \
	; echo "chgrp -R forth $$i" \
	;       chgrp -R forth $$i \
	; echo "chmod -R g+w   $$i" \
	;       chmod -R g+w   $$i \
	; echo "chmod -R a+r   $$i" \
	;       chmod -R a+r   $$i \
	; fi fi done ; true

direct: # a shortcut for building on shell.sourceforge.net itself.
	$(MAKE) install perms DOCDIR=/home
test:   # a shortcut for building on shell.sourceforge.net itself.
	$(MAKE) install perms DOCDIR=/home SUFFIX=/test/$(USER)

# ---------------------------------------------------------------------------
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
	@ for i in $(LINKS) ; do : \
	; FRM=`echo $$i | sed s/.*://` ; TGT=`echo $$i | sed s/:.*//`
	; if test ! -e $$TGT ; then \
	; echo "ln -s $$FRM $$TGT" \
	;       ln -s $$FRM $$TGT || break \
	; else echo ": $$FRM --> $$TGT" \
	; fi ; done

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

#
# rupload allows you to do a "make install", "make upload" (with rsync in
# order to transmit only the differences) and "make updone".
#
rupload:
	$(MAKE) install
	-rsync -e ssh -crlHSz $(FORTHDOC)/ $(HTHOST):$(HTDOCS)/
	$(MAKE) updone 2> /dev/null


perms:
	@ for i in $(HTDOCS)/* ; do : \
	; if test -d $$i ; then if test ! -f $$i/mkinstalldirs ; then : \
	; echo "chgrp -R forth $$i" \
	;       chgrp -R forth $$i \
	; echo "chmod -R g+w   $$i" \
	;       chmod -R g+w   $$i \
	; echo "chmod -R a+r   $$i" \
	;       chmod -R a+r   $$i \
	;   for j in `find $$i -name CVS` ; do : \
	;   test ! -f $$j/Entries || rm $$j/Entries \
	;   test ! -f $$j/Repository || rm $$j/Repository \
	;   test ! -f $$j/Root || rm $$j/Root \
	;   echo "rmdir $$j" \
	;         rmdir $$j \
	;   done \
	; fi fi done ; true

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


mirrors:
	@ for i in mirror/* ; do if test -f $$i/Makefile \
	; then $(MAKE) -C $$i mirror \
	; fi done

# -------------------------------------------------------------------
# different approach: choose "make install" to put the wealth
# of pages into a directory path of the local system. Then, assemble
# the files installed into a dist-tarball/rpm, and carry elsewhere.
DISTFILES= forth.css forth2.css bg.gif 4ring.gif Makefile \
	index-l.txt index-l.htm index-r.txt index-r.htm index.header \
	mkinstalldirs

INDEXFILE=index.html

install-dir installdir :
	test -d $(DESTDIR)$(FORTHDOC) || $(mkinstalldirs) $(DESTDIR)$(FORTHDOC)

install :
	@ echo "START INSTALL TO:" $(DESTDIR)$(FORTHDOC)
	test -d $(DESTDIR)$(FORTHDOC) || $(mkinstalldirs) $(DESTDIR)$(FORTHDOC)
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
	; if test -d $(DESTDIR)$(FORTHDOC)/$$i ; then : \
	; echo ::dir $(DESTDIR)$(FORTHDOC)/$$i ; else : \
	; echo mkdir $(DESTDIR)$(FORTHDOC)/$$i \
	;      mkdir $(DESTDIR)$(FORTHDOC)/$$i \
	; fi \
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
	@ for i in $(LINKS) ; do : \
	; FRM=`echo $$i | sed s/.*://` ; TGT=`echo $$i | sed s/:.*//` \
	; if test ! -e "$(DESTDIR)$(FORTHDOC)/$$TGT" ; then : \
	; echo "(cd $(DESTDIR)$(FORTHDOC) && ln -s $$FRM $$TGT)" \
	;       (cd $(DESTDIR)$(FORTHDOC) && ln -s $$FRM $$TGT) \
	; else echo "(cd $(DESTDIR)$(FORTHDOC) && : $$FRM '-->' $$TGT)" \
	; fi ; done ; true

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
