import sys
from numpy import *
from collections import defaultdict 
from OrderedDefaultDict import *
import re


#PRINT EXPECTED ARGS
print "ARGS: PDB-FILE"
print "Converting PDB to restart.dat"
print "Using xyz-boxsize from pdb."

#CONST
ang_to_atomic = 1.0/0.529177211

#READ PDB FILE
with open(sys.argv[1]) as f:
    data = f.readlines()

#ACCEPT ONLY PDB FILES
if not sys.argv[1][-3:]=="pdb":
    print "Please use .pdb files..Aborting"
    exit()

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
    species[ls[2]].append(ls[-5:-2])
    if ls[2] not in molecules[ls[3]]:
        molecules[ls[3]].append(ls[2])

#PRINT WHAT WAS FOUND
print "Read pdb file (A): " + sys.argv[1] 
cnt = 1
for m in molecules.keys():
    for s in molecules[m]:
        print "(" + str(cnt) + ") MOL " + m + " RES "  + s + ": " + str(len(species[s])).rjust(10-len(s))
    cnt += 1    	

print "...creating ./restart.dat"
#----OUTPUT----
sys.stdout = open('restart.dat', 'w')

#HEADER
print "restart\nexplicitmol\nT positions\nF velocities\nF wall charges\nF dipoles\nF full run log\nMolecules"  

#MOLIDS PDB FILE
sp_cnt = 1
molit_cnt = 0
for m in molecules.keys():
	if m != "CDC" and m != "WAL":
		for s in molecules[m]:
			it_cnt = 1
			for e in species[s]:
				print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
				it_cnt += 1
			sp_cnt += 1
		molit_cnt += it_cnt-1

it_cnt = molit_cnt+1
for m in molecules.keys():
	if m == "CDC" or m == "WAL":
		for s in molecules[m]:
			for e in species[s]:
				print str(it_cnt).rjust(10) + str(0).rjust(10)        
				it_cnt += 1

#POSITIONS PDB
print "Positions"
for m in molecules.keys():
	if m != "CDC" and m != "WAL":
		for s in molecules[m]:
			for e in species[s]:
				fCoords = ang_to_atomic * array((map(float, e)))
				print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(fCoords[2]).rjust(20)
for m in molecules.keys():
	if m == "CDC" or m == "WAL":
		for s in molecules[m]:
			for e in species[s]:
				fCoords = ang_to_atomic * array((map(float, e)))
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
