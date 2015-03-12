import os,sys

print "ARGS: JOBS_ROOTDIR WALLTIME(h) NODES PPN"

rootdir = sys.argv[1]
walltime = sys.argv[2]
nodes = sys.argv[3]
ppn = sys.argv[4]

cores = int(nodes)*int(ppn)
numSteps = cores*30*walltime  

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
		#CALC NUMSTEPS FROM SCALING LAWS
		if ACN=="0ACN":
			numSteps = int(81.6*pow(cores,0.834)*(float(walltime)-0.1))
		elif ACN=="10ACN":
			numSteps = int(84.346*pow(cores,0.8415)*(float(walltime)-0.1))
		elif ACN=="20ACN":
			numSteps = int(65.64*pow(cores,0.865)*(float(walltime)-0.1))
		elif ACN=="40ACN":
			numSteps = int(74.07*pow(cores,0.842)*(float(walltime)-0.1))
		#numSteps = int(numSteps*0.9)
		
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
		print "INPUTDIR=" + ap
		print "JOB=\"" + job + "\""                                                           
		print "mkdir -p $HOME/data/$JOB"
		print "cd $HOME/data/$JOB"
		print "NRUNS=$(ls -lR | grep ^d | wc -l)"
		print "DATADIR=\"$(expr $NRUNS + 1)\""
		print "mkdir $DATADIR"
		print "cd $DATADIR"
		print ""
		#FIRST RUN? USE restart.dat from INPUTDIR
		print "if [ \"$NRUNS\" == \"0\" ]; then"
		print "   RESTARTFILE=\"$INPUTDIR/restart.dat\""
		print "else"
		#Nth RUN? USE (N-1)th MOST RECENT testout.rst* IF FILE EXISTS, OTHERWISE (N-1)th restart.dat
		print "   if [ -a ../$NRUNS/testout.rst* ]; then"
		print "      RESTARTFILE=\"$(ls -t ../$NRUNS/testout.rst* | head -1)\""
		print "   else"
		print "      RESTARTFILE=\"../$NRUNS/restart.dat\""
		print "   fi"
		print "fi"
		print ""
		print "cp $INPUTDIR/potential.inpt $INPUTDIR/runtime.inpt ./"
		print "cp $RESTARTFILE ./restart.dat"
		print ""
		print "aprun -n " + str(cores) + " -N " + ppn + " $HOME/src/metalwalls/bin/metalwalls.exe"
	
		sys.stdout = sysout	


#CREATE SUBMIT FILE
with open("submit.sh",'w') as submitFile:
	submitFile.writelines(submits) 
