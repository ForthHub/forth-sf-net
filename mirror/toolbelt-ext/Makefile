
s=home.earthlink.net/%7Eneilbawd
f=toolbelt.html

mirror:
	wget --mirror --timestamping --level=1 \
		--no-parent $s/$f

index:
	cp $s/*.html .
	if test -f $f ; then mv $f index.html ; fi ; true


