
s=home.earthlink.net/%7Eneilbawd
f=toolbelt.html

mirror:
	wget --mirror --timestamping --level=1 --quiet --no-parent $s/$f

index:
	cp $s/*.html .
	if test -f $f ; then : \
	; cat $f | sed \
	-e 's,</H2>,<small>(<a href="http://$s/$f">copy from $s</a>)</small></H2>,' \
	> index.html \
	; fi ; true


