#!/usr/bin/python

from TOSSIM import *
import sys ,os
import random
import time #Pkapenekakis Gpiperakis

seed = int(time.time())  # Generate the seed
print("Saving RANDOM_SEED to file:", seed)

with open("seed.txt", "w") as f:
    f.write(str(seed))

#Start tossim simulation
t=Tossim([])
f=sys.stdout #open('./logfile.txt','w')
SIM_END_TIME= 1000 * t.ticksPerSecond()

print "TicksPerSecond : ", t.ticksPerSecond(),"\n"

#t.addChannel("Boot",f)
#t.addChannel("RoutingMsg",f)
#t.addChannel("NotifyParentMsg",f)
#t.addChannel("Radio",f)
#t.addChannel("Serial",f)
#t.addChannel("SRTreeC",f)
#t.addChannel("PacketQueueC",f)

#Aggregation
t.addChannel("SensorValues",f)
#t.addChannel("CustomSend",f)
#t.addChannel("CustomReceive",f)
#t.addChannel("CustomAggregationFunction",f)
#t.addChannel("CustomDataChosen",f)


#Micropulse
t.addChannel("generateValues",f)
t.addChannel("Phase1CriticalPathTask",f)
t.addChannel("Phase1Receive",f)
t.addChannel("Phase2PathPropagation",f)
t.addChannel("Phase2Receive",f)

t.addChannel("Custom",f)
t.addChannel("CustomBug",f)


for i in range(0,10):
	m=t.getNode(i)
	m.bootAtTime(10*t.ticksPerSecond() + i)


topo = open("topology.txt", "r")

if topo is None:
	print "Topology file not opened!!! \n"


	
r=t.radio()
lines = topo.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))

mTosdir = os.getenv("TINYOS_ROOT_DIR")
noiseF=open(mTosdir+"/tos/lib/tossim/noise/meyer-heavy.txt","r")
lines= noiseF.readlines()

for line in  lines:
	str1=line.strip()
	if str1:
		val=int(str1)
		for i in range(0,10):
			t.getNode(i).addNoiseTraceReading(val)
noiseF.close()
for i in range(0,10):
	t.getNode(i).createNoiseModel()
	
ok=False
#if(t.getNode(0).isOn()==True):
#	ok=True
h=True
while(h):
	try:
		h=t.runNextEvent()
		#print h
	except:
		print sys.exc_info()
#		e.print_stack_trace()

	if (t.time()>= SIM_END_TIME):
		h=False
	if(h<=0):
		ok=False

#print "Node 0 connected with node 1" , r.connected(0,1) , r.connected(1,0)
#print "Node 0 connected with node 2" , r.connected(0,2) , r.connected(2,0)
#print "Node 1 connected with node 7" , r.connected(1,7) , r.connected(7,1)
#print "Node 2 connected with node 3" , r.connected(2,3) , r.connected(3,2)
#print "Node 4 connected with node 8" , r.connected(4,8) , r.connected(8,4)
