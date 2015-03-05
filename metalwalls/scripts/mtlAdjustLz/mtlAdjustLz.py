import sys
from numpy import *
import re

#PRINT EXPECTED ARGS
print "ARGS: PATH_TO_restart.dat dLz(Angstrom) NUM_IONS_TOTAL NUM_CDC NUM_P"
print "Shift right Carbon atoms + borders by dLz"
print "Scale Ion z position: z *= (1+dLz/Lz)"

#CONST
ang_to_atomic = 1.0/0.529177211

#READ RESTARTFILE
with open(sys.argv[1]) as f:
        data = f.readlines()

#REMOVE EMPTY LINES
data = filter(lambda x: not re.match(r'^\s*$', x), data)

#PARSE BOX SIZE
box_z = float(data[-1])

#HEADER/FOOTER
lCnt = 0
readPos = False
for l in data:
	#First appearance of sth else then 3 entries after 'Positions' defines end of positions block
	if readPos and not len(l.split()) == 3:
		posData = data[hdCnt+1:lCnt]
		footData = data[lCnt:-1]
		break
	#Start 'Positions' block 
	if "Positions" in l:
		headData = data[0:lCnt+1]	
		hdCnt = lCnt
		readPos = True
		
	lCnt += 1

#OTHER INPUT ARGS
dLz = float(sys.argv[2])

num_ions = int(sys.argv[3])
num_cdc = int(sys.argv[4])
num_border = int(sys.argv[5])

s_cdcR = num_ions + num_cdc
e_cdcR = s_cdcR + num_cdc
s_bR = e_cdcR + num_border

scale_ions = 1.0 + dLz / box_z

#OUTPUT FILENAME
outfile = sys.argv[1].split("/")[-1] + "_adjusted_dLz_" + str(dLz)

#PRINT WHAT WAS FOUND
print "Reading restart file: " + sys.argv[1] 
print "...creating ./" + outfile

#Tests
lCnt = 0
isC = 0
cdcC = 0
pC = 0
ncC = 0
for l in posData:
	if lCnt < num_ions:
		isC += 1
	elif lCnt >= s_cdcR and lCnt < e_cdcR:    
		cdcC += 1
	elif lCnt >= s_bR:
		pC += 1
	else:
		ncC += 1
	lCnt += 1

print "Found " + str(lCnt) + " position lines"
print "Scale " + str(isC) + " positions"
print "Shift " + str(cdcC) + " cdc positions"
print "Shift " + str(pC) + " right border positions"
print "Unchanged " + str(ncC) + " lines"

#----OUTPUT----
sys.stdout = open(outfile, 'w')

#HEADER
for l in headData:
	print l,

#POSITIONS
lCnt = 0
isC = 0
cdcC = 0
pC = 0
ncC = 0
for l in posData:
	if lCnt < num_ions:
		isC += 1
		ls = l.split()
		posz = float(ls[-1]) * scale_ions
		print str(ls[0]).rjust(20) + str(ls[1]).rjust(20) + str(posz).rjust(20)
	elif lCnt >= s_cdcR and lCnt < e_cdcR:    
		cdcC += 1
		ls = l.split()
		posz = float(ls[-1]) + dLz
		print str(ls[0]).rjust(20) + str(ls[1]).rjust(20) + str(posz).rjust(20)
	elif lCnt >= s_bR:
		pC += 1
		ls = l.split()
		posz = float(ls[-1]) + dLz
		print str(ls[0]).rjust(20) + str(ls[1]).rjust(20) + str(posz).rjust(20)
	else:
		ncC += 1
		print l,
	lCnt += 1

for l in footData:
	print l,

print "   " + str(box_z+dLz)

