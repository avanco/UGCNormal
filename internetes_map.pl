#!/usr/bin/env perl

use Data::Dumper;
use Encode qw / decode encode /;
use utf8;

%internetes = ();

open INT, $ARGV[0] or die $!;
open INT_SIGL_ABRV, $ARGV[1] or die $!;
open TEXT_FILE, $ARGV[2] or die $!;

chomp(@int= <INT>);
chomp(@int_sigl_abrv= <INT_SIGL_ABRV>);
@text_lines = <TEXT_FILE>;

# internetes
# remove first line: description csv fields
shift @int;
foreach (@int) {
    $internetes{$1} = $2 if /(.*?),(.*?),/;
    #print "$1\t$internetes{$1}\n";
}
# internetes_siglas_abreviaturas
# remove first line: description csv fields
shift @int_sigl_abrv;
foreach (@int_sigl_abrv) {
    $internetes{$1} = $2 if /(.*?),(.*?),/;
    #print "$1\t$internetes{$1}\n";
}

$output_text = '';
foreach $l (@text_lines) {
    # first normalize vowel repetitions
    $l =~ s/([a|e|i|o|u])\1{2,}/$1/g;
    $l = decode('utf-8', $l);
	$l =~ s/mem \./memória/g;
	$l =~ s/transf \./transferência/g;
    for $k (keys %internetes) {
        $sub = decode('utf-8', $internetes{$k});
        $l =~ s/\b$k\b/$sub/gi;
    }
    $output_text .= $l;
}

$output_text = encode('utf-8', $output_text);

# se sentenca esta comecando com minuscula, passar para caixa alta
if ($output_text =~ /^(\p{Ll})(.*)$/) {
    $output_text = uc($1).$2."\n";
}

print $output_text;
