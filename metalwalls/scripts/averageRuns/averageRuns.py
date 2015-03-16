import os,sys,glob
import numpy as np

print "ARGS: PATH_TO_RUNS [RUNINDICES] PATH_TO_OUTPUT_FOLDER"
print "Averages data found in PATH_TO_RUNS/RUNINDEX"

runRootDir = sys.argv[1]
runIndices = sys.argv[2:-1]
outputDir = sys.argv[-1]

#runNStepsLocal = []
#runNStepsGlobal = []
runNStepsDensity = []

runDensityFiles = []

#COLLECT RUN LENGHTS, CHECK FOR FILES
for runid in runIndices:
    runDir = runRootDir + "/" + runid
    runOutFile = runDir + "/run.out" 
    runDensityFiles.append(runDir + "/density.out") 
    #testrunFiles = glob.glob(runDir+"/testrun*")
    #testrunFiles.sort(key=os.path.getmtime)

    #SANITY CHECKS
    for neededFile in [runOutFile,runDensityFiles[-1]]:
        if not os.path.isfile(neededFile):
            sys.exit("Could not find " + neededFile)
        elif os.stat(neededFile).st_size == 0:
            sys.exit("File " + neededFile + " is empty")
    #GET RUN LENGHTS FROM run.out
    #with open(runOutFile,"r") as runOut:
    #    for l in runOut.readlines()[::-1]:
    #        if "Step" in l:
    #            if "*" in l:
    #                ld = [l.split("*")[-1]]*2
    #            else:
    #                ld = l[5:].split(",")
    #            ld = [int(lde.rstrip()) for lde in ld]
    #            print "Run " + runid + " has " + str(ld[1]) + " steps, maxsteps=" + str(ld[0]) 
    #            runNStepsGlobal.append(ld[0])
    #            runNStepsLocal.append(ld[1])
    #            break
    #GET RUN LENGHTS FROM density.out COMMENT
    with open(runDensityFiles[-1],"r") as runDens:
        for l in runDens.readlines():
            if "Average" in l:
                nst = int(l.split()[-2])
                print "Run " + runid + " has " + str(nst) + " steps" 
                runNStepsDensity.append(nst)
                break
            
sumStepsDensity = sum(runNStepsDensity)

print "Density: Found total of " + str(sumStepsDensity) + " steps" 

#AVERAGE DENSITY
densityComments = []
#GET NUMBER OF BINS
nBins = 0
with open(runDensityFiles[0],"r") as runDensity:
    densityTestData = runDensity.readlines()
    for l in densityTestData: 
        ls = l.strip()
        if not ls.startswith("#"):
            nBins+=1
        elif not "Average" in ls:
            densityComments.append(ls)
    nColumns = len(densityTestData[-1].split())

print "Density: Use spacing from first file: " + str(nBins) + " bins and " + str(nColumns) + " columns"

#COLLECT DATA
densityData = np.zeros((nBins,nColumns))
for runDensityFile,nSteps in zip(runDensityFiles,runNStepsDensity):
    print "Density: Get data from " + runDensityFile
    densityData += 1.0*nSteps/sumStepsDensity * np.genfromtxt(runDensityFile, comments="#")

#CREATE OUTPUT 
if not os.path.exists(outputDir):
    os.makedirs(outputDir)
                
#SAVE AVERAGED DENSITY DATA WITH COMMENTS
densityComments.insert(2,"# Average over " + str(sumStepsDensity) + " steps")
densityOut = outputDir + "/av_density.out"
with open(densityOut,"w") as out:
    for c in densityComments:
          out.write("%s\n" % c)
with open(densityOut,"a") as out:
    np.savetxt(out, densityData,fmt="%.9f")

print "Done writing " + densityOut
