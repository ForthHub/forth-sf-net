
my $F = $ARGV[0];

open F, "<$F" or die "$F: could not open: $!";
$_ = join("",<F>); close F;

my $where = $ENV{PWD}; $where =~ s{ ^ .*/  } {}sx;

my $title = "";
s{ (^)title:(.*) } { $title = $2; $1." <a href=\"..\"> / $where / </a>\n<h1> $2 </h1>\n<dl>" }mex;
s{ (^)([\w\-\.]+:) } { $1." <dt> ".$2." </dt><dd><ul> \n" }gmex;
s{ (^)(\>+\s)} { $1." <br> ".$2 }gmex;
s{ (^)(\.\s) } { $1." <br> ".$2 }gmex;
s{ (^)(\*\s) } { $1." <li> ".$2 }gmex;
s{ (^)(\-\s) } { $1." <li> " }gmex;
s{ (^)(---+) } { $1."\n </dl>\n<hr />\n" }gmex;
s{ (http://)([\w\.\/\~\-]+) } {
    my ($a,$b) = ($1,$2);
    my $c = $b; $c =~ s/^www\.//;
    " <a href=\"$a$b\"> ".$c." </a> " }gmex;
s{ ((?:\.\./)+)([\w\.\/\~\-]+) } {
    " <a href=\"$1$2\"> ".$2." </a> " }gmex;
s{ ((?:\.\/\./)+)([\w\.\/\~\-]+) } {
    " <a href=\"$1$2\"> ".$2." </a> " }gmex;
s{ (\./)([\w\.\/\~\-]+\.html) } {
    " <a href=\"$1$2\"> ".$2." </a> " }gmex;
s{ (\./)([\w\.\/\~\-]+\.txt) } {
    " <a href=\"$1$2\"> ".$2." </a> " }gmex;
s{ (\$Id: index-people.pl,v 1.1.1.1 2000/10/26 07:41:23 guidod Exp $]+ \$) } { "<small><tt>".$1."</small></tt>" }gmex;
s{ \(\( ([^\(\)]+) \)\) } { " &nbsp;<small><small>(".$1.")</small></small>&nbsp; " }gmex;

s{ (<dd><ul>) ((?:.(?!</?(?:dd|dt|dl)>))*.) (</?(?:dt|dl)>) } { $1.$2."</ul></dd>".$3 }gsex;
s{ (<li>) ((?:.(?!</?(?:li|ul|ol|dl|dd|dt)>))*.) (</?(?:li|ul|ol|dl|dd|dt)>) }
    { $1.$2."</li>".$3 }gsex;

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

