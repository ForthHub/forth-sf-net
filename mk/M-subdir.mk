LN_S=ln -s

all:
	@echo call make index or make install directly

index:
	@ for i in * ; do \
	; if test -f $$i/Makefile  \
	; then $(MAKE) -C $$i index \
	; elif test -f $$i/$$i.html  \
	; then echo $$i/$$i.html '->' $$i/index.html \
	; (cd $$i && $(LN_S) $$i.html index.html) \
	; elif test -f $$i/$$i.htm  \
	; then echo $$i/$$i.htm '->' $$i/index.html \
	; (cd $$i && $(LN_S) $$i.htm index.html) \
	; elif test -f $$i/index-v.txt  \
	; then echo $$i/index-v.txt '->' $$i/index.html \
	; (cd $$i && perl ../../mk/index-v.pl index-v.txt >index.html) \
	; fi \
	; done

IGNORED= echo ' :'
# IGNORED= :
STDDISTFILES=index-r.txt index-l.txt index-r.htm index-l.htm index.header
install:
	@ TOPDIR=$(TOPDIR) ; test -z "$$TOPDIR" && TOPDIR=`pwd`"/.." \
	; for i in * ; do : \
	; test -d $$i || continue \
	; test $$i != "CVS" || continue \
	; test ! -f $$i/IGNORE.DIR || continue \
	; test ! -f $$i/IGNORE.TXT || continue \
	; test ! -f %%i/IGNORE.TXT || continue \
	; echo ======= $$i ========= \
	; for f in $(STDDISTFILES) ; do : \
	; if test -f $$f \
	; then echo cp $$f $(DESTDIR)$(FORTHDOC)/$$f \
	;           cp $$f $(DESTDIR)$(FORTHDOC)/$$f \
	; fi ; done \
	; for f in `find $$i` ; do : \
	; case $$f \
	in */CVS/*|*/CVS|*~|*.bak) $(IGNORED) $$f \
	;; *) if test -d $$f ; then : \
	; echo mkdir $(DESTDIR)$(FORTHDOC)/$$f \
	;      mkdir $(DESTDIR)$(FORTHDOC)/$$f \
	; else : \
	; echo cp $$f $(DESTDIR)$(FORTHDOC)/$$f \
	;      cp $$f $(DESTDIR)$(FORTHDOC)/$$f \
	; fi \
	;; esac \
	; done \
	; if test -f $(DESTDIR)$(FORTHDOC)/$$i/Makefile  \
	; then echo $(MAKE) -C $(DESTDIR)$(FORTHDOC)/$$i index \
	;   $(MAKE) -C $(DESTDIR)$(FORTHDOC)/$$i index TOPDIR=$$TOPDIR \
	; elif test -f $(DESTDIR)$(FORTHDOC)/$$i/$$i.html  \
	; then echo $$i/$$i.html '->' $$i/index.html \
	; (cd $(DESTDIR)$(FORTHDOC)/$$i && $(LN_S) $$i.html index.html) \
	; elif test -f $(DESTDIR)$(FORTHDOC)/$$i/$$i.htm  \
	; then echo $$i/$$i.htm '->' $$i/index.html \
	; (cd $(DESTDIR)$(FORTHDOC)/$$i && $(LN_S) $$i.htm index.html) \
	; elif test -f $(DESTDIR)$(FORTHDOC)/$$i/index-v.txt  \
	; then echo $$i/index-v.txt '->' $(DESTDIR)$(FORTHDOC)/$$i/index.html \
	; (cd $(DESTDIR)$(FORTHDOC)/$$i \
	&& perl $(TOPDIR)/mk/index-v.pl index-v.txt >index.html) \
	; fi \
	; done
