#! /usr/bin/env perl
eval 'exec perl -S $0 ${1+"$@"}'
    if 0;

use strict;                             # unix shell command:
use File::Temp qw( tempfile tempdir );  # mktemp
use File::Path qw( mkpath rmtree );     # mkdir -p | rm -r
use File::Copy qw( copy );              # cp
use Cwd        qw( cwd );               # pwd
use File::Find qw( find );              # find

my $help = "make.pl command [args|opts]...\n"
    ."commands:\n"
    ."  dist            make dist tarball/zipfile\n"
    ."  index <where>   make index.html files\n"
    ."  links <where>   setup alias links\n";

# options-hash: use as $o{optionname} to check for commandline options.
my %opt;
my @ARGS;

{  # scan the argument list, options and files and dirs, fill %X file-hash ...
    my $old = ""; # pushback of $arg
    my $arg;
    for $arg (@ARGV)
    {
        if ($arg =~ /^--?help/) { print $help; exit 0; }
        if ($arg =~ /^--?(\w[\w-]*)=(.*)/) { $opt{$1} = $2; next; }
        if ($arg =~ /^--?no-([a-z].*)/) { $opt{$1} = ""; next; }
        if ($arg =~ /^--?([a-z].*)/) { $opt{$1} = "*"; next; }
        if ($arg =~ /^-[A-Z]/) { die "illegal option $arg"; }

	push @ARGS, $arg;
    }
}

# The rest of the file is organized in terms of sub-functions that will
# get triggered by commands given as arguments - in general the first
# non-option argument i.e. "make.pl index" to create index files. In order
# to statisfy "use strict", the "main" routine is near the end of file.

# ------------------------------------------------------------------------
my @DISTFILES = ("forth.css", "forth2.css", "bg.gif", "4ring.gif",
		 "index-l.txt", "index-l.htm", "index-r.txt", "index-r.htm",
		 "index.header",             "make.pl");
my @SUBDIRS = ("naming", "people", "mirror", "syntax", "system",
	       "website", "word", "wordset", "standard", "Standard+",
	       "techniques", "reversal-word", "about", "algorithm");
my %LINKS = (from => "people",
	     sys =>  "system",
	     web =>  "website",
	     ws =>   "wordset",
	     std =>  "standard");
my $HTGROUP = "groups/f/fo/forth/htdocs";
my $HTHOST  = "shell.sourceforge.net";
# ------------------------------------------------------------------------
# helper: move to column - the length of the input string is taken current
sub col36                # column and some spaces are printed to STDOUT
{
    my $column = length $_[0];
    return if 36 <= $column;
    return " " x (36 - $column);
}
sub col22
{
    my $column = length $_[0];
    return if 22 <= $column;
    return " " x (22 - $column);
}
sub runs
{
    my $line = join (" ",@_);
    print $line, "\n";
    `$line`;
}
sub runx
{
    my $path = shift @_;
    my $line = join (" ",@_);
    if ($path eq "" or $path eq ".")
    {
	print "   ", $line, "\n";
	`$line`;
    }else{
	print "cd ", $path, " &&\n   ", $line, "\n";
	`cd $path && $line`;
    }
}
sub echo
{
    my $line = join (" ",@_);
    print $line, "\n";
}
sub E
{
    my $line = join (" ",@_);
    print $line, "\n";
}
#sub ln_s # $where $args...
#{
#    my $where = shift @_;
#    runx $where, "ln -s", @_;
#}
sub ln_s # $where $from $link
{
    my ($where,$from,$into) = @_;
    my $ol = cwd();
    chdir $where if length $where > 1;
    echo "cd $where" if length $where > 1;
    echo "   ln -s",$from,$into;

    my $implemented = eval { symlink($from,$into); 1 };
    if (not $implemented)
    {
	if (-f $from and $from =~ m:[.]html$: or $from =~ m:[.]htm$:)
	{
	    my $F = $from;
	    if (open F, "< $F")
	    {
		my $T = join ("",<F>); close F;
		$T =~ s:<body>:<!--SYMLINK--><body>:;
		$F = $into;
		if (open F, "> $F")
		{
		    print F $T; close F;
		}
	    }
	}
    }
    chdir $ol if length $where > 1;
}
sub zip # $where $args...
{
    my $where = shift @_;
    runx $where, "zip", @_;
}
sub tar # $where $args...
{
    my $where = shift @_;
    runx $where, "tar", @_;
}
sub gzip1 # $where $args...
{
    my $where = shift @_;
    runx $where, "gzip", @_;
}
sub bzip2 # $where $args...
{
    my $where = shift @_;
    runx $where, "bzip2", @_;
}
sub perl # $script $command \@args
{
    my $line = "perl '$_[0]' '$_[1]'";
    my $arg;
    for $arg (@{$_[2]})
    {
	$line .= " '".$arg."'";
    }
    for $arg (keys %opt)
    {
	if ($opt{$arg} eq "*")
	{
	    $line .= " '--".$arg.'"';
	}else{
	    $line .= " '--".$arg."=".$opt{$arg}."'";
	}
    }
    echo "SKIP ",$line;
}
sub make # $script $command \@args
{
    my $line = "make -f '$_[0]' '$_[1]'";
    my $arg;
    for $arg (@{$_[2]})
    {
	$line .= " '".$arg."'";
    }
    for $arg (keys %opt)
    {
	$line .= " '".$arg."=".$opt{$arg}."'";
    }
    echo "SKIP ",$line;
}

