# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 15:54:17 2022

@author: George
"""
#import os
import time
import subprocess
import sys
from datetime import datetime

# run the script from linux bash

starttime = time.time() * 1000

'''
#os.system("./netft 192.168.1.2 >> data.csv")
stream = os.popen('./netft 192.168.1.2')
output = stream.read()
print(output)
'''

test = subprocess.Popen(["bash", "-c", 'watch -n 0.01 ./bash_script.sh'], stdout=subprocess.PIPE)
time.sleep(10)
'''
start = datetime.now()
stamp = start.strftime(" %Y-%m-%d %H %M %S")
with open('data' + stamp + '.csv', 'a') as file:
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
    while(x<100):
        if hasattr(sys, 'getwindowsversion'):
            print("windows")
            test = subprocess.Popen(["bash", "-c", "'watch -n 0.01 ./netft 192.168.1.2'"], stdout=subprocess.PIPE)
        else:
            test = subprocess.Popen(["./netft", "192.168.1.2"], stdout=subprocess.PIPE)
        output = test.communicate()
        #print(output)
        new = output[0].decode("utf-8") 
        #new = "".join(output[:-1])
        l_new = new.split('\n')
        for d in l_new[:-1]:
            parts = d.split(':')
            file.write(parts[1]+",")
        file.write('{0}\n'.format(time.time() * 1000 - starttime))
        x+=1
'''


#os.system("echo \"{0}\" >> data.csv".format(time.time() * 1000 - starttime))


"""
# client example

import socket, time
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('localhost', 49152))
while True:
    time.sleep(5)
    data = client_socket.recv(512)
    if data.lower() == 'q':
        client_socket.close()
        break

    print("RECEIVED: %s" % data)
    data = input("SEND( TYPE q or Q to Quit):")
    client_socket.send(data)
    if data.lower() == 'q':
        client_socket.close()
        break
"""

"""
import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the address given on the command line
server_name = '192.168.1.2' #sys.argv[1]
server_address = (server_name, 49152)
print (sys.stderr, 'starting up on {0} port {1}'.format(server_address[0], server_address[1]))
sock.bind(server_address)
sock.listen(1)

while True:
    print (sys.stderr, 'waiting for a connection')
    connection, client_address = sock.accept()
    try:
        print (sys.stderr, 'client connected:', client_address)
        while True:
            data = connection.recv(16)
            print (sys.stderr, 'received "{0}"'.format(data))
            if data:
                connection.sendall(data)
            else:
                break
    finally:
        connection.close()
"""
"""
import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the socket to the port where the server is listening
server_address = ('localhost', 49152)
print (sys.stderr, 'connecting to {0} port {1}'.format(server_address[0], server_address[1]))
sock.connect(server_address)
try:
    
    # Send data
    message = 'This is the message.  It will be repeated.'
    print (sys.stderr, 'sending "{0}"'.format(message))
    sock.sendall(message)

    # Look for the response
    amount_received = 0
    amount_expected = len(message)
    
    while amount_received < amount_expected:
        data = sock.recv(16)
        amount_received += len(data)
        print (sys.stderr, 'received "{0}"'.format(data))

finally:
    print (sys.stderr, 'closing socket')
    sock.close()
"""