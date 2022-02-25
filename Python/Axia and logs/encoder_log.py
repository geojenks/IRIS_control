# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 14:12:41 2022

@author: George
"""
import sys, os, serial, threading, time
from datetime import datetime

start = datetime.now()
stamp = start.strftime("%Y-%m-%d_%H%M%S")

def monitor():
    ser = serial.Serial(COMPORT, BAUDRATE)
    #time.sleep(2)
    ser.read_all()
    while (1):
        #ser.read_all()
        line = ser.readline()
        if (line != ""):
            #print line[:-1]         # strip \n
             #fields = line[:-1].split('; ');
            #ID = fields[0]
            #TIME = int(fields[1])
            # print fields
            #print "device ID: ", ID
            # write to file
            csv_file = open("data"+ stamp + ".csv", "a")
            #line = str(TIME) + ": " + str(CT) + "\n"
            line = line.decode("latin-1")#"utf-8")
            csv_file.write(line[:-1])
            csv_file.close()

        # do some other things here

    print("Stop Monitoring")

""" -------------------------------------------
MAIN APPLICATION
"""  

print("Start Serial Monitor")

COMPORT = "COM10"
BAUDRATE = 9600

monitor()