#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2017/11/4 上午10:47
# @Author  : Shihan Ran
# @Site    : 
# @File    : speech to text.py
# @Software: PyCharm

import os
import json
import pyaudio
import time
import wave
import multiprocessing
import socket
import time

def print_ts(message):  # print headlines
    print("[%s] %s"%(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), message))

# PyAudio example: Record a few seconds of audio and save to a WAVE file
def record(i):
    path = './' + str(i) + '.wav'

    CHUNK = 1024
    FORMAT = pyaudio.paInt16
    CHANNELS = 2
    RATE = 44100
    RECORD_SECONDS = 5

    WAVE_OUTPUT_FILENAME = path

    p = pyaudio.PyAudio()
    stream = p.open(format=FORMAT,
                    channels=CHANNELS,
                    rate=RATE,
                    input=True,
                    frames_per_buffer=CHUNK)

    print("* recording")
    frames = []
    for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        data = stream.read(CHUNK)
        frames.append(data)

    print("* done recording")

    stream.stop_stream()
    stream.close()
    p.terminate()
    wf = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b''.join(frames))
    wf.close()

def detec(text):  # detec the id of player
    words = text.split()
    dict = {'one':1, 'two':2, 'three':3, 'four':4, 'five':5, 'six':6, 'seven':7, 'eight':8, 'nine':9, 'ten':10}
    for word in words:
        if word in dict: return dict[word]

def trans(id):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # ipv4,udp
    sock.bind(('127.0.0.1', 54377))  # UDP服务器端口和IP绑定
    buf, addr = sock.recvfrom(40960)  # 等待matlab发送请求，这样就能获取matlab client的ip和端口号
    print(addr)

    s = str(id)  # 将数据转化为String
    sock.sendto(bytes(s, encoding="utf8"), addr)  # 将数据转为bytes发送给matlab的client
    print(s)
    time.sleep(1)

    sock.close()

def get_speeches(i):  # get speeched to text

    path = './' + str(i) + '.wav'

    cmd = 'curl -X POST -u 810e0500-12e4-4ed8-a1ac-4706ae4858d1:IjZZ80MAGJlY \
    --header "Content-Type: audio/wav" \
    --header "Transfer-Encoding: chunked" \
    --data-binary @' + path + ' \
    "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize"'
    tmp = ' '.join(os.popen(cmd).readlines())

    speech = json.loads(tmp)
    text = speech['results'][0]['alternatives'][0]['transcript']

    print_ts("-" * 50)
    print(text)
    # text = 'Number seven , He got it !'
    id = detec(text)
    trans(id)

    return text, id

if __name__ == '__main__' :
    for i in range(1, 3):
        record(i)

        p = multiprocessing.Process(target=get_speeches, args=(i,))  # 用子进程保证录音的连续性
        p.start()