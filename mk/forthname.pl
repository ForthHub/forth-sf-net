package forth::nameguess;
use strict;

# convert an xm-encoded string into a filename-compatible string
# which is actually a string consisting of alphas and minus-chars.
# example: "&lt;#s" -> less-num-s
# example: "#K1297-G20" -> num-k-twelve-ninetyseven-g-twenty
sub nameguess
{
    my $n = shift;

    $n =~ tr{A-Z}{a-z};
    $n =~ s{^ - -}   {minus-minus-}gsx;
    $n =~ s{  - - $ } {-minus-minus}gsx;
    $n =~ s{^ - }  {minus-}gsx;
    $n =~ s{  - $ } {-minus}gsx; # all other minus get squeezed later...

# the angle heuristics
    $n =~ s{^ &gt; $ } {-greater-}gsx;
    $n =~ s{^ &lt; $ } {-less-}gsx;

    $n =~ s{ &gt; &gt; } {-push-}gsx;
    $n =~ s{ &lt; &lt; } {-pull-}gsx;
    $n =~ s{ &gt; &lt; } {-greater-less-}gsx;
    $n =~ s{ &lt; &gt; } {-not-equals-}gsx;

    $n =~ s{ &gt; $ } {-from-}gsx;
    $n =~ s{ &lt; $ } {-less-than-}gsx;

    $n =~ s{ &gt; } {-to-}gsx;
    $n =~ s{ &lt; } {-less-}gsx;

# go for the asciis (in order)

    $n =~ s{ \  } {-hidden-}gsx;
    $n =~ s{ \! } {-store-}gsx;
    $n =~ s{ &quot; } {-quote-}gsx;
    $n =~ s{ \# } {-num-}gsx;
    $n =~ s{ \? } {-q-}gsx;
    $n =~ s{ \= } {-set-}gsx;
    $n =~ s{ \$ } {-var-}gsx;
    $n =~ s{ \% } {-mod-}gsx;
    $n =~ s{ &amp; } {-and-}gsx;
    $n =~ s{ \' } {-tick-}gsx;
    $n =~ s{ \( ([^\(\)]*) \) } {-paren-$1}gsx;
    $n =~ s{ \( } {-paren-}gsx;
    $n =~ s{ \) } {-endparen-}gsx;
    $n =~ s{ \* } {-star-}gsx;
    $n =~ s{ \+ } {-plus-}gsx;
    $n =~ s{ \, } {-comma-}gsx;
    $n =~ s{ \. } {-dot-}gsx;
    $n =~ s{ \/ } {-slash-}gsx;
    $n =~ s{ \: } {-colon-}gsx;
    $n =~ s{ \; } {-semicolon-}gsx;
    $n =~ s{ \= } {-set-}gsx;
    $n =~ s{ \? } {-Q-}gsx;
    $n =~ s{ \@ } {-fetch-}gsx;
    $n =~ s{ \[ ([^\[\]]*) \] } {-bracket-$1}gsx;
    $n =~ s{ \[ } {-bracket-}gsx;
    $n =~ s{ \] } {-endbracket-}gsx;
    $n =~ s{ \\ } {-backslash-}gsx;
    $n =~ s{ \^ } {-control-}gsx;
    $n =~ s{ \` } {-backtick-}gsx;
    $n =~ s{ \{ } {-start-}gsx;
    $n =~ s{ \} } {-end-}gsx;
    $n =~ s{ \| } {-or-}gsx;
    $n =~ s{ \~ } {-about-}gsx;

# the numbers, try to seperate per two digits
    $n =~ s{ 0(\d) } {-o~$1-}gsx;
    $n =~ s{ 1(\d) } {-ten~$1-}gsx;
    $n =~ s{ 2(\d) } {-twenty~$1-}gsx;
    $n =~ s{ 3(\d) } {-thirty~$1-}gsx;
    $n =~ s{ 4(\d) } {-fourty~$1-}gsx;
    $n =~ s{ 5(\d) } {-fifty~$1-}gsx;
    $n =~ s{ 6(\d) } {-sixty~$1-}gsx;
    $n =~ s{ 7(\d) } {-seventy~$1-}gsx;
    $n =~ s{ 8(\d) } {-eighty~$1-}gsx;
    $n =~ s{ 9(\d) } {-ninety~$1-}gsx;
    $n =~ s{ o~0 } {-hundred-}gsx;
    $n =~ s{ ten~1 } {eleven}gsx;
    $n =~ s{ ten~2 } {twelve}gsx;
    $n =~ s{ ten~3 } {thirteen}gsx;
    $n =~ s{ ten~4 } {fourteen}gsx;
    $n =~ s{ ten~5 } {fifteen}gsx;
    $n =~ s{ ten~6 } {sixteen}gsx;
    $n =~ s{ ten~7 } {seventeen}gsx;
    $n =~ s{ ten~8 } {eightteen}gsx;
    $n =~ s{ ten~9 } {nineteen}gsx;
    $n =~ s{ ~0 } {}gsx;
    $n =~ s{ ~1 } {one}gsx;
    $n =~ s{ ~2 } {two}gsx;
    $n =~ s{ ~3 } {three}gsx;
    $n =~ s{ ~4 } {four}gsx;
    $n =~ s{ ~5 } {five}gsx;
    $n =~ s{ ~6 } {six}gsx;
    $n =~ s{ ~7 } {seven}gsx;
    $n =~ s{ ~8 } {eight}gsx;
    $n =~ s{ ~9 } {nine}gsx;
    $n =~ s{ 0 } {-zero-}gsx;
    $n =~ s{ 1 } {-one-}gsx;
    $n =~ s{ 2 } {-two-}gsx;
    $n =~ s{ 3 } {-three-}gsx;
    $n =~ s{ 4 } {-four-}gsx;
    $n =~ s{ 5 } {-five-}gsx;
    $n =~ s{ 6 } {-six-}gsx;
    $n =~ s{ 7 } {-seven-}gsx;
    $n =~ s{ 8 } {-eight-}gsx;
    $n =~ s{ 9 } {-nine-}gsx;

# and anything else..
    $n =~ s{ [^\w\-] } {X}gsx;

# now squeeze the minus-chars...
    $n =~ s{ \-\-+ } {-}gsx;
    $n =~ s{ ^ \-} {}gsx;
    $n =~ s{   \- $ } {}gsx;

    return $n;
}

for (@ARGV)
{
    s{&} {&amp;}gs; s{<} {&lt;}gs; s{>} {&gt;}gs; s{\"} {&quot;}gs;

    print nameguess($_);
}

1;
