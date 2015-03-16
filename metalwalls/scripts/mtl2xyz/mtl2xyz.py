#!/usr/bin/python
import sys

def isNumber(s):
    try:
        s=s.replace("d","e")
        float(s)
        return True
    except ValueError:
        return False

print "ARGS: PATH_TO_runtime.inpt PATH_TO_positions.out Output_File" 
#PARSE runtime.inpt
print "Parsing runtime.inpt"
runtimeFile = open(sys.argv[1],"r")
rData = runtimeFile.readlines()
molNames = []
molNum = []
molCharges = []
numSpecies = int(rData[3].split()[0])
print "----> Looking for " + str(numSpecies) + " species"
spc =0
currl=0
for rl in rData:
    d = rl.split()[0]
    if not isNumber(d) and not d==".false." and not d==".true.":
        molNames.append(d)
        nel=0
        for nl in rData[currl+1:]:
            d = nl.split()[0]
            if nel==0:
                molNum.append(int(d))
                nel+=1
            else:
                if (isNumber(d)):
                    molCharges.append(float(d))
                else:
                    molCharges.append(0)
                break    
        spc += 1
    if spc==numSpecies:
        break
    currl+=1

print "----> Found species:" 
for mname,mnum,mch in zip(molNames,molNum,molCharges):
    print mname.ljust(10,' ') + " N=" + str(mnum).ljust(10,' ') + " q=" + str(mch)
numParts = sum(molNum)
print "Total number of particles: " + str(numParts)
molInfo = []
for mname,mnum,mch in zip(molNames,molNum,molCharges):
    molInfo.append(mname + " N=" + str(mnum) + " q=" + str(mch))

#ANALYZE POSITION DATA
positionsFile = open(sys.argv[2], "r")
pData = positionsFile.readlines()
numPos = len(pData)
mod_p_N = numPos%numParts

#NUMBER OF POSITIONS DOESN'T CORRESPOND TO TOTAL PARTICLE NUMBER
if mod_p_N != 0:
    print "Number of positions (" + str(numPos) + "%" + str(numParts) + "=" + str(mod_p_N) + ") doesn't correspond to total particle number: ignoring last " + str(mod_p_N) + " postitions"
    pData = pData[:-mod_p_N]

#ADD PARTICLE NAMES
xyzData = []
mi = 0
mti = 0
numT = 0
for pd in pData:
    xyzData.append(molNames[mti] + " " + pd)
    mi += 1
    if mi==molNum[mti]:
        mti += 1
        mi = 0
        if mti==len(molNames):
            numT += 1
            mti = 0


#WRITE XYZ FILE
xyzFile = open(sys.argv[3], "w")
xyzFile.write(str(numParts) + "\n")
xyzFile.write("Converted position.out from metalwalls. " + str(numT) + " Timesteps. " + " ".join(molInfo) + "\n")
xyzFile.writelines(xyzData)

print "DONE converting " + sys.argv[2] + " to " + sys.argv[3]
