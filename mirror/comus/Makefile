
# http://www.albany.net/~hello/comus.htm
x=www.albany.net/%7Ehello
f=comus.htm

mirror:
	wget --mirror --timestamping --level=1 --no-parent $x/$f

index:
	cp $x/*.html $x/*.htm .
	cp $f index.html


