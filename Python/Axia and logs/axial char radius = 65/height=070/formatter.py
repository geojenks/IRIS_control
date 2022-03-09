# -*- coding: utf-8 -*-
"""
Created on Fri Feb 18 12:33:39 2022

@author: georg
script to format data from axia and encoder with 2 outputs
1: formatted axia data
2: combined data
"""
import os

# format axia data
filenames_ax = []
for file in os.listdir():
    if "axia" in file:
        filenames_ax.append(file)

for filename in filenames_ax:
    #with open(filename) as file:
    with open(filename) as file:
        data = file.read()
        #i=0
        #for line in data:
        data = data.replace('\n', ', ')
        data = data.replace('Status: ', '\n')
        data = data.replace('Fx: ', '')
        data = data.replace('Fy: ', '')
        data = data.replace('Fz: ', '')
        data = data.replace('Tx: ', '')
        data = data.replace('Ty: ', '')
        data = data.replace('Tz: ', '')
        #    data[i] = line
        #    i = i+1
        #    print(line)
        #    line = line.split(",")
        #    if i == 0:
        #        offset = int(line[7])
        #        line[7] = '0'
        #    else:
        #        print(line)
        #        line[7] = str(int(line[7] - offset))
        #    line = ",".join(line)
    #calibrate to starting time
    
    #data = "".join
    csv_file = open(filename[:-4] + "_formatted.csv", "w")
    #line = str(TIME) + ": " + str(CT) + "\n"
    csv_file.write("Status,Fx,Fy,Fz,Tx,Ty,Tz,time")
    csv_file.write(data)
    csv_file.close()
    
    # calibrate to starting time
    with open(filename[:-4] + "_formatted.csv") as file:
        data = file.readlines()
        i = 0
        for line in data[1:-1]:
            line = line.split(",")
            if i == 0:
                offset = int(line[7])
                line[7] = '0'
            else:
                line[7] = str(int(line[7]) - offset)
            i = i+1
            data[i] = ",".join(line)
    
    data = "".join(data)
    csv_file = open(filename[:-4] + "_formatted.csv", "w")
    csv_file.write(data)
    csv_file.close()

# calibrate encoder data   
filenames_enc = []
for file in os.listdir():
    if "encoder" in file:
        filenames_enc.append(file)

for filename in filenames_enc:
    offset = -10
    zero_encountered = 0
    zero_2_encountered = 0
    with open(filename) as file:
        print(filename)
        data = file.read()
        data = data.split("\n")
        data = data[:-1]
        data[0] = "0, 0"
        for i in range(0,len(data)):
            spl = data[i].split(",")
            #sort out timing column
            [entry.replace(" ", "") for entry in spl]
            if spl[0] == "0":
                spl[0] = str(i*10)+","
                offset = offset+10
                zero_encountered = 1
            elif zero_encountered:
                try:
                    spl[0] = str(int(spl[0]) + offset)+","
                except:
                    spl[0] = str(offset)+","    
            else:
                spl[0] = str(i*10)+","
                offset = offset+10
                spl[1] = "0"
            #sort out encoder column
            if len(spl) > 1 and spl[1] != "0":
                if zero_2_encountered == 0:
                    spl[1] = "0"
            if len(spl) > 1 and spl[1] == "0":
                zero_2_encountered = 1
            data[i] = "".join(spl)+"\n"
        data = "".join(str(d) for d in data)
        csv_file = open(filename[:-4] + "_calibrated.csv", "w")
        #line = str(TIME) + ": " + str(CT) + "\n"
        csv_file.write(data)
        csv_file.close()

# zip data together
# in formatted: get col 3, use col 7 to match col 0 of calibrated, get col 1 of calibrated
# add other info from formatted into the other columns

for filename in filenames_ax:
    csv_file = open(filename[9:26] + "_zipped.csv", "a")
    csv_file.write('encoder,Fz,Fx,Fy,Tx,Ty,Tz,time,turn_count\n')
    csv_file.close()
    turn_count = 0
    whole_turns_last = 0
    last_encoder = 0
    with open(filename[:-4] + "_formatted.csv", "r") as formatted:
        with open("encoder_data" + filename[9:26] + "_calibrated.csv", "r") as calibrated:
            #form = formatted.readlines()
            cal = calibrated.readlines()
            f_l = formatted.readlines()
            first = f_l[1].split(",")
            calib_axia = [0, int(first[1]), int(first[2]), int(first[3]),
                          int(first[4]), int(first[5]), int(first[6]),int(first[7])]
            for form in f_l[1:-1]:
                #print(form)
                form = form.split(",")
                time = round(int(form[7])/10)*10
#                if int(time)/10 > len(cal):
#                        break
                #encoder = cal[time].split(",")[1] #### this is now well off
                for row in cal:
                    row = row.split(",")
                    #use 10ms before as a back up
                    if str(time-10) == row[0]:
                        encoder = row[1]
                    if str(time) == row[0]:
                        encoder = row[1]
                whole_turns = round((-1*int(encoder) - 40000) / 100000)
                if whole_turns != whole_turns_last:
                    if last_encoder < encoder:
                        turn_count = turn_count + 1
                    else:
                        turn_count = turn_count - 1
                csv_file = open(filename[9:26] + "_zipped.csv", "a")
                csv_file.write(str(-1*int(encoder) - round((-1*int(encoder) - 40000) / 100000)*100000) + 
                               "," + str(-1*(int(form[3])-calib_axia[3])) +
                               "," + str(int(form[1])-calib_axia[1]) + "," + str(int(form[2])-calib_axia[2]) +
                               "," + str(int(form[4])-calib_axia[4]) + "," + str(int(form[5])-calib_axia[5]) +
                               "," + str(int(form[6])-calib_axia[6]) + "," + str(int(form[7])-calib_axia[7]) +
                               "," + str(turn_count) + "\n")
                csv_file.close()
                last_encoder = encoder
                whole_turns_last = whole_turns











