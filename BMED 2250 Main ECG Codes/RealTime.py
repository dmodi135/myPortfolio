'''
import serial
import numpy as np
from matplotlib import pyplot as plt
from time import time

ser = serial.Serial('/dev/cu.usbserial-14210', 9600)
i=0
# set plot to animated
plt.ion()

start_time = time()
timepoints = []
ydata = []
yrange = [-0.1, 5.1]
view_time = 0.1  # seconds of data to view at once
duration = 10  # total seconds to collect data

fig1 = plt.figure()
# http://matplotlib.org/users/text_props.html
fig1.suptitle('live updated data', fontsize='18', fontweight='bold')
plt.xlabel('time, seconds', fontsize='14', fontstyle='italic')
plt.ylabel('potential, volts', fontsize='14', fontstyle='italic')
plt.axes().grid(True)
line1, = plt.plot(ydata, marker='o', markersize=4, linestyle='none', markerfacecolor='red')
plt.ylim(yrange)
plt.xlim([0, view_time])

# flush any junk left in the serial buffer
ser.flushInput()
# ser.reset_input_buffer() # for pyserial 3.0+
run = True

# collect the data and plot a moving frame
while run:
    ser.reset_input_buffer()
    data = ser.readline()#.split(' ')

    # sometimes the incoming data is garbage, so just 'try' to do this
    try:
        # store the entire dataset for later
        ydata.append(float(data))  #float(data[0]) * 5.0 / 1024)
        timepoints.append(time() - start_time)
        current_time = timepoints[-1]

        # update the plotted data
        line1.set_xdata(timepoints)
        line1.set_ydata(ydata)

        # slide the viewing frame along
        if current_time > view_time:
            plt.xlim([current_time - view_time, current_time])

        # when time's up, kill the collect+plot loop
        if timepoints[-1] > duration: run = False

    # if the try statement throws an error, just do nothing
    except:
        pass

    # update the plot
    fig1.canvas.draw()

# plot all of the data you collected
fig2 = plt.figure()
# http://matplotlib.org/users/text_props.html
fig2.suptitle('complete data trace', fontsize='18', fontweight='bold')
plt.xlabel('time, seconds', fontsize='14', fontstyle='italic')
plt.ylabel('potential, volts', fontsize='14', fontstyle='italic')
plt.axes().grid(True)

plt.plot(timepoints, ydata, marker='o', markersize=4, linestyle='none', markerfacecolor='red')
plt.ylim(yrange)
fig2.show()

ser.close()

print("debug")
'''


'''
import serial
import matplotlib.pyplot as plt
import numpy as np
plt.ion()
fig=plt.figure()

i=0
x=list()
y=list()

ser = serial.Serial('/dev/cu.usbserial-14210',9600)
ser.close()
ser.open()

while True:

    data = ser.readline()
    print(data.decode())
    x.append(i)
    y.append(data.decode())

    #plt.scatter(i, float(data.decode()))
    plt.scatter(x, y)
    i += 1
    plt.show()
    #plt.pause(0.0001)  # Note this correction
'''

import serial # import Serial Library

import numpy # Import numpy

import matplotlib.pyplot as plt #import matplotlib library

from drawnow import *

HRV = []

arduinoData = serial.Serial('/dev/cu.usbserial-14210', 9600) #Creating our serial object named arduinoData

plt.ion() #Tell matplotlib you want interactive mode to plot live data
plt.draw()

cnt=0

def makeFig(): #Create a function that makes our desired plot
    plt.ylim(-1,6) #Set y min and max values

    plt.title('My Live Streaming Sensor Data') #Plot the title

    plt.grid(True) #Turn the grid on

    plt.ylabel('V') #Set ylabels

    plt.plot(HRV, 'ro-', label='Volts') #plot the temperature

    plt.legend(loc='upper left') #plot the legend
    plt.draw()

while True: # While loop that loops forever

    while (arduinoData.inWaiting()==0): #Wait here until there is data
        #print("no data yet")
        pass #do nothing

    #arduinoString = arduinoData.readline() #read the line of text from the serial port
    #print(arduinoString.readline.decode())
    HRV.append(arduinoData.readline().decode())
    drawnow(makeFig)
    plt.pause(.000001) #Pause Briefly. Important to keep drawnow from crashing

    cnt=cnt+1

