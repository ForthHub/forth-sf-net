
TXT_FILES = fst83-0.txt fst83-1.txt fst83-2.txt fst83-3.txt fst83-4.txt \
	fst83-5.txt fst83-6.txt fst83-7.txt fst83-8.txt fst83-9 \
	fst83-10.txt fst83-11.txt fst83-12.txt fst83-13.txt \
	fst83-14.txt fst83-15.txt fst83-16.txt \
	fst83-a.txt fst83-b.txt fst83-c.txt fst83-d.txt fst83-e.txt

HTM_FILES = $(TXT_FILES:.txt=.htm) fst83.htm
EXT_FILES = FORTH-83.PRN forth.css Makefile
CHK_FILES = fst83chk.fs \
	fst83_12.fs fst83_13.fs fst83_14.fs fst83_15.fs fst83_16.fs \
	fst83_b.fs fst83_c.fs

index:
	ln -s fst83.htm index.html
	cp ../../forth.css forth.css

zip:
	zip -9 ../fst83.zip \
	$(TXT_FILES) $(HTM_FILES) $(EXT_FILES) $(CHK_FILES)