sub make_links # $where
{
    my $dir = $_[0];
    $dir = "." if not length $dir;
    -d $dir or die "no such directory: $dir: $!";
    my $name;
    for $name (keys %LINKS)
    {
	if (-d $LINKS{$name})
	{
	    ln_s "$dir", $LINKS{$name}, $name;
	}else{
	    echo ": ",$LINKS{$name}," --> ",$name;
	}
    }
}

# ------------------------------------------------------------------------
#              this part had been the "index-v.pl" script !!!!!

sub index_v # $where $src $htm
{
    my ($where,$src,$htm) = @_;
    echo "cd $where &&" if length $where > 1;
    echo "   index_v",$src,">",$htm;
    my $ol = cwd();
    chdir $where if length $where;


    my $F = $src;
    open F, "< $F" or die "$F: could not open: $!";
    $_ = join("",<F>); close F;

    $F = $htm;
    open F, "> $F" or die "$F: could not open: $!";

    my $which = $ENV{PWD}; $which =~ s{ ^ .*/  } {}sx;

    my $title = "";
    s{ (^)title:(.*) }
    { $title = $2;
      $1." <a href=\"..\"> / $which / </a>\n<h1> ".$2." </h1>\n<dl>"
      }mex;

    # mark each section start
    # and some linestarts have also special replacements
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
	$b =~ s{^<[a-z/].*>\ *$ } { my $v = $&;
				    $v =~ s{\"} {\~\~\~quote!}gs;
				    $v =~ s{<} {\~\~\~tag[}gs;
						$v =~ s{>} {]tag\~\~\~}gs;
				    $v }gmex;
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
	$b =~ s{ $ } {"<br>".$1 }gmex;
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
	$title =~ s{ / ([^/]+) $ }{$1}gmex;
    }

    print F "<head><title>".$title."</title>\n";
    print F "<meta name=\"generator\" content=\"$0\" ";
    print F "date=\"".(scalar localtime)."\" />\n";
    print F "<link rel=\"derived-from\" href=\"$F\" />\n";
    if (-f "$which.css")
    {
	print F "<link rel=\"stylesheet\" media=\"screen\" ";
	print F "href=\"$which.css\" />\n";
    }
    elsif (-f "../../forth2.css")
    {
	print F "<link rel=\"stylesheet\" media=\"screen\" ";
	print F "href=\"../../forth2.css\" />\n";
    }
    print F "</head><body>\n";
    print F $text;
    print F $html_footer;
    print F "</body>\n";

    close F;
    chdir $ol if length $where;
}

# ------------------------------------------------------------------------
#              this part had been the "index-dirs.pl" script !!!!!

# this one shall generate the index for a set of subdirectories. Remember,
# that on forth.sourceforge the first and second level of the file tree
# is almost empty. Only the third level of the file tree may contain
# arbitrary information and archive files. The others have usually just
# a single index.html file. This script tries to intelligently assemble
# an index.html file from the various snippets it can find in that directory.

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

