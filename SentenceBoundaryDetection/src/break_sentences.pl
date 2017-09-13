#!/usr/bin/env perl

use Data::Dumper;

open TEXT_FILE, $ARGV[0] or die $!;
@text = <TEXT_FILE>;

$all_text = '';
foreach $line (@text) {
    chomp $line;
    $all_text .= " ".$line;
}
@sentences = split("<S>", $all_text);
foreach (@sentences) {
    print "$_\n";
}
