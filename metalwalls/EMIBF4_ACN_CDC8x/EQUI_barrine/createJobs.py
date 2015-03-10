import os,sys

print "ARGS: JOBS_ROOTDIR WALLTIME(h) NODES PPN NUM_STEPS"

rootdir = sys.argv[1]
walltime = sys.argv[2]
nodes = sys.argv[3]
ppn = sys.argv[4]
numSteps = sys.argv[5]

cores = int(nodes)*int(ppn)
#numSteps = int(360000 * int(walltime) / (11.86 + 7508.77 / cores) * 0.5 )

submits = []  
sysout = sys.stdout

for subdir, dirs, files in os.walk(rootdir):
	if len(dirs) == 0:
		
		#GET SPECS FROM PATH
		if subdir[-1]=="/":
			subdir=subdir[:-1]
		sp = subdir.split("/")
		ap = os.path.abspath(subdir)
		
		T = sp[-3]
		ACN = sp[-2]
		V = sp[-1]
		job = "_".join([T,ACN,V])
		pbsoutfile = os.path.join(ap,"job.pbs")
		
		#CHANGE INTEGRATION STEPS IN runtime.inpt
		rinpt = os.path.join(subdir,"runtime.inpt")
		with open(rinpt,'r') as runtimeFile:
			runtimeData=runtimeFile.readlines()
		runtimeData[0]=str(numSteps) + "      Number of steps in the run.\n"
		with open(rinpt,'w') as runtimeFile:
			runtimeFile.writelines(runtimeData) 
		print "Set " + str(numSteps) + " steps in file " + rinpt
		
		#COLLECT pbs FILES FOR GLOBAL SUBMIT SCRIPTS
		submits.append("qsub " + pbsoutfile + "\n") 

  		print "Create " + pbsoutfile
	
		#CREATE PBS FILE
		sys.stdout = open(pbsoutfile, 'w')

		print "#!/bin/bash"
		print "#PBS -N " + job
		print "#PBS -l nodes=" + nodes + ":ppn=" + ppn
		print "#PBS -l walltime=" + walltime.zfill(2) + ":00:00"
                print ""
		print "JOB=\"" + job + "\""                                                           
		print "DATADIR=\"$HOME/data/$JOB\""
		print "INPUTDIR=" + ap
		print ""
		print "mkdir -p $DATADIR/"
		print "cd $DATADIR"
		print "rm *out* testout*"
		print ""
		print "cp $INPUTDIR/potential.inpt $INPUTDIR/restart.dat $INPUTDIR/runtime.inpt ./"
		print ""
		print "aprun -n " + str(cores) + " -N " + ppn + " $HOME/src/metalwalls/bin/metalwalls.exe"
	
		sys.stdout = sysout	


#CREATE SUBMIT FILE
with open("submit.sh",'w') as submitFile:
	submitFile.writelines(submits) 
