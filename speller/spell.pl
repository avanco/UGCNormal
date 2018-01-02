#!/usr/bin/env perl

# Author: Lucas Avanço

# use lib => for pre-processing UGCNormal module
use lib "$ENV{HOME}/ugc_norm/speller";
# use lib => run Speller
#use lib ".";
use Data::Dumper;
use Encode qw / encode decode /;
use soundex qw / do_soundex /;
use pt_sound qw / sound_cmp sound_encode /;
use Text::LevenshteinXS;
use Parallel::Loops;

# dict: unitex lexicon
%dict = ();
# ignore: words from lexicons (siglas, internetes, names)
%ignore = ();

@alphabet = (A..Z,a..z,'á','Á','é','É','í','Í','ú','Ú','ó','Ó','â','Â','ê','Ê','ô','Ô','à','À','ã','Ã','õ','Õ','ç','Ç');

@vowels = qw / a e i o u /;

# debug function
# input: phonetic code using PB-RULES
# output: what rules were applied
sub what_rules {
	$code = shift;
	print "RULES: ";
	print "1, " if ($code =~ '1');
	print "2, " if ($code =~ '2');
	print "3, " if ($code =~ '3');
	print "4, " if ($code =~ '4');
	print "5, " if ($code =~ '5');
	print "6, " if ($code =~ '6');
	print "7, " if ($code =~ '7');
	print "8, " if ($code =~ '8');
	print "9, " if ($code =~ '9');
	print "10, " if ($code =~ '\{');
	print "11, " if ($code =~ '\[');
	print "12, " if ($code =~ '\<');
	print "13, " if ($code =~ '\}');
	print "14, " if ($code =~ '\]');
	print "15, " if ($code =~ '~');
	print "16, " if ($code =~ '\^');
	#print "17, " if ($code =~ '1');
	print "18, " if ($code =~ '\-');
	print "19, " if ($code =~ '\*');
	print "20, " if ($code =~ '\%');
	print "\n";
}


# input: word (string)
# output: list of candidates, whose distance is 1 diacritic
sub diac_cands {
	$w = shift;
	@diac_suggestions = ();
	while ($w =~ /a/g) {
        $sug = $`.'á'.$';
	    push @diac_suggestions, $sug;
	}
	while ($w =~ /a/g) {
	    push @diac_suggestions, $`.'â'.$';
	}
	while ($w =~ /a/g) {
	    push @diac_suggestions, $`.'ã'.$';
	}
	while ($w =~ /e/g) {
	    push @diac_suggestions, $`.'é'.$';
	}
	while ($w =~ /e/g) {
	    push @diac_suggestions, $`.'ê'.$';
	}
	while ($w =~ /i/g) {
	    push @diac_suggestions, $`.'í'.$';
	}
	while ($w =~ /o/g) {
	    push @diac_suggestions, $`.'ó'.$';
	}
	while ($w =~ /o/g) {
	    push @diac_suggestions, $`.'ô'.$';
	}
	while ($w =~ /o/g) {
	    push @diac_suggestions, $`.'õ'.$';
	}
	while ($w =~ /u/g) {
	    push @diac_suggestions, $`.'ú'.$';
	}
	return \@diac_suggestions;
}

