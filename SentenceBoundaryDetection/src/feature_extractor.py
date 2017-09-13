# -*- coding: utf-8 -*-
'''
Created on 21/07/2014

@author: Roque Lopez
'''
from __future__ import unicode_literals
from nltk.corpus import stopwords
from nltk import word_tokenize
from utils import clean_tags, clean_tokens
import os
import codecs
import pickle
import csv
import re

BEGIN = 0
END = 1
NORMAL = 2
PRE = 'pre'
POST = 'post'
NONE = 'None'

p_symbol = '.'
stop_words = stopwords.words('portuguese')


class Feature_Extractor(object):
    '''
    Extract features for each word of the sentence 
    '''
    
    def __init__(self, uppercase=False, with_tagger=False):
        self.__uppercase = uppercase
        self.__tokens_list = list()
        self.__test_text = ""
        self.__instance_list = list()
        self.__label_list = list()
        self.__raw_freq_list = dict()
        self.__probabilities_tokens = {PRE:{}, POST:{}}
        self.__probabilities_tags = {PRE:{}, POST:{}}
        if with_tagger:
            with open("../resource/lexical/brill_tagger.pkl", 'rb') as handle:
                self.__tagger = pickle.load(handle)
        else:
            with open("../resource/lexical/probabilistic_tagger.pkl", 'rb') as handle:
                self.__tagger = pickle.load(handle)
    
    def extract_to_train(self, train_path_list):
        ''' Extract features in the training set '''
        for train_path in train_path_list:
            for file_name in os.listdir(train_path):
                self.read_file(os.path.join(train_path, file_name), False)
        self.calculate_probabilities()
        
    def extract_to_test(self, test_file_path):
        ''' Extract features in the test file '''
        index = self.get_size()
        self.read_file(test_file_path, True)
        self.get_probabilities(index)                  
 
    def read_file(self, file_path, is_testing):
        ''' Read and get the text of a file '''
        data_file = codecs.open(file_path, 'r', 'utf-8')
        text = data_file.read().strip()
        if is_testing: self.__test_text = text
        text = re.sub('\.{2,}', " ", text)
        if not self.__uppercase: text = text.lower()
        
        sentences = re.split('\.(?=[^0-9]|\Z)', text) 
        token_tag_list = []
        newlines_list = self.get_newlines_list(re.split("\n+|\r+", text))

        for sentence in sentences:
            sentence = sentence.strip()
            if len(sentence) > 0:
                tokens = word_tokenize(sentence)
                tmp_list = clean_tags(self.__tagger.tag(tokens))
                if len(tmp_list) > 0:
                    token_tag_list += tmp_list
                    token_tag_list.append((p_symbol, p_symbol))

        self.processing(token_tag_list, newlines_list)
        data_file.close()   

    def processing(self, token_tag_list, newlines_list): 
        ''' Analize and create a instance for each token of a text '''    
        size = len(token_tag_list)
        j = 0
        for i in range(size):    
            token_tag = token_tag_list[i] 
            is_begin, is_end = False, False
            if token_tag != (p_symbol, p_symbol): 
                
                if i+1 < size and token_tag_list[i+1] == (p_symbol, p_symbol): is_end = True 
                if token_tag_list[i-1] == (p_symbol, p_symbol): is_begin = True   
               
                new_instance = self.create_instance(token_tag, i, token_tag_list, is_begin, is_end, newlines_list[i-j])
                self.__instance_list.append(new_instance)
                
                if not token_tag in self.__raw_freq_list: self.__raw_freq_list[token_tag] = [0, 0, 0]
                
                if is_begin: 
                    self.__raw_freq_list[token_tag][BEGIN] += 1 
                    self.__label_list.append(1)      
                elif is_end: 
                    self.__raw_freq_list[token_tag][END] += 1  
                    self.__label_list.append(0)
                else:
                    self.__raw_freq_list[token_tag][NORMAL] += 1  
                    self.__label_list.append(1)
            else:
                j += 1 
                 
    def create_instance(self, token_tag, index, token_tag_list, is_begin, is_end, is_newline):
        ''' Create and return a new instance '''
        size = len(token_tag_list) - 1
        word_tuple = dict()
        self.__tokens_list.append(token_tag[0])
        tmp_index = index
        
        if is_begin: tmp_index -= 1
        has_pre_word = True if tmp_index - 1 >= 0  else False
        pre_word = token_tag_list[tmp_index - 1][0] if has_pre_word else NONE
        
        word_tuple['at1'] = pre_word
        word_tuple['at2'] = NONE # probability
        word_tuple['at3'] = token_tag[1] if has_pre_word else NONE
        word_tuple['at4'] = NONE # probability
        if has_pre_word: word_tuple['at5'] = True if pre_word.lower() in stop_words else False
        else: word_tuple['at5'] = NONE
        
        if self.__uppercase: 
            if has_pre_word: word_tuple['at6'] = self.is_uppercase(pre_word)
            else: word_tuple['at6'] = NONE
            
        tmp_index = index
        if is_end: tmp_index += 1
        has_post_word = True if tmp_index + 1 <= size else False
        post_word = token_tag_list[tmp_index + 1][0] if has_post_word else NONE

        word_tuple['at7'] = post_word
        word_tuple['at8'] = NONE # probability
        word_tuple['at9'] = token_tag[1] if has_post_word else NONE
        word_tuple['at10'] = NONE # probability
        if has_post_word: word_tuple['at11'] = True if post_word.lower() in stop_words else False
        else: word_tuple['at11'] = NONE
        
        if self.__uppercase: 
            if has_post_word: word_tuple['at12'] = self.is_uppercase(post_word)
            else: word_tuple['at12'] = NONE
        
       
        word_tuple['at13'] = is_newline
        word_tuple['at14'] = True if is_end else False
        
        return word_tuple
        
    def get_instance_list(self):
        ''' Return the list of instances '''
        return self.__instance_list
    
    def get_label_list(self):
        ''' Return the list of labels '''
        return self.__label_list
    
    def get_tokens_list(self):
        ''' Return the list of tokens '''
        return self.__tokens_list
    
    def get_test_text(self):
        ''' Return the test text '''
        return self.__test_text
    
    def get_raw_freq_list(self):
        ''' Return the list of frequencies '''
        return self.__raw_freq_list
    
    def get_size(self):
        ''' Return the number of instances '''
        return len(self.__instance_list)
    
    def get_newlines_list(self, segments):
        ''' Return a list indicating the positions where there is a newline marker '''
        tmp_list = []
        for segment in segments:          
            tokens = clean_tokens(word_tokenize(" ".join(re.split('\.(?=[^0-9]|\Z)', segment))))#segment.replace(p_symbol,"")))
            if len(tokens) > 0:
                tmp_list += [False] * (len(tokens)-1) + [True]
        return tmp_list
    
    def is_uppercase(self, word):
        ''' Verify if the first letter is in uppercase '''
        if len(word) == 1:
            return word.isupper() 
        else:
            return word[0].isupper() and word[1:].islower()
          
    def calculate_frequency(self):  
        ''' Calculate the frequency of occurrence of each token and tag '''
        frequency_tokens = dict()
        frequency_tags = dict() 
        
        for key, value in self.__raw_freq_list.items():
            token , tag = key
            # for tags
            if not tag in frequency_tags: frequency_tags[tag] = [0, 0, 0]
            frequency_tags[tag][BEGIN] += value[BEGIN] 
            frequency_tags[tag][END] += value[END]
            frequency_tags[tag][NORMAL] += value[NORMAL]
            # for tokens
            if not token in frequency_tokens: frequency_tokens[token] = [0, 0, 0]
            frequency_tokens[token][BEGIN] += value[BEGIN]
            frequency_tokens[token][END] += value[END]
            frequency_tokens[token][NORMAL] += value[NORMAL]
        
        return frequency_tokens, frequency_tags
    
    def calculate_probabilities(self):
        ''' Calculate the probability of occurrence of the POS tags (from the training set) '''
        frequency_tokens, frequency_tags = self.calculate_frequency()

        for new_instance in self.__instance_list:
            pre_word = new_instance.get('at1')
            post_word = new_instance.get('at7')
            pre_tag = new_instance.get('at3')
            post_tag = new_instance.get('at9')
            
            if pre_word != NONE:
                if pre_word in self.__probabilities_tokens[PRE]:
                    new_instance['at2'] =  self.__probabilities_tokens[PRE][pre_word]
                else:
                    frequencies = frequency_tokens[pre_word]
                    value = float(frequencies[END]) / float(frequencies[BEGIN] + frequencies[END] + frequencies[NORMAL])
                    new_instance['at2'] =  value
                    self.__probabilities_tokens[PRE][pre_word] = value
                
                if pre_tag in self.__probabilities_tags[PRE]:
                    new_instance['at4'] =  self.__probabilities_tags[PRE][pre_tag]
                else:                  
                    frequencies = frequency_tags[pre_tag]
                    value = float(frequencies[END]) / float(frequencies[BEGIN] + frequencies[END] + frequencies[NORMAL])
                    new_instance['at4'] =  value
                    self.__probabilities_tags[PRE][pre_tag] = value
            
            if post_word != NONE:               
                if post_word in self.__probabilities_tokens[POST]:
                    new_instance['at8'] =  self.__probabilities_tokens[POST][post_word]
                else:
                    frequencies = frequency_tokens[post_word]
                    value = float(frequencies[BEGIN]) / float(frequencies[BEGIN] + frequencies[END] + frequencies[NORMAL])
                    new_instance['at8'] =  value
                    self.__probabilities_tokens[POST][post_word] = value
                    
                if post_tag in self.__probabilities_tags[POST]:
                    new_instance['at10'] =  self.__probabilities_tags[POST][post_tag]
                else:
                    frequencies = frequency_tags[post_tag]
                    value = float(frequencies[END]) / float(frequencies[BEGIN] + frequencies[END] + frequencies[NORMAL])
                    new_instance['at10'] =  value
                    self.__probabilities_tags[POST][post_tag] = value 
                               
    
    def get_probabilities(self, index):
        ''' Assign the probability of occurrence of the POS tags for tokens in the training set '''
        for new_instance in self.__instance_list[index:]:
            pre_word = new_instance.get('at1')
            post_word = new_instance.get('at7')
            pre_tag = new_instance.get('at3')
            post_tag = new_instance.get('at9')
            
            if pre_word != NONE:
                new_instance['at2'] =  self.__probabilities_tokens[PRE].get(pre_word, NONE)
                new_instance['at4'] =  self.__probabilities_tags[PRE].get(pre_tag, NONE)

            if post_word != NONE:               
                new_instance['at8'] =  self.__probabilities_tokens[POST].get(post_word, NONE)
                new_instance['at10'] =  self.__probabilities_tags[POST].get(post_tag, NONE)
  
    def update_labels(self, index, corpus_path):
        ''' Update the labels of the test set according to the gold standard data '''
        files = sorted(os.listdir(corpus_path))
                        
        for file_name in files:
            data_file = codecs.open(os.path.join(corpus_path, file_name), 'r', encoding='utf-8')
            text = data_file.read().strip()
            text = re.sub('\.{2,}', " ", text)
            if not self.__uppercase: text = text.lower()
            sentences = re.split('\.(?=[^0-9]|\Z)', text)
            
            for sentence in sentences:
                sentence = sentence.strip()
                if len(sentence) > 0:
                    tokens = word_tokenize(sentence)
                    tmp_list = clean_tags(self.__tagger.tag(tokens))
                    size = len(tmp_list)
                   
                    for i in range(size):
                        self.__label_list[index] = 0 if i == size - 1 else 1
                        index += 1
    
    def reset(self, index):
        self.__tokens_list = self.__tokens_list[:index]
        self.__instance_list = self.__instance_list[:index]
        self.__label_list = self.__label_list[:index]
        self.__test_text = ""

    def print_pretty_instance(self, instance):
        ''' Return the features of a instance '''
        key_list = ['at' + str(i) for i in range(15)]
        attribute_list = [str(instance[id_key]) for id_key in key_list if id_key in instance]
        #print attribute_list
        return attribute_list
    
    def to_csvfile(self, file_name, index=0): 
        ''' Generate a CSV file with features and labels '''
        with open(file_name, 'wb') as csvfile:
            file_out = csv.writer(csvfile, quoting=csv.QUOTE_ALL)
            file_out.writerow(["at%d" % i for i in range(1,16)])
            
            for i in range(index, len(self.__instance_list)):
                file_out.writerow(self.print_pretty_instance(self.__instance_list[i]) + [self.__label_list[i]])
                                