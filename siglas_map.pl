#!/usr/bin/env perl

use Data::Dumper;
use Parallel::Loops;

%low2up = ();

open SIGLAS, $ARGV[0] or die $!;
open TEXT_FILE, $ARGV[1] or die $!;

chomp(@siglas = <SIGLAS>);
@text_lines = <TEXT_FILE>;

# remove first line: description csv fields
shift @siglas;
foreach (@siglas) {
    $low2up{lc $1} = uc $1 if /(.*?),/;
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