sub change_diac {
	$w = shift;
	if ($w =~ /á|â/) {
	    $cand = $`.'a'.$';
        return $cand;
	}
	if ($w =~ /é|ê/) {
	    $cand = $`.'e'.$';
        return $cand;
	}
	if ($w =~ /í|î/) {
	    $cand = $`.'i'.$';
        return $cand;
	}
	if ($w =~ /ó|ô/) {
	    $cand = $`.'o'.$';
        return $cand;
	}
	if ($w =~ /ú|û/) {
	    $cand = $`.'u'.$';
        return $cand;
	}
}

# given an tokenized txt file do the auto-correction
# input: input txt file name
# output: txt file spell-checked
sub pp_text {
	$file = shift;
	open INPUT_FILE, $file or die $!;
	@input = <INPUT_FILE>;
	$input_text = '';
	$output_text = '';
	foreach (@input) {
		$input_text .= $_;
	}
	@input_lines = split("\n", $input_text);
	foreach $line (@input_lines) {
		@input_toks = split(" ", $line);
		# spell check each word
		foreach (@input_toks) {
            if (/^([A-Za-zÀ-ú\-]+)$/) {
                $output_text .= &spell_check($_)." ";
            } else {
                $output_text .= "$_ ";
            }
		}
        $output_text .= "\n";
	}
    return $output_text;
}

# input: word
# output: word (correct or original word)
sub spell_check {
	$word = shift;
	$correct_word = undef;
	# position of chosen suggestion
	$word_position = 0;
	$original_word = $word;
	# lowercase
	$word = decode('utf-8', $word);
	# flag if uppercase
	$uppercase = $word =~ /\p{Lu}/;
	$word = lc $word;
	$word = encode('utf-8', $word);
	# how many words to suggest
	$known_words_size = 1;

	if ($original_word eq '-') {
		return $original_word;
	}
	if (exists $dict{$word} or exists $ignore{$word}) {
		return $original_word;
		#$correct_word = $original_word;
		#return $correct_word;
	}
	else {
		# heuristic 0: ex: aste -> haste
		$first_letter = substr $word, 0, 1;
		if ($first_letter ~~ @vowels) {
			if (exists $dict{'h'.$word}) {
				$correct_word = 'h'.$word;
				if ($uppercase) {
					$correct_word = decode("utf-8", $correct_word);
					$correct_word = ucfirst($correct_word);
					$correct_word = encode("utf-8", $correct_word);
				}
				return $correct_word;
			}
		}
        # heuristic 1: ç e ~
        # ex: acao -> ação, relacao -> relação
        if ($word =~ /(.*?)cao/) {
            $correct_word = $1."ção";
			if (exists $dict{$correct_word}) {
				if ($uppercase) {
					$correct_word = decode("utf-8", $correct_word);
					$correct_word = ucfirst($correct_word);
					$correct_word = encode("utf-8", $correct_word);
				}
				return $correct_word;
			}
			#return $correct_word if (exists $dict{$correct_word});
        } elsif ($word =~ /(.*?)coes/) {
            $correct_word = $1."ções";
			if (exists $dict{$correct_word}) {
				if ($uppercase) {
					$correct_word = decode("utf-8", $correct_word);
					$correct_word = ucfirst($correct_word);
					$correct_word = encode("utf-8", $correct_word);
				}
				return $correct_word;
			}
			#return $correct_word if (exists $dict{$correct_word});
        } elsif ($word =~ /(.*)c(.*)/) {
            $correct_word = "$1ç$2";
			if (exists $dict{$correct_word}) {
				if ($uppercase) {
					$correct_word = decode("utf-8", $correct_word);
					$correct_word = ucfirst($correct_word);
					$correct_word = encode("utf-8", $correct_word);
				}
				return $correct_word;
			}
			#return $correct_word if (exists $dict{$correct_word});
        }
		# heuristic 2: try to correct, checking diacritic differences
        # word has no diacritic, generate candidates with diacritic
		@diac_suggestions = @{&diac_cands($word)};
		foreach $sug (@diac_suggestions) {
			#return $sug if (exists $dict{$sug});
			if (exists $dict{$sug}) {
				$correct_word = $sug;
				if ($uppercase) {
					$correct_word = decode("utf-8", $correct_word);
					$correct_word = ucfirst($correct_word);
					$correct_word = encode("utf-8", $correct_word);
				}
				return $correct_word;
			}
		}
        # word has diacritic but it is wrong
        $diac_cand = &change_diac($word);
		if (exists $dict{$diac_cand}) {
			$correct_word = $diac_cand;
			if ($uppercase) {
				$correct_word = decode("utf-8", $correct_word);
				$correct_word = ucfirst($correct_word);
				$correct_word = encode("utf-8", $correct_word);
			}
			return $correct_word;
		}
		#if (exists $dict{$diac_cand}) {
			#return $diac_cand;
		#}

		# calculating Edit-distance between input word and each word in the lexicon
		# distances 1,2,... (hashs)
		# key: suggestion; value: frequency
		%d1 = ();
		%d2 = ();
		foreach (keys %dict) {
			$d = distance($word, $_);
			if ($d == 1) {
				$d1{$_} = $dict{$_};
			}
			elsif ($d == 2) {
				$d2{$_} = $dict{$_};
			}
		}
		# sort by frequency hashes with suggested words
		@suggestions1 = ();
		foreach $val (sort {$d1{$b} <=> $d1{$a}} keys %d1) {
			push @suggestions1, $val;
		}
		@suggestions2 = ();
		foreach $val (sort {$d2{$b} <=> $d2{$a}} keys %d2) {
			push @suggestions2, $val;
		}
		# merge all Suggestions, for each distance: 1 and 2
		@suggestions = ();
		push @suggestions, @suggestions1;
		push @suggestions, @suggestions2;
        ######################
		###################### BR-PHONETIC RULES
        ######################
		foreach $sug (@suggestions) {
			$word_position++;
			# foreach rule (20 br-phonetic rules)
			foreach $r (1..20) {
				@sound_typed_word = &sound_encode($word, $r);
				@sound_code = &sound_encode($sug, $r);
				foreach $input_code (@sound_typed_word) {
					foreach $candidadte_code (@sound_code) {
						if (&sound_cmp($input_code,$candidadte_code)) {
							$correct_word = $sug;
							if ($uppercase) {
								$correct_word = decode("utf-8", $correct_word);
								$correct_word = ucfirst($correct_word);
								$correct_word = encode("utf-8", $correct_word);
							}
                            $known_words_size--;
                            #return $correct_word;
						}
					}
				}
			}
		}
        ######################
		###################### SOUNDEX
        ######################
		# No suggestion using BR-PHONETIC RULES => try SOUNDEX
		if ($known_words_size) {
			$sound_typed_word = &do_soundex(decode('utf-8',$word));
			$sound_typed_word = encode('utf-8', $sound_typed_word);
			foreach $sug (@suggestions) {
				$word_position++;
				$sound_code = &do_soundex(decode('utf-8',$sug));
				$sound_code = encode('utf-8',$sound_code);
				if ($sound_typed_word eq $sound_code) {
					$correct_word = $sug;
					if ($uppercase) {
                        $correct_word = decode("utf-8", $correct_word);
                        $correct_word = ucfirst($correct_word);
                        $correct_word = encode("utf-8", $correct_word);
					}
					$known_words_size--;
					if (!$known_words_size) {
						last
					}
				}
			}
		}
		# No suggestion yet: return the most frequent word
		if ($known_words_size) {
			foreach $sug (@suggestions) {
				$word_position++;
				$correct_word = $sug;
				if ($uppercase) {
                    $correct_word = decode("utf-8", $correct_word);
                    $correct_word = ucfirst($correct_word);
                    $correct_word = encode("utf-8", $correct_word);
				}
				$known_words_size--;
				if (!$known_words_size) {
					last
				}
			}
		}
		if ($known_words_size) {
			$correct_word = $original_word;
		}
	}
	return $correct_word;
}

sub expand_lexicon {
    $siglas_lexicon_file = "$ENV{PWD}/resources/lexico_siglas.txt";
    $int_lexicon_file = "$ENV{PWD}/resources/lexico_internetes.txt";
    $int_sigl_lexicon_file = "$ENV{PWD}/resources/lexico_internetes_sigl_abrv.txt";
    $np_lexicon_file = "$ENV{PWD}/resources/lexico_nome_proprio.txt";
    $estr_lexicon_file = "$ENV{PWD}/resources/lexico_estrangeirismo.txt";
    $medidas_lexicon_file = "$ENV{PWD}/resources/lexico_unidade_medida.txt";
    open SIGLAS, $siglas_lexicon_file or die $!;
    open INT, $int_lexicon_file or die $!;
    open INT_SIGL, $int_sigl_lexicon_file or die $!;
    open NP, $np_lexicon_file or die $!;
    open ESTR, $estr_lexicon_file or die $!;
    open MED, $medidas_lexicon_file or die $!;
    chomp(@siglas = <SIGLAS>);
    chomp(@int = <INT>);
    chomp(@int_sigl = <INT_SIGL>);
    chomp(@np = <NP>);
    chomp(@estr = <ESTR>);
    chomp(@med = <MED>);
    # remove first line: csv description
    shift @siglas;
    shift @int;
    shift @int_sigl;
    shift @np;
    shift @estr;
    shift @med;
    foreach (@siglas) {
        if (/(.*?),/) {
            $w = $1;
            $w = decode('utf-8', $w);
            $w = lc $w;
            $w = encode('utf-8', $w);
            $ignore{$w} = 0 if (! $ignore{$w});
        }
    }
    foreach (@int) {
        if (/(.*?),/) {
            $w = $1;
            $w = decode('utf-8', $w);
            $w = lc $w;
            $w = encode('utf-8', $w);
            $ignore{$w} = 0 if (! $ignore{$w});
        }
    }
    foreach (@int_sigl) {
        if (/(.*?),/) {
            $w = $1;
            $w = decode('utf-8', $w);
            $w = lc $w;
            $w = encode('utf-8', $w);
            $ignore{$w} = 0 if (! $ignore{$w});
        }
    }
    foreach $w (@np) {
        $w = decode('utf-8', $w);
        $w = lc $w;
        $w = encode('utf-8', $w);
		# add proper nouns in lexicon -> we will try to correct wrong proper nouns
		$dict{$w} = 0 if (! $dict{$w});
    }
    foreach $w (@estr) {
        $w = decode('utf-8', $w);
        $w = lc $w;
        $w = encode('utf-8', $w);
		# add foreign words in lexicon -> we will try to correct wrong foreign words
		$dict{$w} = 0 if (! $dict{$w});
    }
    foreach $w (@med) {
        $w = decode('utf-8', $w);
        $w = lc $w;
        $w = encode('utf-8', $w);
		$ignore{$w} = 0 if (! $ignore{$w});
    }
}

# remove some rare words related to diacritic (varias - várias, etc.)
sub clean_lexicon {
    $blacklist = "$ENV{PWD}/resources/blacklist_gemeas.txt";
	open BLACKLIST, $blacklist or die $!;
	chomp(@blacklist_words = <BLACKLIST>);
	foreach $w (@blacklist_words) {
		delete $dict{$w} if exists $dict{$w};
	}
}

sub main {
	if (not $ARGV[1]) {
		print "\nUsage:\n";
		print "\tperl $0 -stat <FREQ-WORDS>\n";
        print "\tperl $0 -stat ./lexicos/regra+cb_freq.txt\n\n";
		print "\tperl $0 -stat <FREQ-WORDS> -f <INPUT-TEXT-FILE>\n";
        print "\tperl $0 -stat ./lexicos/regra+cb_freq.txt -f ./data/input_texts/input_test.txt\n\n";
		print "\tperl $0 -stat <FREQ-WORDS> -d <INPUT-DIR-PATH>\n";
        print "\tperl $0 -stat ./lexicos/regra+cb_freq.txt -d ./data/input_texts/\n\n";
		print "FREQ-WORDS: utf-8 encoded file, and each line WORD,FREQ, must have this pattern: [A-Za-zÀ-ú_-]+,\\d+\n";
		print "INPUT-TEXT-FILE: utf-8 encoded file, containing a text to be checked the misspelling errors\n";
        print "INPUT-DIR-PATH: dir with files to be spell-checked. Only \".txt\" files will be processed\n";
		exit 0;
	}
	if ($ARGV[0] eq '-stat') {
		#print "Loading statistic data...\n";
		open STATFILE, $ARGV[1] or die $!;
		@stat = <STATFILE>;
		foreach (@stat) {
			$dict{$1} = $2 if /([A-Za-zÀ-ú_-]+),(\d+)/;
		}
        # expand_lexicon adds (proper nouns, foreign words, internet slangs, etc.)
        &expand_lexicon();
		# use blacklist_gemeas.txt to remove diacritic words (rare words)
		&clean_lexicon();
		# spell check a tokenized txt file
		if ($ARGV[2] eq '-f') {
			print &pp_text($ARGV[3]);
        } elsif ($ARGV[2] eq '-d') {
            #print "ARGV3: $ARGV[3]\n";
            $dir_name = $ARGV[3];
            $last = substr $ARGV[3], -1;
            if ($last eq '/') {
                $dir_name =  substr $ARGV[3], 0, -1;
            }
            opendir(DIR, $dir_name) or die "cannot open directory $dir_name";
            @texts = grep(/\.txt$/,readdir(DIR));
            mkdir "$dir_name/checked";
			# create parallel lop
			$pl = Parallel::Loops->new(20);
            $pl->foreach (\@texts, sub {
                $input_file = $_;
				$result = &pp_text("$dir_name/$input_file");
                open FILE, ">", "$dir_name/checked/$input_file";
                print FILE $result;
                close FILE;
            }
            );
		# spell check a word from stdin
		} else {
			print "#\n";
			while (chomp ($word = <STDIN>)) {
                if ($word !~ /[[:punct:]|\d]+/) {
                    print &spell_check($word), "\n";
                }
                elsif ($word =~ /\-/) {
                    print &spell_check($word), "\n";
                } else {
                    print "$word\n";
                }
			}
			print "\n";
		}
	}
}
&main;
