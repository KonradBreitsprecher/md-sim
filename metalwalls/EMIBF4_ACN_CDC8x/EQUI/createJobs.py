import os,sys
rootdir = sys.argv[1]
walltime = sys.argv[2]
nodes = sys.argv[3]
ppn = sys.argv[4]

for subdir, dirs, files in os.walk(rootdir):
	if len(dirs) == 0:
		
		if subdir[-1]=="/":
			subdir=subdir[:-1]
		sp = subdir.split("/")
		ap = os.path.abspath(subdir)
		outfile = os.path.join(ap,"job.pbs")
		
		T = sp[-3]
		ACN = sp[-2]
		V = sp[-1]
		job = "_".join([T,ACN,V])

		sys.stdout = open(outfile, 'w')

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
                print "aprun -n " + str(int(nodes)*int(ppn)) + " -N " + ppn + " $HOME/src/metalwalls/bin/metalwalls.exe"

