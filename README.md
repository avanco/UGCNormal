# UGCNormal

This is a normalizer tool for user-generated content (Brazilian Portuguese). You can use it as a service, look at [https://github.com/thiagootuler/ugcnormal_interface](ugcnormal_interface).


```

                            UGC-Normalizer

INPUT
|
|    -----------------------------      -------------      -----------
---> | SentenceBoundaryDetection | ---> | tokenizer | ---> | speller | ----
     -----------------------------      -------------      -----------    |
                                                                          |
                                                                          |
     ----------------------------------------------------------------------
     |
     |    --------------      ------------------      ----------
     ---> | siglas_map | ---> | internetes_map | ---> | np_map | ---> OUTPUT
          --------------      ------------------      ----------



>>> HOW TO USE:

Before anything else, run ./configure.sh script to check and solve all
dependencies. After that you can run the normalizer script.

Main script is ugc_norm.sh. Use it to apply the normalization pipeline. Just run and pass as
parameters INPUT_dir and OUTPUT_dir. The INPUT_dir must contain all text files
to be processed.

You can test the normalizer using the data in directory "test":

./ugc_norm.sh ./test/input/ ./test/output/



>>> MORE INFO:

******************************* test
Input and output directories to test the normalizer. The output directory tree
has the output produced by each step of this pipeline (sent -> tok -> checked
-> siglas -> internetes -> nomes). The deeper directory ('nomes') has the
result of the full pipeline (probably you are interested only in this result).


******************************* internetes_map.pl
perl script to translate web language using dictionary


******************************* np_map.pl
perl script to normalize NPs using (./resources/np_data.txt). It just
capitalizes the first letter


******************************* siglas_map.pl
Script to put all letters to upper case, if it is in ./resources/lexico_siglas.txt


******************************* upper_handler.py
It checks if a text file is totally in uppercase, if it is, only words after
punctuation are capitalized, all the others are set to lowercase


******************************* upper_periods.py
It capitalizes words after periods


******************************* README.txt
This file !


******************************* resources
Directory with dictionaries for NPs and web language


******************************* SentenceBoundaryDetection
Sentence boundary detection tool, it appends <S> tags at the end of each sentence


******************************* speller
Speller tool directory


******************************* tokenizer
Tokenizer tool directory, you can change lex rules in webtok.lex and run
Makefile using make tool


******************************* utils
- ./utils/extract.sh
This script extract all opinions (text files) in a corpus (many
subdirectories)
```

## References
Duran, M. S.; Avanço, L. V.; Nunes, M. G. V. (2015). A Normalizer for UGC in Brazilian Portuguese. In: ACL 2015, Workshop on Noisy User-generated Text - WNUT, 2015, Beijing, China, p. 38-47.
<http://aclanthology.info/papers/W15-4305/a-normalizer-for-ugc-in-brazilian-portuguese>
