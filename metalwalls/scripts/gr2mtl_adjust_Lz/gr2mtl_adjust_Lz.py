import sys
from numpy import *
from collections import defaultdict 
from OrderedDefaultDict import *
import re

def foldPos(pos):
    dim = 0
    retPos = pos
    for co in pos:
        if dim < 2:
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
print "ARGS: PDB-FILE CDC_BORDER-FILE NUM-CDC_ATOMS NUM-BORDER_ATOMS SYSTEM_LENGTH"
print "Combining PDB-File with CDC+Border, shift PDB input to center of new box, shift right CDC+Border accordingly."
print "Expecting PDB-File with:\nLine 1: Box size in Format:* bx by bz .*\nLine 2-ENDOFFILE: Position Data in Format:* * ATOMID MOLID .* px py pz * *"  
print "Using xy-boxsize from pdb, z-boxsize from input."
print "Folding input coorinates in xy-dimension, NOT in z-dimension."

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

#PARSE HEADER/FOOTER
l1 = data[0].split()
box = map(float, l1[1:4])
data = data[1:]

#GET SPECIES
species = OrderedDefaultdict(list)
molecules = OrderedDefaultdict(list)
for l in data:
    ls = l.split()
    species[ls[2]].append(ls[-5:-2])
    if ls[2] not in molecules[ls[3]]:
        molecules[ls[3]].append(ls[2])

#READ CDC+BORDER FILE
coords_wall = genfromtxt(sys.argv[2]) # (au)
box_z_cdc = amax(coords_wall.T[2]) # (au)

#OTHER INPUT ARGS
num_cdc_atoms = int(sys.argv[3])
num_border_atoms = int(sys.argv[4])
box_z = float(sys.argv[5]) # (au)

#CDC-WIDTH
cdc_widthL = amax(coords_wall.T[2][:num_cdc_atoms/2])
cdc_widthR = box_z_cdc - amin(coords_wall.T[2][num_cdc_atoms/2:num_cdc_atoms])

#SHIFT PDB ATOMS TO CENTER OF NEW BOX_Z (au)
shift_pdb = box_z*0.5-ang_to_atomic*box[2]*0.5

#SHIFT RIGHT CDC AND RIGHT BORDER ACCORDING TO NEW BOX_Z (au)
shift_cdc = box_z-box_z_cdc

#PRINT WHAT WAS FOUND
ion_skin = 2.0*ang_to_atomic
overlap = False
ions_L = box_z*0.5-box[2]*0.5-ion_skin
ions_R = box_z*0.5+box[2]*0.5+ion_skin
if (ions_L < cdc_widthL):
    print "Most Left Ion pos " + str(ions_L) + " overlaps with CDC: Increase system length by " + str(2*(cdc_widthL-ions_L)) + " ...Aborting"
    overlap = True
if (ions_R > box_z-cdc_widthR):
    print "Most Right Ion pos " + str(ions_R) + " overlaps with CDC: Increase system length by " + str(2*(ions_R - box_z + cdc_widthR)) + " ...Aborting"
    overlap = True
if (overlap):
    exit(0)

print "Read pdb file (A): " + sys.argv[1] 
for s in species.keys():
    print s + ": " + str(len(species[s])).rjust(10-len(s))
print "Read CDC+Border-File (au): " + sys.argv[2]
print "Num CDC Atoms: " + str(num_cdc_atoms)
print "Num Border Atoms: " + str(num_border_atoms)
print "CDC+Border Box Length (au): " + str(box_z_cdc) 
print "Targeted Box Length (au): " + str(box_z) 
print "...creating ./restart.dat"

#----OUTPUT----
sys.stdout = open('restart.dat', 'w')

#HEADER
print "restart\nexplicitmol\nT positions\nF velocities\nF wall charges\nF dipoles\nF full run log\nMolecules"

#MOLIDS PDB FILE
sp_cnt = 1
molit_cnt = 0
for m in molecules.keys():
    for s in molecules[m]:
        it_cnt = 1
        for e in species[s]:
            print str(molit_cnt + it_cnt).rjust(10) + str(sp_cnt).rjust(10)        
            it_cnt += 1
        sp_cnt += 1
    molit_cnt += it_cnt-1

#MODIDS CDC LEFT
for i in range(1,num_cdc_atoms/2+1):
    molit_cnt += 1
    print str(molit_cnt).rjust(10) + str(0).rjust(10)        
sp_cnt += 1

#MODIDS CDC LEFT
for i in range(1,num_cdc_atoms/2+1):
    molit_cnt += 1
    print str(molit_cnt).rjust(10) + str(0).rjust(10)        
sp_cnt += 1

#MODIDS BODER
for i in range(1,num_border_atoms+1):
    molit_cnt += 1
    print str(molit_cnt).rjust(10) + str(0).rjust(10)        

#SHIFTED POSITIONS PDB
print "Positions"
for s in species.keys():
    for e in species[s]:
        fCoords = ang_to_atomic * array(foldPos(map(float, e)))
        print str(fCoords[0]).rjust(20) + str(fCoords[1]).rjust(20) + str(shift_pdb + fCoords[2]).rjust(20)

#POSITIONS CDC LEFT
for i in range(0,num_cdc_atoms/2):
    print str(coords_wall[i][0]).rjust(20) + str(coords_wall[i][1]).rjust(20) + str(coords_wall[i][2]).rjust(20) 
 
#SHIFTED POSITIONS CDC RIGHT
for i in range(num_cdc_atoms/2,num_cdc_atoms):
    print str(coords_wall[i][0]).rjust(20) + str(coords_wall[i][1]).rjust(20) + str(shift_cdc + coords_wall[i][2]).rjust(20) 

#POSITIONS BORDER LEFT
for i in range(num_cdc_atoms,num_cdc_atoms + num_border_atoms/2):
    print str(coords_wall[i][0]).rjust(20) + str(coords_wall[i][1]).rjust(20) + str(coords_wall[i][2]).rjust(20) 
 
#SHIFTED POSITIONS BORDER RIGHT
for i in range(num_cdc_atoms + num_border_atoms/2,num_cdc_atoms+num_border_atoms):
    print str(coords_wall[i][0]).rjust(20) + str(coords_wall[i][1]).rjust(20) + str(shift_cdc + coords_wall[i][2]).rjust(20) 

#CELL
box = ang_to_atomic*array(box)
print "Cell"
print "   1.00000000000000   0.000000000000000E+000   0.000000000000000E+000"
print "   0.000000000000000E+000   1.00000000000000   0.000000000000000E+000"
print "   0.000000000000000E+000   0.000000000000000E+000   1.000000000000000E+000"
print "   " + str(box[0])
print "   " + str(box[1])
print "   " + str(box_z)
