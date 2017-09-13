# -*- coding: utf-8 -*-
'''
Created on 20/07/2014

@author: Roque Lopez
'''

from __future__ import unicode_literals
from classifier import Classifier
from feature_extractor import Feature_Extractor
from probabilistic_tagger import ProbabilisticTagger
import sys
import os
import pickle 

if __name__ == '__main__':
    new_model = True
    train_path_list =  ["../resource/data/training_data/"]
    test_path = "../resource/data/input_data/"
    output_path = "../resource/data/output_data/"
    serialized_object = "../resource/data/fe_object.pkl"

    print "Reading training data..."

    if new_model:
    	fe = Feature_Extractor(True, False)
    	fe.extract_to_train(train_path_list)
    	with open(serialized_object, 'wb') as handle:
    		pickle.dump(fe, handle)
    else:
    	with open(serialized_object, 'rb') as handle:
    		fe = pickle.load(handle)

    index = fe.get_size()  
    c = Classifier()
    c.set_classifier('bayes')
    
    print "Reading test data..." 

    for file_name in os.listdir(test_path):
    	print file_name
    	fe.extract_to_test(os.path.join(test_path, file_name)) 
        predicted = c.classify(fe.get_instance_list(), fe.get_label_list(), index)          
        c.generate_output(output_path, file_name, fe.get_test_text(), fe.get_tokens_list()[index:])
        fe.reset(index)

    print "Outputs generated"