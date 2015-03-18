import sys
from numpy import *
from collections import defaultdict 
from OrderedDefaultDict import *
import re

def foldPos(pos):
    dim = 0
    retPos = pos
    for co in pos:
        if co < 0:
            while co < 0:
                co += box[dim]
        elif co > box[dim]:
            while co > box[dim]:
                co -= box[dim]
        retPos[dim]=co
        dim += 1
    return retPos        

#PRINT EXPECTED ARGS
print "ARGS: PDB-FILE"
print "Converting PDB to restart.dat"
print "Using xyz-boxsize from pdb."

#CONST
ang_to_atomic = 1.0/0.529177211
molwl = ["YZ1","YZ2","YZP","YZN"]
molwlPOL = ["YZP","YZN"]
molwlNONPOL = ["YZ1","YZ2"]

#READ PDB FILE
with open(sys.argv[1]) as f:
    data = f.readlines()

#ACCEPT ONLY PDB FILES
if not sys.argv[1][-3:]=="pdb":
    print "Please use .pdb files..Aborting"
    exit()

#OUTPUT FILENAME
outfile = "restart.dat_" + sys.argv[1][:-4].split('/')[-1]

#REMOVE EMPTY LINES
data = filter(lambda x: not re.match(r'^\s*$', x), data)

#DELETE OBSOLETE LINES
data_f = []
for l in data:
    ls = l.split()
    if ls[0] == "CRYST1" or ls[0] == "ATOM":
       data_f.append(l) 

#PARSE BOXSIZE
l1 = data_f[0].split()
box = map(float, l1[1:4])
data_f = data_f[1:]

#GET SPECIES
species = OrderedDefaultdict(list)
molecules = OrderedDefaultdict(list)
for l in data_f:
    ls = l.split()
    mol=ls[3]
    molres=ls[2]
    res=mol+molres
    species[res].append(ls[-5:-2])
    if res not in molecules[mol]:
        molecules[mol].append(res)

#PRINT WHAT WAS FOUND
print "Read pdb file (A): " + sys.argv[1] 
cnt = 1
for m in molecules.keys():
    for s in molecules[m]:
        print "(" + str(cnt) + ") MOL " + m + " RES "  + s + ": " + str(len(species[s])).rjust(10-len(s))
    cnt += 1    	
<<<<<<< HEAD
=======

>>>>>>> 7d5aa5bc142fc96255eeefafcbee2d4c237a8f49
print "...creating ./" + outfile
#----OUTPUT----
sys.stdout = open(outfile, 'w')

<<<<<<< HEAD
sp_cnt = 1
=======
>>>>>>> 7d5aa5bc142fc96255eeefafcbee2d4c237a8f49
#HEADER
print "restart\nexplicitmol\nT positions\nF velocities\nF wall charges\nF dipoles\nF full run log\nMolecules"  

#MOLIDS PDB FILE
<<<<<<< HEAD
#ANIONS
sp_cnt = 1
molit_cnt = 0
for s in molecules["BF"]:
    it_cnt = 1
    for e in species[s]:
        print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
        it_cnt+=1
    sp_cnt += 1
molit_cnt += it_cnt-1
#CATIONS
for s in molecules["BMI"]:
    it_cnt = 1
    for e in species[s]:
        print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
        it_cnt+=1
    sp_cnt += 1
molit_cnt += it_cnt-1
#ACN
for s in molecules["AN"]:
    it_cnt = 1
    for e in species[s]:
        print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
        it_cnt+=1
    sp_cnt += 1
molit_cnt += it_cnt-1

#WALLS
=======
sp_cnt = 1
molit_cnt = 0
for m in molecules.keys():
	if m not in molwl:
		for s in molecules[m]:
			it_cnt = 1
			for e in species[s]:
				print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
				it_cnt += 1
			sp_cnt += 1
		molit_cnt += it_cnt-1

>>>>>>> 7d5aa5bc142fc96255eeefafcbee2d4c237a8f49
it_cnt = molit_cnt+1
for m in molecules.keys():
	if m in molwl:
		for s in molecules[m]:
			for e in species[s]:
				print str(it_cnt).rjust(10) + str(0).rjust(10)        
				it_cnt += 1

#POSITIONS PDB
print "Positions"
<<<<<<< HEAD
#ANIONS
for s in molecules["BF"]:
    for e in species[s]:
        fCoords = ang_to_atomic * foldPos(array((map(float,e))))
        print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
#CATIONS
for s in molecules["BMI"]:
    for e in species[s]:
        fCoords = ang_to_atomic * foldPos(array((map(float,e))))
        print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
#ACN
for s in molecules["AN"]:
    for e in species[s]:
        fCoords = ang_to_atomic * foldPos(array((map(float,e))))
        print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
#POLARIZABLE WALL
=======
for m in molecules.keys():
	if m not in molwl:
		for s in molecules[m]:
			for e in species[s]:
				fCoords = ang_to_atomic * foldPos(array((map(float,e))))
				print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
>>>>>>> 7d5aa5bc142fc96255eeefafcbee2d4c237a8f49
for m in molecules.keys():
	if m in molwlPOL:
		for s in molecules[m]:
			for e in species[s]:
				fCoords = ang_to_atomic * foldPos(array((map(float,e))))
				print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
<<<<<<< HEAD
#NON-POLARIZABLE WALL
=======
>>>>>>> 7d5aa5bc142fc96255eeefafcbee2d4c237a8f49
for m in molecules.keys():
	if m in molwlNONPOL:
		for s in molecules[m]:
			for e in species[s]:
				fCoords = ang_to_atomic * foldPos(array((map(float,e))))
				print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)

#CELL
box = ang_to_atomic*array(box)
print "Cell"
print "   1.00000000000000   0.000000000000000E+000   0.000000000000000E+000"
print "   0.000000000000000E+000   1.00000000000000   0.000000000000000E+000"
print "   0.000000000000000E+000   0.000000000000000E+000   1.000000000000000E+000"
print "   " + str(box[0])
print "   " + str(box[1])
print "   " + str(box[2])
