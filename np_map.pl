#!/usr/bin/env perl

use Data::Dumper;

%low2up = ();

open NPS, $ARGV[0] or die $!;
open TEXT_FILE, $ARGV[1] or die $!;

chomp(@nps = <NPS>);
@text_lines = <TEXT_FILE>;

# remove first line: description csv fields
shift @nps;
foreach (@nps) {
    $low2up{lc $1} = ucfirst $1 if /(.*)/;
    #print lc $1, "\t", ucfirst $1, "\n";
}

$output_text = '';
foreach $l (@text_lines) {
    @text_toks = split(/\s/, $l);
    foreach $t (@text_toks) {
        if (exists $low2up{lc $t}) {
            $output_text .= $low2up{lc $t}." ";
        } else {
            $output_text .= $t." ";
        }
    }
    $output_text .= "\n";
}

print $output_text;
