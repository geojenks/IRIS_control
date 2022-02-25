# -*- coding: utf-8 -*-
"""
Created on Thu Feb 17 12:09:14 2022

@author: georg
"""


import exiftool

#exiftool.executable = 'E:\\Users\\George\\Documents\\Git\ repositories\\IRIS_control\\Python\\Axia\ and\ logs\\executable.sh'
while(1):
    exiftool.executable.execute(b'./netft 192.168.1.2 >> new.csv')