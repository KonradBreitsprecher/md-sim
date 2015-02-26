#!/usr/bin/python

import sys

f = open(sys.argv[1], "r")

molIDs = {}
for i in range(0,100):
	molIDs[i]=0
posCnt = 0

for line in f:
	if "Molecules" in line:
		for mline in f:
			if "Positions" in mline:
				for pline in f:
					if "Velocities" in pline or "Cell" in pline:
						molIDs = dict((k,v) for k,v in molIDs.items() if v != 0)
						print "IDs:			" + str(molIDs)
						print "Total IDs:		" + str(sum(molIDs.itervalues()))
						print "Total Positions:	" + str(posCnt)						
						exit()
					else:
						posCnt += 1
			else:
				molIDs[int(mline.split()[1])]+=1

print "DONE"		
