
use strict;

# this one shall generate the index for a set of subdirectories. Remember,
# that on forth.sourceforge the first and second level of the file tree
# is almost empty. Only the third level of the file tree may contain
# arbitrary information and archive files. The others have usually just
# a single index.html file. This script tries to intelligently assemble
# an index.html file from the various snippets it can find in that directory.

my $sourceforge_logo =
        '    <a href="http://sourceforge.net/projects/forth">
         <img src="http://sourceforge.net/sflogo.php?group_id=12692"
                width="88" height="31" border="0" alt="SourceForge Logo">
        </a>';

sub dir2sec
{
    local $_ = $_[0];
    s{.*/}{};
    y{\-}{ };
    s{ forth $ } { "Forth" }sex;
    s{ \b([a-z]{1,2})\b } { uc($1) }gsex;
    s{ ^ (\w\w\w) $ } { uc($1) }gsex;
    s{ (^|\s) ([a-z]) }{ $1.uc($2) }sex if /^[a-z]+$/;
    return $_;
}

# detect first or second level by looking for forth.css
my $forth_css;
if (-f "forth.css") { $forth_css = "forth.css"; }
elsif (-f "../forth.css") { $forth_css = "../forth.css"; }
else { die "could not find forth.css"; }

# detect the section name
my $section_name;
if ($forth_css !~ /^\.\./) { $section_name = "Index"; }
else {
    $section_name = dir2sec($ENV{PWD});
}

my $site_name = "comp.lang.forth.repository";
my $html_header;
$html_header = '<table width="100%"><tr><td width="30%" align="left">';
$html_header .= "\n<h2><i> ".$section_name." </i></h2>\n";
$html_header .= '</td><td width="30%" align="center">';
$html_header .= "\n<h1> ".$site_name." </i></h2>\n";
$html_header .= '</td><td width="30%" align="right">';
$html_header .= "\n ".$sourceforge_logo." \n";
$html_header .= "</td></tr></table>\n";

my $html_footer =
    "\n<p align=right><small>"
    ."<i>generated </i>"
    .(scalar localtime)
    ."<sup><u>".$ENV{USER}."</u></sup>"
    ."\n</small></p>";

my %index = ( );
my ($F,$D);
opendir D, "." or die "could not open local dir: $!";
while ($F = readdir D)
{
    next if $F eq "CVS"; # you run it inside a cvs-tree itself? bad boy...
    next if -l $F; # the symlinks are already there, so this is an update run..
    next if -f "$F/mkinstalldirs"; # a cvs-tree on the webserver? that's okay..

    if (-d "$F" and length $F > 2)
    {
	if (-f "$F/index.html")
	{
	    $index{$F} = "$F/index.html";
	}elsif (-f "$F/index.htm")
	{
	    $index{$F} = "$F/index.htm";
	}elsif (-f "$F/$F.html")
	{
	    $index{$F} = "$F/$F.html";
	}elsif (-f "$F/$F.htm")
	{
	    $index{$F} = "$F/$F.htm";
	}else
	{
	    $index{$F} = "$F/";
	}
    }
} closedir D;

my $html_l_pane = "<ul>\n";
my $big = "span"; $big = "big" if scalar %index < 20;
my %secnames;
my %secfiles;
my $secname;
my $sec;
for $F (sort keys %index)
{
    next if $F =~ /^(\w\w)$/;
    $secname = dir2sec($F);
    if (-f $index{$F})
    {
	if (open F, "<$index{$F}")
	{
	    my $T = join ("",<F>); close F;
	    if ($T =~ m{<(title|TITLE)>([^<>]*)</(title|TITLE)>}s)
	    { $secname = $2; "" }
	    # HEY, WHAT WAS THAT FOR? I JUST DON'T REMEMBER...
	    $secname =~ s{\([\w\s\.]+\)}{};
	}else{
	    print STDERR " ...could not open $index{$F}: $!\n";
	}
    }
    $sec = $secname;
    $sec =~ y/[a-z]/[A-Z]/;
    $secnames{$sec.$F} = $secname;
    $secfiles{$sec.$F} = $F;
}
for $sec (sort keys %secnames)
{
    $html_l_pane .= "<li><$big><a href=\"".$index{$secfiles{$sec}}."\">"
 	.$secnames{$sec}."</a></$big></li>\n";
} $html_l_pane .= "</ul>\n";

my $html_l_text = "";
if (-f "index-l.htm")
{
    $F = "index-l.htm";
    open F, "<$F" or die "could not open $F: $!";
    $html_l_text .= join ("",<F>); close F;
}elsif (-f "index-l.txt")
{
    $F = "index-l.txt";
    open F, "<$F" or die "could not open $F: $!";
    $html_l_text .= "<small><pre>";
    $html_l_text .= join ("",<F>); close F;
    $html_l_text .= "</pre></small>";
}

# this section should perhaps do a lot more.
my $html_r_pane = "";
if (-f "index-r.htm")
{
    $F = "index-r.htm";
    open F, "<$F" or die "could not open $F: $!";
    $html_r_pane .= join ("",<F>); close F;
}elsif (-f "index-r.txt")
{
    $F = "index-r.txt";
    open F, "<$F" or die "could not open $F: $!";
    $html_r_pane .= "<pre>";
    $html_r_pane .= join ("",<F>); close F;
    $html_r_pane .= "</pre>";
}

# go for printing it
print "<html><head><title> ".$section_name." (".$site_name.") </title> \n";
print "<meta name=\"generator\" content=\""
    .$0."\" date=\""
    .(scalar localtime)."\">\n";
print "<link rel=stylesheet type=\"text/css\" media=\"screen\" "
    ."href=\"".$forth_css."\">\n";
print "</head><body>\n";
print $html_header;
print '<table width="100%" border="0">'
    . '<tr valign="top"><td width=50% valign="top">'
    .$html_l_pane."\n</td><td width=\"50%\" rowspan=\"2\">\n".$html_r_pane
    ."</td></tr>"
    .'<tr valign="top"><td width=50% valign="bottom">'
    .$html_l_text."\n</td></tr></table>\n";
print $html_footer."\n</body></html>\n";






