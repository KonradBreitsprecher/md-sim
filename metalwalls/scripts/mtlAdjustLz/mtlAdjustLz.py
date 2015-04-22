import sys
from numpy import *
import re

#PRINT EXPECTED ARGS
print "ARGS: PATH_TO_restart.dat dLz(Angstrom) NUM_MOVING_PARTICLES PATH_TO_OUTPUT"
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
	#if readPos and not len(l.split()) == 3:
	if "Velocities" in l:
		posDataRaw = data[hdCnt+1:lCnt]
		footData = data[lCnt:-1]
		break
	#Start 'Positions' block 
	if "Positions" in l:
		headData = data[0:lCnt+1]	
		hdCnt = lCnt
		readPos = True
		
	lCnt += 1

#RESOLVE x*A type compression
posData = []
for pd in posDataRaw:
	pd_cs = pd.rstrip().split(",")
	if len(pd_cs) != 3:
		pd_ret = []
		for r in pd_cs:
			if "*" in r:
				r_ss = r.split("*")
				pd_ret.extend([r_ss[1]]*int(r_ss[0]))	
			else:
				pd_ret.append(r)
	else:
		pd_ret = pd_cs
	posData.append(pd_ret)


#OTHER INPUT ARGS
dLz = float(sys.argv[2])*0.1

num_ions = int(sys.argv[3])
num_cdc = 3821 #int(sys.argv[4])
num_border = 200 #int(sys.argv[5])

s_cdcR = num_ions + num_cdc
e_cdcR = s_cdcR + num_cdc
s_bR = e_cdcR + num_border


#OUTPUT FILENAME
#outfile = sys.argv[1].split("/")[-1] + "_adjusted_dLz_" + str(dLz)
outfile = sys.argv[4]

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
		rb_posz = float(l[-1]) 
	else:
		ncC += 1
	lCnt += 1

box_z = rb_posz + ang_to_atomic 
scale_ions = 1.0 + dLz / box_z

print "Found " + str(lCnt) + " position lines"
print "Scale " + str(isC) + " positions"
print "Shift " + str(cdcC) + " cdc positions"
print "Shift " + str(pC) + " right border positions"
print "Unchanged " + str(ncC) + " lines"

#----OUTPUT----
stdo = sys.stdout
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
for ls in posData:
	if lCnt < num_ions:
		isC += 1
		posz = float(ls[-1]) * scale_ions
		print str(ls[0]).rjust(20) + "," + str(ls[1]).rjust(20) + "," + str(posz).rjust(20)
	elif lCnt >= s_cdcR and lCnt < e_cdcR:    
		cdcC += 1
		posz = float(ls[-1]) + dLz
		print str(ls[0]).rjust(20) + "," + str(ls[1]).rjust(20) + "," + str(posz).rjust(20)
	elif lCnt >= s_bR:
		pC += 1
		posz = float(ls[-1]) + dLz
		print str(ls[0]).rjust(20) + "," + str(ls[1]).rjust(20) + "," + str(posz).rjust(20)
	else:
		ncC += 1
		print ",".join(ls)
	lCnt += 1

for l in footData:
	print l,

print "   " + str(box_z+dLz)

sys.stdout = stdo
print "DONE\n"

