#!/usr/bin/env python2
#-*- encoding: utf-8 -*-

import codecs
import sys
import re
import os

f = codecs.open(sys.argv[1]+'.tmp', 'w', 'utf-8')
for line in codecs.open(sys.argv[1], 'r', 'utf-8'):
    line = re.sub(r'(\s\.\s)(.*?)(\s)', lambda pattern: \
            pattern.group(1)+pattern.group(2).capitalize()+pattern.group(3), line)
    f.write(line)
f.close()
os.system('mv '+sys.argv[1]+'.tmp'+' '+sys.argv[1])
