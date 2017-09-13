#!/usr/bin/env python2
#-*- encoding: utf-8 -*-

import codecs
import sys
import re
import os

allupper = False
sentences = []
# first check if text is all upper case
for line in codecs.open(sys.argv[1], 'r', 'utf-8'):
    sentences.append(line.strip())
    allupper = line.isupper()

if allupper:
    os.system('rm '+sys.argv[1])
    f = codecs.open(sys.argv[1]+'.tmp', 'w', 'utf-8')
    for s in sentences:
        s = s[0].upper() + s[1:].lower()
        s = re.sub(r'([\?|!]\s*)(\w)', lambda pattern: pattern.group(1)+pattern.group(2).upper(), s)
        f.write(s+"\n")
    f.close()
