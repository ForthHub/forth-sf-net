
index:
	sed -e "s/<body>/<!--BODY-->/" \
	-e "/BODY-->/r sf-forthlinks.html" < rev1.html > index.html

zip:
	zip -9 ../fst83.zip \
	$(TXT_FILES) $(HTM_FILES) $(EXT_FILES) $(CHK_FILES)
