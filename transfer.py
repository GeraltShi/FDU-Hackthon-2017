#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2017/11/4 下午10:37
# @Author  : Shihan Ran
# @Site    : 
# @File    : transfer.py
# @Software: PyCharm

import socket
import time

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # ipv4,udp
sock.bind(('127.0.0.1', 54377))  # UDP服务器端口和IP绑定

buf, addr = sock.recvfrom(40960)  # 等待matlab发送请求，这样就能获取matlab client的ip和端口号
# print(addr)

s = str(None)  # 将数据转化为String
sock.sendto(bytes(s, encoding="utf8"), addr)  # 将数据转为bytes发送给matlab的client
time.sleep(1)

sock.close()