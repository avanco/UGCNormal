# -*- coding: utf-8 -*-
'''
Created on 21/07/2014

@author: Roque Lopez
'''
from __future__ import unicode_literals
from sklearn.metrics import confusion_matrix, recall_score, precision_score, f1_score, accuracy_score
import nltk
import codecs
import os
import string
import re

string_punctuation = string.punctuation + '``\'\''

def punkt(folder_path):
    ''' Return the labels of the classification by the method Punkt (implemented in NLTK library) '''
    files = sorted(os.listdir(folder_path))        
    sent_tokenizer = nltk.data.load('tokenizers/punkt/portuguese.pickle')
    classes_list = []

    for file_name in files:  
        data_file = codecs.open(os.path.join(folder_path, file_name), 'r', encoding='utf-8')
        text = data_file.read().strip()
        sentences = sent_tokenizer.tokenize(text)
        for sentence in sentences:
            classes_list += put_format(sentence)
        
    return classes_list

def mxterminator(folder_path):
    ''' Return the labels of the classification by the method MxTerminator (implemented in OpenNLP library) '''
    files = sorted(os.listdir(folder_path))# As OpenNLP is implemented in Java, we read the ouput of this library
    classes_list = []

    for file_name in files:  
        data_file = codecs.open(os.path.join(folder_path, file_name), 'r', encoding='utf-8')
        sentences = data_file.readlines()
        for sentence in sentences:
            classes_list += put_format(sentence.strip())
        
    return classes_list
            
def put_format(sentence):
    ''' Generate a list of labels for each word in a sentence '''
    sentence = re.sub('\.{2,}', " ", sentence)
    tokens = clean_tokens(nltk.word_tokenize(" ".join(re.split('\.(?=[^0-9]|\Z)', sentence))))
    if len(tokens) > 0:
        return [1] * (len(tokens)-1) + [0]
    return []
    
def clean_tokens(tokens):
    ''' Delete some tokens which are punctuation marks '''
    tmp_list = list()
    for token in tokens:
        if not token in string_punctuation:
            tmp_list.append(token)
    return tmp_list

def clean_tags(tokens_tags):
    ''' Delete some POS tags corresponding to punctuation marks '''
    tmp_list = list()
    for token, tag in tokens_tags:
        if not token in string_punctuation:
            tmp_list.append((token, tag))
    return tmp_list
        
def clean_text(text):
    ''' Delete some punctuation marks present in the text '''
    exclusion = ['.']
    for punctuation in string_punctuation:
        if not punctuation in exclusion:
            text = text.replace(punctuation, "")  
    return text

def print_metrics(label_test, predicted):
    ''' Print different metrics for the evaluation of the test set '''
    cm = confusion_matrix(label_test, predicted)
    print("CLASS YES: Precision = %.3f  Recall = %.3f F-Measure = %.3f" % (precision_score(label_test, predicted, pos_label=0, average='micro'), 
                                                                          recall_score(label_test, predicted, pos_label=0, average='micro'), 
                                                                          f1_score(label_test, predicted, pos_label=0, average='micro'))) 
     
    print("CLASS NO:  Precision = %.3f  Recall = %.3f F-Measure = %.3f" % (precision_score(label_test, predicted, pos_label=1, average='micro'), 
                                                                          recall_score(label_test, predicted, pos_label=1, average='micro'),
                                                                          f1_score(label_test, predicted, pos_label=1, average='micro')))
     
    print("AVERAGE:   Precision = %.3f  Recall = %.3f F-Measure = %.3f" % (precision_score(label_test, predicted, pos_label=None, average='macro'), 
                                                                          recall_score(label_test, predicted, pos_label=None, average='macro'),
                                                                          f1_score(label_test, predicted, pos_label=None, average='macro')))
    print("Accuracy = %.3f" % accuracy_score(label_test, predicted))
    print("Confusion Matrix")
    print(cm)      