
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
    $b =~ s{\&} {\&amp;}gs;
    $b =~ s{\<} {\&lt;}gs;
    $b =~ s{\>} {\&gt;}gs;
    $b =~ s{\"} {\&quot;}gs;
    $b =~ s{\~\~\~tag\[} {\<}gs;
    $b =~ s{\]tag\~\~\~} {\>}gs;
    $b =~ s{$} {"<br>".$1 }gme;
    $a."<dd><tt>".$b."</tt></dd>".$c
    }gsex;

# make file references hot...
s{ ((?:http|ftp|mailto):/*) ([\w\.\/\~\-]+) }
{
    my ($a,$b) = ($1,$2);
    my $c = $b; $c =~ s/^www\.//;
    " <a href=\"$a$b\"> ".$c." </a> "
    }gmex;
s{ ([\.\/]+)([\w\.\/\~\-]+) }
{ -f "$1$2"
? "<a href=\"$1$2\"> ".$2." </a> "
: -f "../$1$2"
? "<a href=\"../$1$2\"> ".$2." </a> "
: length $1 > 3
? "<a href=\"$1$2\"> ".$2." </a> "
: $1.$2
}gmex;

# and look for these too...
s{ (\$Id: index-v.pl,v 1.6 2001/06/09 15:27:55 mlg Exp $]+ \$) }
{ "<small><tt>".$1."</small></tt>" }gmex;
s{ \(\( ([^\(\)]+) \)\) }
{ " &nbsp;<small><small>(".$1.")</small></small>&nbsp; " }gmex;
s{ (\=\&gt\;)(\s+)([^\s\<\>]+) }
{ "<small>".$1."</small>".$2."<b>".$3."</b>" }gmex;

my $text = $_;

if (not length $title)
{
    $title = $ENV{PWD};
    $title =~ s{/([^/]+)$}{$1}gmex;
}

print "<head><title>".$title."</title>\n";
print "<meta name=\"generator\" content=\"$0\" date=\"".(scalar localtime)."\" />\n";
if (-f "$where.css")
{ print "<link rel=\"stylesheet\" media=\"screen\" href=\"../$where.css\" />\n"; }
elsif (-f "../forth.css")
{ print "<link rel=\"stylesheet\" media=\"screen\" href=\"../../forth.css\" />\n"; }
print "</head><body>\n";
print $text;
print "</body>\n";
