package soundex;

# Author: Lucas Avanço
# Mar 30 2014

use strict;
#use warnings;
use utf8;

use Exporter qw / import /;
our @EXPORT_OK = qw / do_soundex /;

my %soundex = ();

$soundex{'a'} = 0;
$soundex{'e'} = 0;
$soundex{'i'} = 0;
$soundex{'o'} = 0;
$soundex{'u'} = 0;
$soundex{'h'} = 0;
$soundex{'w'} = 0;
$soundex{'y'} = 0;

# accents
$soundex{'á'} = 0;
$soundex{'à'} = 0;
$soundex{'â'} = 0;
$soundex{'ã'} = 0;
$soundex{'é'} = 0;
$soundex{'è'} = 0;
$soundex{'ê'} = 0;
$soundex{'ẽ'} = 0;
$soundex{'í'} = 0;
$soundex{'ì'} = 0;
$soundex{'î'} = 0;
$soundex{'ĩ'} = 0;
$soundex{'ó'} = 0;
$soundex{'ò'} = 0;
$soundex{'ô'} = 0;
$soundex{'õ'} = 0;
$soundex{'ú'} = 0;
$soundex{'ù'} = 0;
$soundex{'û'} = 0;
$soundex{'ũ'} = 0;

$soundex{'b'} = 1;
$soundex{'f'} = 1;
$soundex{'p'} = 1;
$soundex{'v'} = 1;

$soundex{'c'} = 2;
$soundex{'ç'} = 2;
$soundex{'g'} = 2;
$soundex{'j'} = 2;
$soundex{'k'} = 2;
$soundex{'q'} = 2;
$soundex{'s'} = 2;
$soundex{'x'} = 2;
$soundex{'z'} = 2;

$soundex{'d'} = 3;
$soundex{'t'} = 3;

$soundex{'l'} = 4;

$soundex{'m'} = 5;
$soundex{'n'} = 5;

$soundex{'r'} = 6;

sub do_soundex {
	my $word = shift;
	my $sound_code = '';
	# mantain the first letter
	#my $first = substr($word, 0, 1);
	#$sound_code .= $first;
	# get all the correspondent code for each letter
	for (my $i=0; $i<length($word); $i++) {
		my $letter = substr($word, $i, 1);
		my $code = $soundex{$letter};
		$sound_code .= $code if $code;
	}
	# remove consecutive identical digits
	$sound_code =~ s/(\d)\1/$1/g;
	# remove all zeros
	$sound_code =~ tr/0//d;
	# pad trailing zeros
	if (4-length($sound_code) >= 0) {
		$sound_code .= '0'x(4-length($sound_code));
	} else {
		# truncate to code length == 4
		$sound_code = substr $sound_code, 0, 4;
	}
	return $sound_code
}

# We need the 1; at the end because when a module loads, Perl checks to see that the module returns a true value to ensure it loaded OK.
1;
