# -*- coding: utf-8 -*-
"""
Created on Wed Feb 16 11:38:17 2022

@author: George
"""

#import threading as thread
from multiprocessing import Process

import serial, time, subprocess, sys
from datetime import datetime

start = datetime.now()
stamp = start.strftime("%Y-%m-%d_%H%M%S")

global finish
finish = 0

def process_finish():
    while(1):
        choice = input("Press Y to finish")
        if choice == "y" or choice =="Y":
            global finish
            finish = 1
            break

def monitor():
    print("Start Serial Monitor")
    COMPORT = "COM10"
    BAUDRATE = 9600
    ser = serial.Serial(COMPORT, BAUDRATE, timeout = None)
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
            csv_file = open("encoder_data"+ stamp + ".csv", "a")
            #line = str(TIME) + ": " + str(CT) + "\n"
            line = line.decode("latin-1")#"utf-8")
            csv_file.write(line[:-1])
            csv_file.close()
        if finish:
            ser.close()
            print("Stop Monitoring")
            break

# run the script from linux bash

def axia_log():
    test = subprocess.Popen(["bash", "-c", 'watch -n 0.01 ./bash_script.sh "{0}"'.format('axia_data' + stamp + '.csv')], stdout=subprocess.PIPE)
    #starttime = time.time() * 1000
    while(1):
        if finish:
            break
        '''
    with open('axia_data' + stamp + '.csv', 'a') as file:
        print("writing headers")
        file.write('Status' + ', ')
        file.write('Fx' + ', ')
        file.write('Fy' + ', ')
        file.write('Fz' + ', ')
        file.write('Tx' + ', ')
        file.write('Ty' + ', ')
        file.write('Tz' + ', ')
        file.write('Time' + '\n')
        x=0
        while(1):
            #if hasattr(sys, 'getwindowsversion'):
            #    test = subprocess.Popen(["bash", "-c", './netft 192.168.1.2'], stdout=subprocess.PIPE)
            #else:
            #    test = subprocess.Popen(["./netft", "192.168.1.2"], stdout=subprocess.PIPE)
            test = subprocess.Popen(["bash", "-c", "'watch -n 0.01 ./netft 192.168.1.2'"], stdout=subprocess.PIPE)
            if finish:
                break
            output = test.communicate()
            new = output[0].decode("utf-8") 
            #new = "".join(output[:-1])
            l_new = new.split('\n')
            for d in l_new[:-1]:
                parts = d.split(':')
                file.write(parts[1]+",")
            file.write('{0}\n'.format(time.time() * 1000 - starttime))
            x+=1
            if finish:
                break
            '''


if __name__ == "__main__":
    threads = [];
    a = Process(target=monitor, args=())
    #a = thread.Thread(target=monitor, args=())
    threads.append(a)
    b = Process(target=axia_log, args=())
    #b = thread.Thread(target=axia_log, args=())
    threads.append(b)
    #c = thread.Thread(target=process_finish, args=())
    # does not work in multiprocessing
    #c = Process(target=process_finish, args=())
    #threads.append(c)
    a.start()
    b.start()
    #c.start()
    a.join()
    b.join()
    #c.join()