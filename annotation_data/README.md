# Annotated dataset

## Tags:
- `O` --> common misspellings
- `Z` --> real-word misspellings
- `I` --> internet slang
- `C` --> case use (proper names and acronyms)
- `CC` --> case use (start of sentence)
- `S` --> glued words
- `P` --> punctuation

## Tagged text example:
- <wrong_word>`*<TAG>`[expected_word]
- videos`*O`[vídeos]
- da`*Z`[dá]
- ñ`*I`[não]
- skype`*C`[Skype]

ps: punctuation tag `*P[.]` just indicates missing periods.

## References
Duran, M. S.; Avanço, L. V.; Nunes, M. G. V. (2015). A Normalizer for UGC in Brazilian Portuguese. In: ACL 2015, Workshop on Noisy User-generated Text - WNUT, 2015, Beijing, China, p. 38-47.
<https://aclanthology.org/W15-4305/>
