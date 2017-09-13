package pt_sound;

# Author: Lucas Avanço
# May 08 2014

#use strict;
#use warnings;
use utf8;
use List::MoreUtils qw / uniq /;
use Encode qw / encode decode /;

use Exporter qw / import /;
our @EXPORT_OK = qw / sound_cmp sound_encode /;

#use Data::Dumper;

sub rule_1 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/c(a)/1$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/c(o)/1$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/c(u)/1$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/k/1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/qu/1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/q([aeiou])/1$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/x([aeiou])/*$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/x$/*/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/cs/1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/c([^aeiouh])/1$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_2 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/c(e)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/c(i)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ç/2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ss/2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/^s([^h])/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ls/l2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/rs/r2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ns/n2/gr;
	push @all_w, $new_w;
	#$w =~ s/ns/2/g;
	$new_w = $w =~ s/([aeiou])s([aeiou])/${1}2$2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/s([^aeiou])/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/xc(e)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/xc(i)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/x([^aeiou])/*$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/sc(e)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/sc(i)/2$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/z$/2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/s$/2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/z([^aeiou])/2$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_3 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/ch([aeiou])/3$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/sh([aeiou])/3$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/x([aeiou])/*$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_4 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/([^lnms])s([aeiou])/${1}4$2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/([^lns])z([aeiou])/${1}4$2/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_5 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/g([ei])/5$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/j([ei])/5$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_6 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/es?$/6/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/is?$/6/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_7 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/o(s?)$/7$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/([^aeiou])u(s?)$/${1}7$2/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_8 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/([aeiou])l([^aeiou])/${1}8$2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/([aeiou])u([^aeiou])/${1}8$2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/([aeiou])o([^aeiou])/${1}8$2/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_9 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/(.+)r([aeiou])/${1}9$2/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/rr/9/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_10 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/pi([^aeiou])/\{$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/p([^aeiou])/\{$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_11 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/d([^aeiou\d])/\[$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/de/\[/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/di/\[/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_12 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/e([^aeiou\d\*])/<$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ei([^aeiou\d\*])/<$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_13 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/g([^aeiou])/\}$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/gui/\}/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_14 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/b([^aeiou])/\]$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/bi/\]/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_15 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/m([^aeiou])/~$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/n([^aeiou])/~$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_16 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/x$/\^/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/x([aeiou])/\^$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/cs/\^/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/cç/\^/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/quis/\^/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/quiç/\^/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ques/\^/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_17 {
	# heuristic 0: ex: aste -> haste
	my $w = shift;
	return $w;
}

sub rule_18 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/li([aeiou])/\-$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/lh([aeiou])/\-$1/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_19 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/n/\*/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/nh/\*/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_20 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/am$/\%/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/ão$/\%/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

sub rule_21 {
	my $w = shift;
	my @all_w = ();
	$new_w = $w =~ s/c([^aeiou])/\+$1/gr;
	push @all_w, $new_w;
	$new_w = $w =~ s/qui/\+/gr;
	push @all_w, $new_w;
	return uniq @all_w;
}

# parameters:
# $w = word to be phonetic encoded
# $rule = what rule to apply (1..20)
sub sound_encode {
	my $w = shift;
	my $rule = shift;
	$w = decode('utf-8',$w);
	my $original_w = $w;
	# x => generate three different codes.
	# A unique code for x occurrence => * == 1 or 2 or 3 or 4

	# tirar acentos
	$w =~ s/[áâãàä]/a/g;
	$w =~ s/[éêẽèë]/e/g;
	$w =~ s/[íîĩìï]/i/g;
	$w =~ s/[óôõùü]/o/g;
	$w =~ s/[úûũùü]/u/g;

	@codes = &{'rule_'.$rule}($w);
	@all_codes = ();
	foreach (@codes) {
		push @all_codes, encode('utf-8',$_);
	}

	return @all_codes;
}

sub sound_cmp {
	my $w1 = shift;
	my $w2 = shift;
	#print "$w1\t$w2\n";
	# look for w2 inside w1
	if (length($w1) != length($w2)) {
		return undef;
	}
	$w1 =~ s/[áâã]/a/g; $w2 =~ s/[áâã]/a/g;
	$w1 =~ s/[éêẽ]/e/g; $w2 =~ s/[éêẽ]/e/g;
	$w1 =~ s/[íîĩ]/i/g; $w2 =~ s/[íîĩ]/i/g;
	$w1 =~ s/[óôõ]/o/g; $w2 =~ s/[óôõ]/o/g;
	$w1 =~ s/[úûũ]/u/g; $w2 =~ s/[úûũ]/u/g;
	#DEBUG
=pod
	for (my $i=0; $i<length($w1); $i++) {
		my $w1_letter = substr $w1, $i, 1;
		my $w2_letter = substr $w2, $i, 1;
		print "$w1_letter\t-\t$w2_letter\n";
	}
=cut
	#END-DEBUG
	return 1 if $w1 eq $w2;
	for (my $i=0; $i<length($w1); $i++) {
		my $w1_letter = substr $w1, $i, 1;
		my $w2_letter = substr $w2, $i, 1;
		if ($w1_letter eq $w2_letter) {
			next;
		} elsif ($w1_letter eq '*') {
			if ($w2_letter eq '1' or $w2_letter eq '2' or $w2_letter eq '3' or $w2_letter eq '4') {
				next;
			}
			return undef;
		} elsif ($w2_letter eq '*') {
			if ($w1_letter eq '1' or $w1_letter eq '2' or $w1_letter eq '3' or $w1_letter eq '4') {
				next;
			}
			return undef;
		} else {
			return undef;
		}
	}
	return 1;
}

1;
