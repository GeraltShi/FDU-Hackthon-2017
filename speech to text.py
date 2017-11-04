#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2017/11/4 上午10:47
# @Author  : Shihan Ran
# @Site    : 
# @File    : speech to text.py
# @Software: PyCharm

import os
import json
import time
import string
import nltk

def detec(text):  # detec the id of player
    words = text.split()
    dict = {'one':1, 'two':2, 'three':3, 'four':4, 'five':5, 'six':6, 'seven':7, 'eight':8, 'nine':9, 'ten':10}
    for word in words:
        if word in dict: return dict[word]

def get_speeches(path):  # get speeched to text
    cmd = 'curl -X POST -u 810e0500-12e4-4ed8-a1ac-4706ae4858d1:IjZZ80MAGJlY \
    --header "Content-Type: audio/flac" \
    --header "Transfer-Encoding: chunked" \
    --data-binary @' + path + ' \
    "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize"'
    tmp = ' '.join(os.popen(cmd).readlines())

    speech = json.loads(tmp)
    text = speech['results'][0]['alternatives'][0]['transcript']

    # text = 'Number seven , He got it !'
    return text

def main_loop():
     path = '/Users/caroline/Downloads/audio-file.flac'
     get_speeches(path)

if __name__ == '__main__':
    main_loop()