sub index_dirs # $where $subdir $htm
{
    my ($to,$subdir,$htm) = @_;
    $to = "." if not length $to;
    -d $to or die "no such directory: $to: $!";
    echo "cd $to &&" if length $to > 1;
    echo "   index_dirs",$subdir,">","$subdir/$htm";
    my $ol = cwd();
    $to .= "/".$subdir if length $subdir > 1;
    chdir $to if length $to > 1;

    my $sourceforge_logo =
        '    <a href="http://sourceforge.net/projects/forth">
         <img src="http://sourceforge.net/sflogo.php?group_id=12692"
                width="88" height="31" border="0" alt="SourceForge Logo">
        </a>';


    # detect first or second level by looking for forth.css
    my $forth_css;
    if (-f "forth.css") { $forth_css = "forth.css"; }
    elsif (-f "../forth.css") { $forth_css = "../forth.css"; }
    else { die "could not find forth.css"; }

    # detect the section name
    # my $section_name;
    # if ($forth_css !~ /^\.\./) { $section_name = "Index"; }
    # else { $section_name = dir2sec($ENV{PWD}); }
    my $section_name = "Index";
    $section_name = dir2sec($subdir) if length $subdir > 1;

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
	next if -l $F; # symlinks are already there, so this is an update run..
	next if -f "$F/mkinstalldirs"; # CVS on the webserver? that's okay..

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
    $F = $htm;
    open F, "> $F" or die "could not open: $F: $!";
    print F "<html><head><title> ".$section_name;
    print F                   " (".$site_name.") </title> \n";
    print F "<meta name=\"generator\" content=\""
	.$0."\" date=\"".(scalar localtime)."\">\n";
    print F "<link rel=stylesheet type=\"text/css\" media=\"screen\" "
	."href=\"".$forth_css."\">\n";
    print F "</head><body>\n";
    print F $html_header;
    print F '<table width="100%" border="0">'
	. '<tr valign="top"><td width=50% valign="top">'
	.$html_l_pane."\n</td><td width=\"50%\" rowspan=\"2\">\n".$html_r_pane
	."</td></tr>"
	.'<tr valign="top"><td width=50% valign="bottom">'
	.$html_l_text."\n</td></tr></table>\n";
    print F $html_footer."\n</body></html>\n";
    close F;

    chdir $ol if length $to > 1;
}

# ------------------------------------------------------------------------
sub make_subdir_install # $where $which
{
    my $to = $_[0];
    my $in = $_[1];
    my $ol = cwd();
    $to .= "/".$in; # target
    chdir $in;       # source
    my $dir;
    echo " FIND",col22(""),"..",$in,"..";
    for $dir (<*>)
    {
	next if not -d $dir;
	next if $dir eq "CVS";
	next if -f "$dir/IGNORE.DIR";
	next if -f "$dir/IGNORE.TXT";
	# echo "   cd $in/ ",(length $dir ? "($dir)" : "");
	find (sub{
	    return if m:~$: or m:.bak$:;
	    return if -l $_;
	    my $name = $File::Find::dir;
	    if (m:CVS: or $name =~ m:/CVS$: or $name =~ m:/CVS/:)
	    {   $File::Find::prune = 1; return; }
	    # echo $name,$_;
	    if (-d $_)
	    {
		$_ = "" if $_ eq ".";
		echo "mkdir","",col22(""),"*/$in/$name/$_";
		mkdir                       "$to/$name/$_";
		# -d "$dir/$name" or mkdir "$dir/$name"
		#     or die "cannot create directory: $dir/$name: $!";
	    }else{
		echo "copy ",$_,col22($_),"*/$in/$name/$_";
		copy         $_,            "$to/$name/$_";
	    }
	}, $dir);
    }
    chdir $ol;
}

sub make_subdir_index # $where $which
{
    my $to = $_[0];
    my $in = $_[1];
    my $ol = cwd();
    $to .= "/".$in; # target
    chdir $in;       # source
    my $dir;
    for $dir (<*>)
    {
	next if not -d $dir;
	next if $dir eq "CVS";
	next if -f "$to/$dir/IGNORE.DIR";
	next if -f "$to/$dir/IGNORE.TXT";
	# echo "------- $in/$dir -------";
	if (-f "$to/$dir/make.pl")
	{
	    echo "SKIP","perl","make.pl", "index","#","*/$dir";
	    # perl "$to/$dir", "make.pl", "index";
	}
	elsif (-f "$to/$dir/$dir.html")
	{
	    # echo "ln_s", "$dir.html", "index.html","#","*/$dir";
	    ln_s "$to/$dir", "$dir.html", "index.html";
	}
	elsif (-f "$to/$dir/$dir.htm")
	{
	    # echo "ln_s", "$dir.htm", "index.html","#","*/$dir";
	    ln_s "$to/$dir", "$dir.htm", "index.html";
	}
	elsif (-f "$to/$dir/index-v.txt")
	{
	    # echo "index_v", "index-v.txt", "index.html","#","*/$dir";
	    index_v "$to/$dir", "index-v.txt", "index.html";
	}
    }
    chdir $ol;
}


