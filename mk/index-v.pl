
my $F = $ARGV[0];

open F, "<$F" or die "$F: could not open: $!";
$_ = join("",<F>); close F;

my $where = $ENV{PWD}; $where =~ s{ ^ .*/  } {}sx;

my $title = "";
s{ (^)title:(.*) }
{ $title = $2;
  $1." <a href=\"..\"> / $where / </a>\n<h1> ".$2." </h1>\n<dl>"
  }mex;

# mark each section start, and some linestarts have also special replaments
s{ (^)(\.\s) } { $1." <br> ".$2 }gmex;
s{ (^)(\:\s) } { $1."<spanforth>".$2 }gmex;
s{ (^)(\;\s) } { $1.$2."</spanforth>" }gmex;
s{ (^)(---+) } { $1."</dl><hr />\n" }gmex;
s{ (^)([\w\-\.]+)(:) }
{ my ($a,$b,$c)=($1,$2,$3);
  my $k = $b; $k =~ tr/\-/\ /;
  $a." <dt><b><a name=\"$b\">".$k.$c."</b></dt>"
  }gmex;
s{ (^)(>[\ \t])(.*) }
{ my ($a,$b,$c)=($1,$2,$3);
  $c =~ s{\ }{chr(0xA0)}gse;
  $c =~ s{\t}{7 x chr(0xA0)}gse;
  $a.$b.$c
  }gmex;
s{ (<spanforth>) ((?:.(?!</?spanforth>))*.) (</spanforth>)}
{ my $b = $2; $b =~ s{ }{chr(0xA0)}gse; $b }gsex;

# anything inbetween is considered as verbatim text
s{ (</dt>) ((?:.(?!</?(?:dt|hr|dl)\b))*.) }
{
    my ($a,$b,$c) = ($1,$2,$3);
    $b =~ s{^<[a-z/].*> *$} { my $v = $&;
		    $v =~ s{\"} {\~\~\~quote!}gs;
		    $v =~ s{<} {\~\~\~tag[}gs;
                    $v =~ s{>} {]tag\~\~\~}gs;
		    $v }gme;
    $b =~ s{\&} {\&amp;}gs;
    $b =~ s{\<} {\&lt;}gs;
    $b =~ s{\>} {\&gt;}gs;
    $b =~ s{\"} {\&quot;}gs;
    $b =~ s{\~\~\~tag\[} {\<}gs;
    $b =~ s{\]tag\~\~\~} {\>}gs;
    $b =~ s{\~\~\~quote!} {\"}gs;
    $b =~ s{\~\~\~\n\r} {\<quasibr\>}gm;
    $b =~ s{\~\~\~\r\n} {\<quasibr\>}gm;
    $b =~ s{\~\~\~\n} {\<quasibr\>}gm;
    $b =~ s{\~\~\~\r} {\<quasibr\>}gm;
    $b =~ s{$} {"<br>".$1 }gme;
    $b =~ s{\<quasibr\>} {\n}gm;
    $a."<dd><tt>".$b."</tt></dd>".$c
    }gsex;

# make file references hot...
# mlg: I do not remember what chars are allowed after #'s (\x23),
#      but it seems alphanum and - and . are ok.
#      Correct me if you have time.
s{ ((?:http|ftp|mailto):/*) ([\w\.\/\~\-\%]+) (\x23[0-9a-zA-Z\-\.]+)? }
{
    my ($a,$b,$d) = ($1,$2,$3);
    my $c = $b; $c =~ s/^www\.//;
    " <a href=\"$a$b$d\"> ".$c." </a> "
    }gmex;
s{ ([\.\/]+)([\w\.\/\~\-\%]+) (\x23[0-9a-zA-Z\-\.]+)? }
{ -f "$1$2"
? "<a href=\"$1$2$3\"> ".$2." </a> "
: -f "../$1$2"
? "<a href=\"../$1$2$3\"> ".$2." </a> "
: length $1 > 3
? "<a href=\"$1$2$3\"> ".$2." </a> "
: $1.$2.$3
}gmex;

# and look for these too...
s{ (\$ Id : [^\$]+ \$) }
{ "<small><tt>".$1."</small></tt>" }gmex;
s{ \(\( ([^\(\)]+) \)\) }
{ " &nbsp;<small><small>(".$1.")</small></small>&nbsp; " }gmex;
s{ (\=\&gt\;)(\s+)([^\s\<\>]+) }
{ "<small>".$1."</small>".$2."<b>".$3."</b>" }gmex;

my $html_footer =
    "\n<p align=right><small>"
    ."<i>generated </i>"
    .(scalar localtime)
    ."<sup><u>".$ENV{USER}."</u></sup>"
    ."\n</small></p>";

s{([^\240\040])\240([^\240\040])}{\1\040\2}gs;
s{\240}{\&nbsp;}gs;

my $text = $_;

if (not length $title)
{
    $title = $ENV{PWD};
    $title =~ s{/([^/]+)$}{$1}gmex;
}

print "<head><title>".$title."</title>\n";
print "<meta name=\"generator\" content=\"$0\" date=\"".(scalar localtime)."\" />\n";
print "<link rel=\"derived-from\" href=\"$F\" />\n";
if (-f "$where.css")
{
  print "<link rel=\"stylesheet\" media=\"screen\" href=\"$where.css\" />\n";
}
elsif (-f "../../forth2.css")
{
  print "<link rel=\"stylesheet\" media=\"screen\" href=\"../../forth2.css\" />\n";
}
print "</head><body>\n";
print $text;
print $html_footer;
print "</body>\n";
