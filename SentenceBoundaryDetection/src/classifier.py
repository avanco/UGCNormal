# -*- coding: utf-8 -*-
'''
Created on 21/07/2014

@author: Roque Lopez
'''
from __future__ import unicode_literals
from sklearn.feature_extraction import DictVectorizer
from sklearn import tree, svm, cross_validation
from sklearn.naive_bayes import BernoulliNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import SGDClassifier
from sklearn.cross_validation import StratifiedShuffleSplit
from utils import print_metrics
import os
import re
import numpy
import codecs


class Classifier(object):
    '''
    Machine learning method to classify the words in a sentence as 'boundary' or 'no_boundary'
    '''
    
    def __init__(self):
        self.__label_list = None
        self.__instance_list = None
        self.__data_vectorized = None
        self.__vec = DictVectorizer(sparse=True)
        self.__classifier = None
        self.__predicted = None
        
    def set_classifier(self, name='bayes'):
        ''' Choose a machine learning method to classify the data '''
        if name == 'bayes':
            self.__classifier = BernoulliNB()
        elif name == 'gd':
            self.__classifier = SGDClassifier()
        elif name == 'svm':
            self.__classifier =  svm.LinearSVC()
        elif name == 'tree':
            self.__classifier = tree.DecisionTreeClassifier()
        elif name == 'knn':
            self.__classifier =  KNeighborsClassifier(n_neighbors=5)
            
    def classify(self, instance_list, label_list, index):
        ''' Classify the data and return the results '''
        self.__label_list = label_list
        self.__instance_list = instance_list
        self.__data_vectorized = self.__vec.fit_transform(instance_list)
        self.__predicted = self.__classifier.fit(self.__data_vectorized[:index], self.__label_list[:index]).predict(self.__data_vectorized[index:])
        #self.__print_errors(self.__label_list[index:], index)
        return self.__predicted
        
    def k_fold(self):
        ''' Classify the data splitting the training and test sets in K folds '''
        scores = cross_validation.cross_val_score(self.__classifier , self.__data_vectorized , numpy.array(self.__label_list), cv=10, scoring='accuracy')#scoring='f1'
        print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
    
    def k_stratified(self):
        ''' Classify the data splitting the training and test sets in folds preserving the percentage of samples for each class '''
        sss = StratifiedShuffleSplit(self.__label_list, n_iter=1, train_size=0.7, test_size=0.3)
        for train_index, test_index in sss:
            print (len(train_index), len(test_index))
            instance_train, instance_test = self.__data_vectorized[train_index], self.__data_vectorized[test_index]
            label_train, label_test = self.__label_list[train_index], self.__label_list[test_index]     
            predicted = self.__classifier.fit(instance_train, label_train).predict(instance_test)
            print_metrics(label_test, predicted)
       
    def generate_output(self, output_path, file_name, test_text, token_list):
        ''' Generate an output for each file of the test set '''
        iterator = 0
        sentence_list = []
        for index, token in enumerate(token_list):
            position = test_text[iterator:].find(token) + len(token)
            iterator += position
            if index > 0 and self.__predicted[index-1] == 0:
                iterator -= len(token)
                sentence_list.append((re.sub("\s+", " ", test_text[:iterator])).strip())
                test_text = test_text[iterator:]
                iterator = 0

        sentence_list.append((re.sub("\s+", " ", test_text)).strip())
        self.__save_sentences(sentence_list, output_path, file_name)
    
    def __save_sentences(self, sentence_list, output_path, file_name):
        text = ""

        for sentence in sentence_list:
            if len(sentence):
                sentence = sentence[0].upper() + sentence[1:]
                sentence = re.sub("-$", "", sentence).strip()
                sentence += "."
                sentence = re.sub(r"\.{2,}$", ".", sentence)
                sentence = re.sub(r"(,+\.$)|(;+\.$)", ".", sentence)#|(\?+\.$)|(\!+\.$)", ".", sentence)
                sentence = re.sub(r"(\?+)\.$", r"\1", sentence)
                sentence = re.sub(r"(\!+)\.$", r"\1", sentence)
                text += sentence + "\n"
        
        with codecs.open(os.path.join(output_path, file_name), 'w', encoding='utf-8') as f:
            f.write(text)
            
    def __print_errors(self, label_test, index):
        ''' Print the words in which the classifier fails (false positives and false negatives) '''
        size = len(label_test)
        inverse = self.__vec.inverse_transform(self.__data_vectorized)
        
        files = sorted(os.listdir("../resource/data/input_data/")) 
        j = 1
        instance_list = self.__instance_list[index:]
        print files[0]
        for i in range(size):
            if instance_list[i]['at7'] == 'None' and i != size - 1:
                print files[j]
                j += 1
            if label_test[i] == 0 and self.__predicted[i] == 1:
                print "FP", [key for key in inverse[index + i].keys() if key.startswith('at0=')][0].replace('at0=', '')
            if label_test[i] == 1 and self.__predicted[i] == 0:
                print "FN", [key for key in inverse[index + i].keys() if key.startswith('at0=')][0].replace('at0=', '')