# ------------------------------------------------------------------------
sub make_install # $where
{
    my $to = $_[0];
    $opt{datadir} = "/usr/share"                  if not length $opt{datadir};
    $opt{groups}  = "$HTGROUP"                    if not length $opt{groups};
    $opt{docdir}  = "$opt{datadir}/$opt{groups}"  if not length $opt{docdir};
    $opt{destdir} = "" if not exists $opt{destdir};
    $to = $opt{destdir}.$opt{docdir} if not length $to;
    echo "START INSTALL TO:",$to;
    echo "mkpath $to";
    -d $to or mkpath $to or die "could not create: $to: $!";
    my $file;
    for $file (@DISTFILES)
    {
     E "copy", $file, "$to/$file";
	copy   $file, "$to/$file";
    }
    echo "mkpath $to/mk";
    -d "$to/mk" or
	mkpath "$to/mk" or die "could not create: $to/mk: $!";
    echo "copy mk/*.* $to/mk";
    for $file (<mk/*.*>)
    {
	next if $file =~ /~$/;
	print ".";   copy $file, "$to/$file";
    }   print "\n";
    my $dir;
    for $dir (@SUBDIRS)
    {
	echo "mkpath $to/$dir";
	-d "$to/$dir" or
	    mkpath "$to/$dir" or die "could not create: $to/$dir: $!";
	if (-x "$dir/make.pl")	{
	    perl "$dir/make.pl", "install", \@_;
	}else{
	    make_subdir_install $to, $dir;
	}

	for $file (qw( bg.gif ))
	{
	    next if -f  "$to/$dir/$file";
	    copy $file, "$to/$dir/$file";
	}
    }
    for $dir (@SUBDIRS)
    {
	if (-x "$dir/make.pl")	{
	    perl "$dir/make.pl", "index", \@_;
	}else{
	    make_subdir_index $to, $dir;
	}

	index_dirs "$to", "$dir", "index.html";
    }   index_dirs "$to", ".",    "index.html";

    make_links "$to";
}

sub make_index # $where
{
    my $to = $_[0];
    $to = "." if not length $to;
    -d $to or die "no such directory: $to: $!";

    my $file;
    for $file (qw( bg.gif ))
    {
	next if -f  "$to/$file";
	my $here = cwd();
	ln_s "$to", "$here/$file", "$file";
    }
    my  $dir;
    for $dir (@SUBDIRS)
    {
	if (-x "$dir/make.pl")	{
	    perl "$dir/make.pl", "index", \@_;
	}else{
	    make_subdir_index $to, $dir;
	}

	index_dirs "$to", "$dir", "index.html";
    }   index_dirs "$to", ".",    "index.html";

    make_links "$to";
}

sub make_dist # ()
{
    my $datecode = `date '+%Y%m%d'`; chomp $datecode;
    my $pkg = "forth-repository-$datecode";
    my $tmp = tempdir( TMPDIR => 1, CLEANUP => 1 );
    echo "mkdir $tmp/$pkg";
    mkdir "$tmp/$pkg" or die "could not create: $tmp/$pkg: $!";
    my $prj = cwd();
 E "make_install","$tmp/$pkg";
    make_install ("$tmp/$pkg");
    zip "$tmp/$pkg", "-9r", "$prj/$pkg.zip", ".";
 E "make_links","$tmp/$pkg";
    make_links ("$tmp/$pkg");
    tar "$tmp",      "cvf", "$prj/$pkg.tar", "$pkg";
    bzip2 ".", "-9 --keep", "$pkg.tar";
    gzip1 ".", "-9 -f",     "$pkg.tar";
}
# ------------------------------------------------------------------------
sub main
{
    for (@_)
    {
	shift @_;
	make_index (@_)    if /^index$/;
	make_dist  (@_)    if /^dist$/;
	make_install  (@_) if /^install$/;
	make_links (@_)    if /^links$/;
    }
}

main (@ARGS);
exit 0;

